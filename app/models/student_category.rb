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

class StudentCategory < ApplicationRecord
  has_many :students
  has_many :fee_category, class_name: "FinanceFeeCategory"

  before_destroy :check_dependence

  validates :name, presence: true
  validates :name, uniqueness: { scope: :is_deleted, case_sensitive: false }, unless: :is_deleted?

  scope :active, -> { where(is_deleted: false) }

  def empty_students
    Student.find_all_by_student_category_id(id).each do |s|
      s.update(student_category_id: nil)
    end
  end

  def check_dependence
    return if Student.where(student_category_id: id).present?

    errors.add_to_base(t('category_is_in_use').to_s)
    false
  end
end
