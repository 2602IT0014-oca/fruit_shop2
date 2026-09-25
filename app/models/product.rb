class Product < ApplicationRecord
  has_many :orders
  validates :name, presence: true   # 商品名は必須で一意
    validates :price, presence: true  # 価格は必須

    # 追加　ここから

    # Active Storage（商品画像）
    has_one_attached :photo

    # 商品画像のサムネイルを生成
    def thumbnail
      photo.variant(resize_to_limit: [150, 150]).processed  # 画像を 150x150 ピクセル以内にリサイズ
    end
      has_many :cart_items
    # 追加　ここまで
end