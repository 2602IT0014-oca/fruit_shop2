module PriceCalculations
# 追加
  # セッションのカートの合計金額を計算
  def cart_calculation
    session[:cart].each do |item|
      product = Product.find(item["id"].to_i)
      item["price"] = product.price
      item["item_price"] = calculate_item_total(item["price"], item["count"])
    end
    session[:cart_total] = calculate_total_sum(session[:cart].map { |item| item["item_price"] })
  end
# ここまで
end