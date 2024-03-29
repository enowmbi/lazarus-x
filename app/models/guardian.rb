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

class Guardian < ApplicationRecord
  belongs_to :country
  belongs_to :ward, class_name: 'Student'
  belongs_to :user

  validates :first_name, :relation, :ward_id, presence: true
  validates :email, format: { with: /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i, allow_blank: true,
                              message: t('must_be_a_valid_email_address').to_s }
  before_destroy :immediate_contact_nil

  def validate
    errors.add(:dob, "#{I18n.t('cant_be_a_future_date')}.") if !dob.nil? && (dob > Time.zone.today)
  end

  def immediate_contact?
    ward.immediate_contact_id == id
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def archive_guardian(archived_student)
    guardian_attributes = attributes
    guardian_attributes.delete "id"
    guardian_attributes.delete "user_id"
    guardian_attributes["ward_id"] = archived_student
    if ArchivedGuardian.create(guardian_attributes)
      user.soft_delete if user.present?
      destroy
    end
  end

  def create_guardian_user(student)
    user = User.new do |u|
      u.first_name = first_name
      u.last_name = last_name
      u.username = "p#{student.admission_no}"
      u.password = "p#{student.admission_no}123"
      u.role = 'Parent'
      u.email = (email == '') || User.active.find_by(email: email) ? "" : email.to_s
    end
    update(user_id: user.id) if user.save
  end

  def self.shift_user(student)
    find_all_by_ward_id(student.id).each do |g|
      parent_user = g.user
      parent_user.soft_delete if parent_user.present? && (parent_user.is_deleted == false)
    end
    current_guardian = student.immediate_contact
    current_guardian.create_guardian_user(student) if current_guardian.present?
  end

  def immediate_contact_nil
    student = ward
    student.update(immediate_contact_id: nil) if student.present? && (student.immediate_contact_id == id)
  end
end
