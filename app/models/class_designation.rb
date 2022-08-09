#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
class ClassDesignation < ApplicationRecord
  belongs_to :course

  validates :name, presence: true
  validates :cgpa, numericality: true, if: :gpa?
  validates :marks, numericality: true, if: :cwa?

  def gpa?
    course.gpa_enabled?
  end

  def cwa?
    course.cwa_enabled? || course.normal_enabled?
  end

  HUMANIZED_COLUMNS = { cgpa: "CGPA" }.freeze

  def self.human_attribute_name(attribute)
    HUMANIZED_COLUMNS[attribute.to_sym] || super
  end
end
