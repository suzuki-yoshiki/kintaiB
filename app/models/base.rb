class Base < ApplicationRecord
  
  validates :base_name, presence: true, length: { maximum: 50 }
  validates :base_type, presence: true, length: { maximum: 50 }
  validates :base_number, presence: true, uniqueness: true
end