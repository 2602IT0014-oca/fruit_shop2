class HomesController < ApplicationController
  def top
    # 全商品の情報を取得してビューに渡す
  @products = Product.all #追加
  end
end
