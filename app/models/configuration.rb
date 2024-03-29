# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Configuration < ApplicationRecord
  STUDENT_ATTENDANCE_TYPE_OPTIONS = [[I18n.t('daily_text').to_s, "Daily"],
                                     [I18n.t('subject_wise_text').to_s, "SubjectWise"]].freeze

  NETWORK_STATES = [[I18n.t('online').to_s, 'Online'], [I18n.t('offline').to_s, 'Offline']].freeze
  LOCALES = [].freeze
  Dir.glob(Rails.root.join("/config/locales/*.yml")).each do |file|
    file.gsub!(Rails.root.join("/config/locales/"), '')
    file.gsub!(".yml", '')
    LOCALES << file
  end

  def validate
    if config_key == "StudentAttendanceType" && !check_student_attendance_type_option
      errors.add_to_base("#{I18n.t('student_attendance_type_should_be_one')} #{STUDENT_ATTENDANCE_TYPE_OPTIONS}")
    end

    return unless config_key == "NetworkState" && !check_network_state

    errors.add_to_base("#{I18n.t('network_state_should_be_one')} #{NETWORK_STATES}")
  end

  def self.clear_school_cache(user)
    Rails.cache.delete("current_school_name#{user.id}")
  end

  class << self
    def get_config_value(key)
      c = find_by(config_key: key)
      c.nil? ? nil : c.config_value
    end

    def save_institution_logo(upload)
      directory = Rails.root.join("/public/uploads/image")
      filename = 'institute_logo.jpg'
      path = File.join(directory, filename) # create the file path
      File.open(path, "wb") { |f| f.write(upload['datafile'].read) } # write the file
    end

    def available_modules
      modules = Configuration.where(config_key: "AvailableModules")
      modules.map(&:config_value)
    end

    def config_values(values_hash)
      values_hash.each_pair { |key, value| set_value(key.to_s.camelize, value) }
    end

    def set_value(key, value)
      config = find_by(config_key: key)
      if config.nil?
        Configuration.create(config_key: key, config_value: value)
      else
        config.update(:config_value, value)
      end
    end

    def get_multiple_configs_as_hash(keys)
      conf_hash = {}
      keys.each { |k| conf_hash[k.underscore.to_sym] = get_config_value(k) }
      conf_hash
    end

    def grading_types
      grading_types = Course::GRADINGTYPES
      types = all(conditions: { config_key: grading_types.values, config_value: "1" }, group: :config_key)
      grading_types.keys.select { |k| types.collect(&:config_key).include? grading_types[k] }
    end

    def default_country
      find_by(config_key: 'DefaultCountry').config_value.to_i
    end

    def update_grading_types(updates)
      # expects an array of integers types
      grading_types = Course::GRADINGTYPES
      deletions = grading_types.keys - updates
      updates.each do |t|
        find_or_create_by_config_key(grading_types[t]).update(:config_value, 1)
      end
      deletions.each do |t|
        find_or_create_by_config_key(grading_types[t]).update(:config_value, 0)
      end
    end

    def default_time_zone_present_time
      server_time = Time.zone.now
      server_time_to_gmt = server_time.getgm
      local_tzone_time = server_time
      time_zone = Configuration.find_by(config_key: "TimeZone")
      if !time_zone.nil? && !time_zone.config_value.nil?
        zone = TimeZone.find(time_zone.config_value)
        local_tzone_time = if zone.difference_type == "+"
                             server_time_to_gmt + zone.time_difference
                           else
                             server_time_to_gmt - zone.time_difference
                           end
      end
      local_tzone_time
    end

    def cce_enabled?
      get_config_value("CCE") == "1"
    end

    def gpa?
      get_config_value("GPA") == "1"
    end

    def cwa?
      get_config_value("CWA") == "1"
    end
  end

  private

  def check_student_attendance_type_option
    Configuration::STUDENT_ATTENDANCE_TYPE_OPTIONS.collect do |d|
      d[1] == config_value
    end.include?(true)
  end

  def check_network_status
    NETWORK_STATES.collect do |d|
      d[1] == config_value
    end.include?(true)
  end
end

#   Configuration table entries
#
#   StudentAttendanceType  => Daily | SubjectWise
#   CurrencyType           => Rs, $, E, ...
#   ExamResultType         => Marks | Grades | MarksAndGrades
#   InstitutionName        => name of the school or college
