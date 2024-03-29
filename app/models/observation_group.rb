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
class ObservationGroup < ApplicationRecord
  has_many :observations, dependent: :destroy
  has_many :descriptive_indicators, through: :observations
  belongs_to :cce_grade_set
  has_and_belongs_to_many :courses

  scope :active, -> { where(is_deleted: false) }

  OBSERVATION_KINDS = { '0' => 'Scholastic', '1' => 'Co Scholastic Activity', '3' => 'Co Scholastic Area' }.freeze

  validates :name, presence: true
  validates :header_name, presence: true
  validates :observation_kind, presence: true # ,:max_marks
  validates :desc, presence: true
end
