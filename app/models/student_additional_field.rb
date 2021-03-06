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

class StudentAdditionalField < ApplicationRecord
  NAME_FORMAT = %r{\A[^~`@%$*()\-\[\]{}"':;/.,\\=+|]*\z}i

  belongs_to :student
  belongs_to :student_additional_detail
  has_many :student_additional_field_options, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :name, format: { with: NAME_FORMAT, message: I18n.t('must_contain_only_letters_numbers_space').to_s }
  accepts_nested_attributes_for :student_additional_field_options, allow_destroy: true
end
