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

class Weekday < ApplicationRecord
  belongs_to :batch
  has_many :timetable_entries, dependent: :destroy

  default_scope -> { order("weekday asc") }
  scope :default, -> { where(batch_id: nil, is_deleted: false) }
  scope :for_batch, ->(b) { where(batch_id: b.to_i, is_deleted: false) }

  def self.weekday_by_day(batch_id)
    weekdays = Weekday.where(batch_id: batch_id)
    weekdays = Weekday.default if weekdays.empty?
    weekdays.group_by(&:day_of_week)
  end

  def deactivate
    update(is_deleted: true)
  end

  def self.add_day(batch_id, day)
    if batch_id.zero?
      if Weekday.find_by(batch_id: nil, day_of_week: day).nil?
        w = Weekday.new
        w.day_of_week = day
        w.weekday = day
        w.is_deleted = false
        w.save
      else
        Weekday.find_by(batch_id: nil, day_of_week: day).update(is_deleted: false, day_of_week: day)
      end
    elsif Weekday.find_by(batch_id: batch_id, day_of_week: day).nil?
      w = Weekday.new
      w.day_of_week = day
      w.weekday = day
      w.batch_id = batch_id
      w.is_deleted = false
      w.save
    else
      Weekday.find_by(batch_id: batch_id, day_of_week: day).update(is_deleted: false, day_of_week: day)
    end
  end
end
