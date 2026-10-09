class Cart < ApplicationRecord
  belongs_to :user
  # 追加
  has_many :cart_items
  # ここまで
  validates :user_id, uniqueness: true # 追加
end
