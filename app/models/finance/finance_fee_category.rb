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

module Finance
  class FinanceFeeCategory < ApplicationRecord
    belongs_to :batch
    belongs_to :student

    has_many   :fee_particulars, class_name: "FinanceFeeParticular"
    has_many   :fee_collections, class_name: "Finance::FinanceFeeCollection"
    has_many   :fee_discounts

    cattr_reader :per_page

    @per_page = 10

    validates :batch_id, presence: { message: I18n.t('not_specified').to_s }
    validates :name, presence: true, uniqueness: { scope: %I[batch_id is_deleted] }, if: :not_deleted?

    def not_deleted?
      is_deleted == false
    end

    def fees(student)
      FinanceFeeParticular.find_all_by_finance_fee_category_id(id,
                                                               conditions: ["((student_category_id IS NULL AND admission_no IS NULL )OR(student_category_id = '#{student.student_category_id}'AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = '#{student.admission_no}')) and is_deleted=0"])
    end

    def check_fee_collection
      fee_collection = FinanceFeeCollection.find_all_by_fee_category_id(id, conditions: { is_deleted: 0 })
      fee_collection.empty? ? true : false
    end

    def check_fee_collection_for_additional_fees
      flag = 0
      fee_collection = FinanceFeeCollection.find_all_by_fee_category_id(id)
      fee_collection.each do |fee|
        flag = 1 if fee.check_fee_category == true
      end
      flag == 1
    end

    def delete_particulars
      fee_particulars.each do |fees|
        fees.update(is_deleted: true)
      end
    end

    def student_fee_balance(student, date)
      particulars = FinanceFeeParticular.find_all_by_finance_fee_category_id(id,
                                                                             conditions: ["((student_category_id IS NULL AND admission_no IS NULL )OR(student_category_id = '#{student.student_category_id}'AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = '#{student.admission_no}')) and is_deleted=0"])
      financefee = student.finance_fee_by_date(date)

      if financefee.transaction_id.present?
        paid_fees = FinanceTransaction.find(:all,
                                            conditions: "FIND_IN_SET(id,\"#{financefee.transaction_id}\")")
      end

      batch_discounts = BatchFeeDiscount.find_all_by_finance_fee_category_id(id)
      student_discounts = StudentFeeDiscount.find_all_by_finance_fee_category_id_and_receiver_id(id, student.id)
      category_discounts = StudentCategoryFeeDiscount.find_all_by_finance_fee_category_id(id,
                                                                                          joins: 'INNER JOIN students ON fee_discounts.receiver_id = students.student_category_id')
      total_discount = 0
      total_discount += batch_discounts.map(&:discount).sum unless batch_discounts.nil?
      total_discount += student_discounts.map(&:discount).sum unless student_discounts.nil?
      total_discount += category_discounts.map(&:discount).sum unless category_discounts.nil?
      total_discount = 100 if total_discount > 100

      total_fees = 0
      unless particulars.nil?
        total_fees += particulars.collect { |x| x.amount.to_f }.sum
        total_fees = (total_fees - ((total_fees * total_discount) / 100))

        unless paid_fees.nil?
          paid = 0
          paid += paid_fees.collect { |x| x.amount.to_f }.sum
          total_fees -= paid
          trans = FinanceTransaction.find(financefee.transaction_id)
          total_fees += trans.fine_amount.to_f if !trans.nil? && trans.fine_included
        end
      end
      total_fees
    end

    def self.common_active
      find(:all,
           conditions: ["finance_fee_categories.is_master = '1' and finance_fee_categories.is_deleted = 'false'"], joins: "INNER JOIN batches on finance_fee_categories.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0 ", group: :name)
    end

    def is_collection_open
      collection = FinanceFeeCollection.find_all_by_fee_category_id(id,
                                                                    conditions: "start_date < '#{Date.today.to_date}' and due_date > '#{Date.today.to_date}'")
      collection&.reject! { |c| c.no_transaction_present }
      collection.present?
    end

    def have_common_particular?
      fee_particulars.find_all_by_student_category_id_and_admission_no(nil, nil).count.positive? ? true : false
    end
  end
end
