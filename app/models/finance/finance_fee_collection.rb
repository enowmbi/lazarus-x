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
  class FinanceFeeCollection < ApplicationRecord
    belongs_to :batch
    has_many :finance_fees, foreign_key: "fee_collection_id", dependent: :destroy
    has_many :finance_transactions, through: :finance_fees
    has_many :students, through: :finance_fees
    has_many :fee_collection_particulars, dependent: :destroy
    has_many :fee_collection_discounts, class_name: "Finance::FeeCollectionDiscount", dependent: :destroy
    belongs_to :fee_category, class_name: "FinanceFeeCategory"
    has_one :event, as: :origin

    validates :name, :start_date, :fee_category_id, :end_date, :due_date, presence: true

    after_create :create_associates

    def validate
      unless start_date.nil? || end_date.nil?
        errors.add_to_base(I18n.t('start_date_cant_be_after_end_date').to_s) if start_date > end_date
        errors.add_to_base(I18n.t('start_date_cant_be_after_due_date').to_s) if start_date > due_date
        errors.add_to_base(I18n.t('end_date_cant_be_after_due_date').to_s) if end_date > due_date
      end
    end

    def full_name
      "#{name} - #{start_date}"
    end

    def fee_transactions(student_id)
      FinanceFee.find_by(fee_collection_id: id, student_id: student_id)
    end

    def check_transaction(transactions)
      transactions.finance_fees_id.nil? ? false : true
    end

    def fee_table
      finance_fees.all(conditions: "is_paid = 0")
    end

    def self.shorten_string(string, count)
      if string.length >= count
        shortened = string[0, count]
        splitted = shortened.split(/\s/)
        words = splitted.length
        "#{splitted[0, words - 1].join(' ')} ..."
      else
        string
      end
    end

    def check_fee_category
      finance_fees = FinanceFee.find_all_by_fee_collection_id(id)
      flag = 1
      finance_fees.each do |f|
        flag = 0 unless f.transaction_id.nil?
      end
      flag == 1
    end

    def no_transaction_present
      f = FinanceFee.find_all_by_fee_collection_id(id)
      f&.reject! { |x| x.transaction_id.nil? }
      f.blank?
    end

    def create_associates
      batch_discounts = BatchFeeDiscount.find_all_by_finance_fee_category_id(fee_category_id)
      batch_discounts.each do |discount|
        discount_attributes = discount.attributes
        discount_attributes.delete "type"
        discount_attributes.delete "finance_fee_category_id"
        discount_attributes["finance_fee_collection_id"] = id
        BatchFeeCollectionDiscount.create(discount_attributes)
      end
      category_discount = StudentCategoryFeeDiscount.find_all_by_finance_fee_category_id(fee_category_id)
      category_discount.each do |discount|
        discount_attributes = discount.attributes
        discount_attributes.delete "type"
        discount_attributes.delete "finance_fee_category_id"
        discount_attributes["finance_fee_collection_id"] = id
        StudentCategoryFeeCollectionDiscount.create(discount_attributes)
      end
      student_discount = StudentFeeDiscount.find_all_by_finance_fee_category_id(fee_category_id)
      student_discount.each do |discount|
        discount_attributes = discount.attributes
        discount_attributes.delete "type"
        discount_attributes.delete "finance_fee_category_id"
        discount_attributes["finance_fee_collection_id"] = id
        StudentFeeCollectionDiscount.create(discount_attributes)
      end
      particlulars = FinanceFeeParticular.find_all_by_finance_fee_category_id(fee_category_id,
                                                                              conditions: "is_deleted=0")
      particlulars.each do |p|
        particlulars_attributes = p.attributes
        particlulars_attributes.delete "finance_fee_category_id"
        particlulars_attributes["finance_fee_collection_id"] = id
        FeeCollectionParticular.create(particlulars_attributes)
      end
    end

    def fees_particulars(student)
      #TODO: FeeCollectionParticular.find_all_by_finance_fee_collection_id(id, conditions: ["((student_category_id IS NULL AND admission_no IS NULL )OR(student_category_id = '#{student.student_category_id}'AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = '#{student.admission_no}')) and is_deleted=0"])
    end

    def transaction_total(start_date, end_date)
      trans = finance_transactions.all(conditions: "transaction_date >= '#{start_date}' AND transaction_date <= '#{end_date}'")
      total = trans.map(&:amount).sum
    end

    def student_fee_balance(student)
      particulars = fees_particulars(student)
      financefee = fee_transactions(student.id)

      if financefee.transaction_id.present?
        paid_fees = [] # TODO: paid_fees = FinanceTransaction.where("FIND_IN_SET(id,\"#{financefee.transaction_id}\")")
      end

      batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(id)
      student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(id,
                                                                                                             student.id)
      category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(
        id, student.student_category_id
      )
      total_discount = 0
      total_discount += batch_discounts.map(&:discount).sum unless batch_discounts.nil?
      total_discount += student_discounts.map(&:discount).sum unless student_discounts.nil?
      total_discount += category_discounts.map(&:discount).sum unless category_discounts.nil?
      total_discount = 100 if total_discount > 100

      total_fees = 0
      particulars&.map { |s| total_fees += s.amount.to_f }
      total_fees -= total_fees * (total_discount / 100)

      unless paid_fees.nil?
        paid = 0
        paid += paid_fees.collect { |x| x.amount.to_f }.sum
        total_fees -= paid
        trans = FinanceTransaction.find(financefee.transaction_id)
        total_fees += trans.fine_amount.to_f if !trans.nil? && trans.fine_included
      end
      total_fees
    end
  end
end
