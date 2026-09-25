class Cart < ApplicationRecord
  belongs_to :user
  # 追加
  has_many :cart_items
  # ここまで
end
