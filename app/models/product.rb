class Product < ApplicationRecord
  # アソシエーション
  has_many :cart_items, dependent: :destroy
  has_many :order_details, dependent: :destroy
  has_many :orders, through: :order_details

  # Active Storage（商品画像）
  has_one_attached :photo

  # バリデーション
  validates :name, presence: true
  validates :price, presence: true

  # サムネイル画像の生成ヘルパー
  def thumbnail
    photo.variant(resize_to_limit: [150, 150]).processed
  end
end