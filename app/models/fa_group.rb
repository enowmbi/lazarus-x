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
class FaGroup < ApplicationRecord
  has_many :fa_criteria, class_name: "FaCriterium"
  has_and_belongs_to_many :subjects
  belongs_to :cce_exam_category
  has_many :cce_reports, through: :fa_criterium

  scope :active, -> { where(is_deleted: false) }

  validates :name, presence: true
  validates :max_marks, presence: true
  validates :desc, presence: true
end
