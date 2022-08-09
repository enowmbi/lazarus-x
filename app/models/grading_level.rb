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

class GradingLevel < ApplicationRecord
  belongs_to :batch

  validates :name, presence: true, uniqueness: { scope: %i[batch_id is_deleted], case_sensitive: false }
  validates :min_score, presence: true
  validates :credit_points, presence: true, if: :batch_has_gpa?

  default_scope -> { order('min_score desc') }
  scope :default, -> { where(batch_id: nil, is_deleted: false) }
  scope :for_batch, ->(b) { where(batch_id: b.to_i, is_deleted: false) }

  def inactivate
    update :is_deleted, true
  end

  def batch_has_gpa?
    batch_id && batch.gpa_enabled?
  end

  def to_s
    name
  end

  def self.exists_for_batch?(batch_id)
    batch_grades = GradingLevel.where(batch_id: batch_id, is_deleted: false)
    default_grade = GradingLevel.default
    return false if batch_grades.blank? && default_grade.blank?

    true
  end

  class << self
    def percentage_to_grade(percent_score, batch_id)
      batch_grades = GradingLevel.for_batch(batch_id)
      if batch_grades.empty?
        GradingLevel.default.where("min_score <= ?", percent_score.round).order('min_score desc').first
      else
        GradingLevel.for_batch(batch_id).where("min_score <= ?", percent_score.round).order('min_score desc').first
      end
    end
  end
end
