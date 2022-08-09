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

class Attendance < ApplicationRecord
  belongs_to :student
  belongs_to :batch

  validates :reason, presence: true
  validates :month_date, presence: true
  validates :batch_id, presence: true
  validates :student_id, presence: true, uniqueness: { scope: :month_date, message: "already marked as absent" }
  scope :by_month, ->(d) { where(month_date: d.beginning_of_month..d.end_of_month) }
  scope :by_month_and_batch, ->(d, b) { where(month_date: d.beginning_of_month..d.end_of_month, batch_id: b) }
  # validate :student_current_batch

  def validate
    return if student.nil?

    if student.batch_id == batch_id
      true
    else
      errors.add('batch_id', "attendance is not marked for present batch")
      false
    end
  end

  def after_validate
    if month_date.nil?
      errors.add(t('month_date_cant_be_blank').to_s)
    elsif student.present? && (month_date < student.admission_date)
      errors.add(t('attendance_before_the_date_of_admission').to_s)
    end
  end

  def full_day?
    forenoon == true && afternoon == true
  end

  def half_day?
    forenoon == true || afternoon == true
  end
end
