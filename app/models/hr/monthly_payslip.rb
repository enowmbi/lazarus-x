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

class MonthlyPayslip < ApplicationRecord
  validates :salary_date, presence: true

  belongs_to :payroll_category
  belongs_to :employee
  belongs_to :approver, class_name: 'User'
  belongs_to :rejector, class_name: 'User'

  def approve(user_id, remark)
    self.is_approved = true
    self.approver_id = user_id
    self.remark = remark
    save
  end

  def reject(user_id, reason)
    self.is_rejected = true
    self.rejector_id = user_id
    self.reason = reason
    save
  end

  def self.find_and_filter_by_department(salary_date, dept_id)
    payslips = ""
    individual_payslip_category = ""
    if dept_id == "All"
      payslips = find_all_by_salary_date(salary_date.to_date, order: "payroll_category_id ASC",
                                                              include: [:payroll_category])
      individual_payslip_category = IndividualPayslipCategory.where(salary_date: salary_date.to_date).order("id ASC")
    else
      active_employees_in_dept = Employee.where(employee_department_id: dept_id).select("id")

      archived_employees_in_dept = ArchivedEmployee.where(employee_department_id: dept_id).select("former_id")

      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect do |a|
        a.former_id.to_i
      end

      payslips = find_all_by_salary_date(salary_date.to_date,
      conditions: ["employee_id IN (?)", all_employees_in_dept], order: "payroll_category_id ASC", include: [:payroll_category])
      individual_payslip_category =
        IndividualPayslipCategory
        .where(["employee_id IN (?) AND salary_date = ?", all_employees_in_dept, salary_date.to_date])
        .order("id ASC")
    end
    grouped_monthly_payslips = payslips.group_by(&:employee_id) if payslips.present?
    if individual_payslip_category.present?
      grouped_individual_payslip_categories = individual_payslip_category.group_by(&:employee_id)
    end
    { monthly_payslips: grouped_monthly_payslips,
      individual_payslip_category: grouped_individual_payslip_categories }
  end

  def active_or_archived_employee
    employee = Employee.find(employee_id)
    employee.presence || ArchivedEmployee.find_by(former_id: employee_id)
  end

  def status_as_text
    if is_approved == true
      t('approved').to_s
    elsif is_rejected == true
      t('rejected').to_s
    else
      t('pending').to_s
    end
  end

  def self.total_employees_salary(start_date, end_date, dept_id = "")
    total_monthly_payslips = ""
    if dept_id.blank?
      total_monthly_payslips = find(:all, select: "employee_id, amount, payroll_category_id,salary_date",
                                          order: 'salary_date desc', conditions: ["salary_date >= ? and salary_date <= ? and is_approved = 1", start_date.to_date, end_date.to_date], include: [:payroll_category])
    else
      active_employees_in_dept = Employee.find(:all, select: "id",
                                                     conditions: "employee_department_id = #{dept_id}")
      archived_employees_in_dept = ArchivedEmployee.find(:all, select: "former_id",
                                                               conditions: "employee_department_id = #{dept_id}")
      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect do |a|
                                                                         a.former_id.to_i
                                                                       end
      total_monthly_payslips = find(:all, select: "employee_id,amount,payroll_category_id,salary_date",
                                          order: 'salary_date desc', conditions: ["salary_date >= ? and salary_date <= ? and is_approved = 1 and employee_id IN (?)", start_date.to_date, end_date.to_date, all_employees_in_dept], include: [:payroll_category])
    end

    employee_ids = []
    employee_ids = total_monthly_payslips.collect(&:employee_id) if total_monthly_payslips.present?
    if employee_ids.present?
      employee_ids.uniq!
      total_individual_payslips =
        IndividualPayslipCategory
        .where("salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' AND employee_id IN (#{employee_ids.join(',')})").order("id ASC")
    end
    total_salary = 0
    if total_monthly_payslips.present?
      total_monthly_payslips.each do |payslip|
        total_salary += payslip.amount.to_f if payslip.payroll_category.is_deduction == false
        total_salary -= payslip.amount.to_f if payslip.payroll_category.is_deduction == true
      end
    end
    if total_individual_payslips.present?
      total_individual_payslips.each do |payslip|
        total_salary += payslip.amount.to_f if payslip.is_deduction == false
        total_salary -= payslip.amount.to_f if payslip.is_deduction == true
      end
    end
    { total_salary: total_salary, monthly_payslips: total_monthly_payslips,
      individual_categories: total_individual_payslips }
  end
end
