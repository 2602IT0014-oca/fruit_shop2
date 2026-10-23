class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :address, presence: true
end