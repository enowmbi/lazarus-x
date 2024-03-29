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

class EmployeeSalaryStructure < ApplicationRecord
  belongs_to :payroll_category
  belongs_to :employee

  def archive_employee_salary_structure(archived_employee)
    salary_structure_attributes = attributes
    salary_structure_attributes.delete "id"
    salary_structure_attributes["employee_id"] = archived_employee
    delete if ArchivedEmployeeSalaryStructure.create(salary_structure_attributes)
  end
end
