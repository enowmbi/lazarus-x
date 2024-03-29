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

class EmployeeAdditionalDetail < ApplicationRecord
  belongs_to :employee
  belongs_to :additional_field

  def archive_employee_additional_detail(archived_employee)
    additional_detail_attributes = attributes
    additional_detail_attributes.delete "id"
    additional_detail_attributes["employee_id"] = archived_employee
    delete if ArchivedEmployeeAdditionalDetail.create(additional_detail_attributes)
  end

  def save
    super unless destroyed?
    true
  end

  def validate
    if additional_field.is_mandatory == true
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
