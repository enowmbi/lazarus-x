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

class ArchivedEmployee < ApplicationRecord
  belongs_to  :employee_category
  belongs_to  :employee_position
  belongs_to  :employee_grade
  belongs_to  :employee_department
  belongs_to  :nationality, class_name: "Country"
  has_many    :archived_employee_bank_details, dependent: :destroy
  has_many    :archived_employee_additional_details, dependent: :destroy

  has_one_attached :photo do |attached_image|
    attached_image.variant(:thumb, resize_to_limit: [100, 100])
    attached_image.variant(:small, resize_to_limit: [150, 150])
  end

  before_save :status_false

  def status_false
    self.status = 0 unless status.zero?
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end
end
