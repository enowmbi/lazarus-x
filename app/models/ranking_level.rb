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
class RankingLevel < ApplicationRecord
  validates :name, presence: true
  validates :gpa, numericality: { if: :has_gpa }
  validates :marks, numericality: { if: :has_cwa }
  validates :subject_count, numericality: { allow_nil: true }

  belongs_to :course

  LIMIT_TYPES = %w[upper lower exact].freeze

  def gpa?
    course.gpa_enabled?
  end

  def cwa?
    course.cwa_enabled? or course.normal_enabled?
  end
end
