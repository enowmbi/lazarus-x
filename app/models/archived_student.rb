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

class ArchivedStudent < ApplicationRecord
  include CceReportMod

  belongs_to :country
  belongs_to :batch
  belongs_to :student_category
  belongs_to :nationality, class_name: 'Country'
  has_many :archived_guardians, foreign_key: 'ward_id', dependent: :destroy, inverse_of: :ward
  has_one :immediate_contact, dependent: :destroy

  has_many   :students_subjects, primary_key: :former_id, foreign_key: 'student_id'
  has_many   :subjects, through: :students_subjects

  has_many   :cce_reports, primary_key: :former_id, foreign_key: 'student_id'
  has_many   :assessment_scores, primary_key: :former_id, foreign_key: 'student_id'
  has_many   :exam_scores, primary_key: :former_id, foreign_key: 'student_id'

  before_save :is_active_false

  has_one_attached :photo do |attached_photo|
    attached_photo.variant(:thumb, resize_to_limit: [100, 100])
    attached_photo.variant(:small, resize_to_limit: [150, 150])
  end

  def active_false
    self.is_active = 0 unless is_active.zero?
  end

  def gender_as_text
    gender == 'm' ? 'Male' : 'Female'
  end

  def first_and_last_name
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def immediate_contact
    ArchivedGuardian.find(immediate_contact_id) unless immediate_contact_id.nil?
  end

  def all_batches
    graduated_batches + batch.to_a
  end

  def graduated_batches
    BatchStudent.joins(:batch).where(student_id: former_id.to_i).select("batches.*")
  end

  def additional_detail(additional_field)
    StudentAdditionalDetail.find_by(additional_field_id: additional_field, student_id: former_id)
  end

  def retaken_exam?(subject_id)
    retaken_exams = PreviousExamScore.where(student_id: former_id)
    unless retaken_exams.empty?
      exams = Exam.where(id: retaken_exams.collect(&:exam_id))
      return true if exams.collect(&:subject_id).include?(subject_id)
    end
    false
  end
end
