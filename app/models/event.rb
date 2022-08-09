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

class Event < ApplicationRecord
  validates :title, :description, :start_date, :end_date, presence: true

  has_many :batch_events, dependent: :destroy
  has_many :employee_department_events, dependent: :destroy
  has_many :user_events, dependent: :destroy
  belongs_to :origin, polymorphic: true

  scope :holidays, -> { where(is_holiday: true) }
  scope :exams, -> { where(is_exam: true) }

  def validate
    if !(start_date.nil? || end_date.nil?) && (end_date < start_date)
      errors.add(:end_time, t('can_not_be_before_the_start_time').to_s)
    end
  end

  def student_event?(student)
    flag = false
    base = origin
    if base.present? && base.respond_to?('batch_id') && (base.batch_id == student.batch_id)
      finance = base.fee_table
      flag = true if finance.present? && finance.map(&:student_id).include?(student.id)
    end
    user_events = self.user_events
    flag = true if !user_events.nil? && user_events.map(&:user_id).include?(student.user.id)
    flag
  end

  def employee_event?(user)
    user_events = self.user_events
    return true if !user_events.nil? && user_events.map(&:user_id).include?(user.id)

    false
  end

  def active_event?
    flag = false
    if origin.nil?
      flag = true
    elsif origin.respond_to?('is_deleted')
      flag = true unless origin.is_deleted
    else
      flag = true
    end
    flag
  end

  def dates
    (start_date.to_date..end_date.to_date).to_a
  end

  class << self
    def a_holiday?(day)
      return true if Event.holidays.where("start_date <=? AND end_date >= ?", day, day).count.positive?

      false
    end
  end
end
