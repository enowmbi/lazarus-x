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

class StudentAdditionalDetail < ApplicationRecord
  belongs_to :student
  belongs_to :student_additional_field, foreign_key: 'additional_field_id'

  # TODO:  validates :additional_info, presence: true, if: :is_mandatory

  def save
    super unless destroyed?
    true
  end

  def validate
    if student_additional_field.is_mandatory == true
      if additional_info.blank?
        errors.add("additional_info", "can't be blank")
        false
      else
        true
      end
    else
      destroy if additional_info.blank?
      true
    end
  end
end
