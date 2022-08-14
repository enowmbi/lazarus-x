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

class ApplyLeave < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_leave_type

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :reason, presence: true

  before_create :check_leave_count

  cattr_reader :per_page
  @per_page = 12

  def check_leave_count
    if !(start_date.nil? || end_date.nil?) && (end_date < start_date)
      errors.add_to_base(t('end_date_cant_before_start_date').to_s)

    end
    unless start_date.nil? || end_date.nil? || employee_leave_types_id.nil?
      leave = EmployeeLeave.find_by(employee_id: employee_id, employee_leave_type_id: employee_leave_types_id)
      leave_required = (end_date.to_date - start_date.to_date).numerator + 1
      if start_date.to_date < employee.joining_date.to_date
        errors.add_to_base(t('date_marked_is_before_join_date').to_s)

      elsif leave.leave_taken == leave.leave_count
        errors.add_to_base(t('you_have_already_availed').to_s)

      else
        new_leave_count = if is_half_day == true
                            leave_required / 2
                          else
                            leave_required.to_f
                          end
        if leave.leave_taken.to_f + new_leave_count.to_f > leave.leave_count.to_f
          errors.add_to_base(t('no_of_leaves_exceeded_max_allowed').to_s)

        end
      end
    end
    if errors.present?
      false
    else
      true
    end
  end
end
