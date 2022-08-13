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

class Subject < ApplicationRecord
  belongs_to :batch
  belongs_to :elective_group
  has_many :timetable_entries
  has_many :employees_subjects
  has_many :employees, through: :employees_subjects
  has_many :students_subjects
  has_many :students, through: :students_subjects
  has_many :grouped_exam_reports
  # TODO: has_and_belongs_to_many_with_deferred_save :fa_groups

  validates :name, presence: true
  validates :credit_hours, presence: { if: :check_grade_type }
  validates :max_weekly_classes, presence: true, numericality: true
  validates :amount, numericality: { allow_nil: true }
  validates :code, presence: true,
                   uniqueness: { case_sensitive: false, scope: %i[batch_id is_deleted], unless: :is_deleted? }

  scope :for_batch, ->(b) { where(batch_id: b.to_i, is_deleted: false) }
  scope :without_exams, -> { where(no_exams: false, is_deleted: false) }
  scope :active, -> { where(is_deleted: false) }

  before_save :fa_group_valid

  def check_grade_type
    if batch.nil?
      false
    else
      batch = self.batch
      batch.gpa_enabled? || batch.cwa_enabled?
    end
  end

  def inactivate
    update(is_deleted: true)
    employees_subjects.destroy_all
  end

  def lower_day_grade
    subjects = Subject.where(elective_group_id: elective_group_id) # unless elective_group_id.nil?
    selected_employee = nil
    subjects.each do |subject|
      employees = subject.employees
      employees.each do |employee|
        if selected_employee.nil?
          selected_employee = employee
        elsif employee.max_hours_per_day.to_i < selected_employee.max_hours_per_day.to_i
          selected_employee = employee
        end
      end
    end
    selected_employee
  end

  def lower_week_grade
    subjects = Subject.where(elective_group_id: elective_group_id) # unless elective_group_id.nil?
    selected_employee = nil
    subjects.each do |subject|
      employees = subject.employees
      employees.each do |employee|
        if selected_employee.nil?
          selected_employee = employee
        elsif employee.max_hours_per_week.to_i < selected_employee.max_hours_per_week.to_i
          selected_employee = employee
        end
      end
    end
    selected_employee
  end

  def no_exam_for_batch(batch_id)
    grouped_exams = GroupedExam.where(batch_id: batch_id).collect(&:exam_group_id)
    exam_not_created(grouped_exams)
  end

  def exam_not_created(exam_group_ids)
    exams = Exam.where(exam_group_id: exam_group_ids, subject_id: id)
    exams.empty? ? true : false
  end

  private

  def fa_group_valid
    fa_groups.group_by(&:cce_exam_category_id).each_value do |fg|
      if fg.length > 2
        errors.add(:fa_group, "cannot have more than 2 fa group under a single exam category")
        return false
      end
    end
  end
end
