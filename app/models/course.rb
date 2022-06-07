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

class Course < ApplicationRecord
  GRADINGTYPES = { "1" => "GPA", "2" => "CWA", "3" => "CCE" }.freeze

  validates :course_name, presence: true
  validates :code, presence: true
  validate :presence_of_initial_batch, on: :create

  has_many :batches
  has_many :batch_groups
  has_many :ranking_levels
  has_many :class_designations
  has_many :subject_amounts
  accepts_nested_attributes_for :batches
  has_and_belongs_to_many :observation_groups
  # TODO: has_and_belongs_to_many_with_deferred_save :cce_weightages
  has_and_belongs_to_many_with_deferred_save :cce_weightages

  before_save :cce_weightage_valid

  scope :active, -> { where(is_deleted: false).order('course_name asc') }
  scope :deleted, -> { where(is_deleted: true).order('course_name asc') }
  scope :cce, -> { select("courses.*").where(grading_type: GRADINGTYPES.invert["CCE"]).order('course_name asc') }

  def presence_of_initial_batch
    errors.add_to_base I18n.t('should_have_an_initial_batch').to_s if batches.empty?
  end

  def inactivate
    update(is_deleted: true)
  end

  def full_name
    "#{course_name} #{section_name}"
  end

  def active_batches
    batches.all(conditions: { is_active: true, is_deleted: false })
  end

  def has_batch_groups_with_active_batches
    batch_groups = self.batch_groups
    return false if batch_groups.empty?

    batch_groups.each do |b|
      return true if b.has_active_batches == true
    end
    false
  end

  def find_course_rank(batch_ids, sort_order)
    batches = Batch.find_all_by_id(batch_ids)
    @students = Student.find_all_by_batch_id(batches)
    @grouped_exams = GroupedExam.find_all_by_batch_id(batches)
    ordered_scores = []
    student_scores = []
    ranked_students = []
    @students.each do |student|
      score = GroupedExamReport.find_by(student_id: student.id, batch_id: student.batch_id, score_type: "c")
      marks = 0
      marks = score.marks unless score.nil?
      ordered_scores << marks
      student_scores << [student.id, marks]
    end
    ordered_scores = ordered_scores.compact.uniq.sort.reverse
    @students.each do |student|
      m = 0
      student_scores.each do |student_score|
        m = student_score[1] if student_score[0] == student.id
      end
      ranked_students << if (sort_order == "") || (sort_order == "rank-ascend") || (sort_order == "rank-descend")
                           [(ordered_scores.index(m) + 1), m, student.id, student]
                         else
                           [student.full_name, (ordered_scores.index(m) + 1), m, student.id, student]
                         end
    end
    ranked_students = if ["", "rank-ascend", "name-ascend"].include?(sort_order)
                        ranked_students.sort
                      else
                        ranked_students.sort.reverse
                      end
  end

  def cce_enabled?
    Configuration.cce_enabled? && grading_type == "3"
  end

  def gpa_enabled?
    Configuration.gpa? && grading_type == "1"
  end

  def cwa_enabled?
    Configuration.cwa? && grading_type == "2"
  end

  def normal_enabled?
    grading_type.nil? || grading_type == "0"
  end
  #  def guardian_email_list
  #    email_addresses = []
  #    students = self.students
  #    students.each do |s|
  #      email_addresses << s.immediate_contact.email unless s.immediate_contact.nil?
  #    end
  #    email_addresses
  #  end
  #
  #  def student_email_list
  #    email_addresses = []
  #    students = self.students
  #    students.each do |s|
  #      email_addresses << s.email unless s.email.nil?
  #    end
  #    email_addresses
  #  end
  class << self
    def grading_types
      hsh = ActiveSupport::OrderedHash.new
      hsh["0"] = "Normal"
      types = Configuration.grading_types
      types.each { |t| hsh[t] = GRADINGTYPES[t] }
      hsh
    end

    def grading_types_as_options
      grading_types.invert.sort_by { |_k, v| v }
    end
  end

  def cce_weightages_for_exam_category(cce_exam_cateogry_id)
    cce_weightages.where(cce_exam_category_id: cce_exam_cateogry_id)
  end

  private

  def cce_weightage_valid
    cce_weightages.group_by(&:criteria_type).each_value do |v|
      unless v.collect(&:cce_exam_category_id).length == v.collect(&:cce_exam_category_id).uniq.length
        errors.add(:cce_weightages, "can't assign more than one FA or SA under a single exam category.")
        return false
      end
    end
    true
  end
end
