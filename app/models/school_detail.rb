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
class SchoolDetail < ApplicationRecord
  has_one_attached :logo do |attached_logo|
    attached_logo.variant(:original, resize_to_limit: [150, 110])
  end

  validate :image_type_and_size

  private

  def acceptable_image
    return unless logo.attached?

    errors.add(:logo, "must be less than 500 KB") unless logo.byte_size < 500.kilobytes

    valid_image_types = ['image/gif', 'image/png', 'image/jpeg', 'image/jpg'].freeze
    errors.add(:logo, "can on ly be GIF, PNG or  JPG") unless valid_image_types.include(logo.content_type)
  end
end
