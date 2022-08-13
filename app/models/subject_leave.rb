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
class SubjectLeave < ApplicationRecord
  belongs_to :student
  belongs_to :batch
  belongs_to :subject
  belongs_to :employee
  belongs_to :class_timing

  validates :subject_id, presence: true
  validates :batch_id, presence: true
  validates :student_id, presence: true
  validates :month_date, presence: true
  validates :reason, presence: true
  validate :month_date_less_than_admission_date

  scope :by_month_and_subject, ->(d, s) { where(month_date: d.beginning_of_month..d.end_of_month, subject_id: s) }
  scope :by_month_batch_subject, ->(d, b, s) { where(month_date: d.beginning_of_month..d.end_of_month, subject_id: s, batch_id: b) }

  validates :student_id, uniqueness: { scope: %i[class_timing_id month_date], message: "already marked as absent" }

  private

  def month_date_less_than_admission_date
    return unless month_date
    return unless month_date >= student.admission_date

    errors.add(:month_date, I18n.t('attendance_before_the_date_of_admission').to_s)
  end
end
