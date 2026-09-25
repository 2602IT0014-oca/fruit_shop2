module PriceCalculations

  # 小計（個々）
  def calculate_item_total(price, count)
    price * count
  end

  # 合計金額（全体用）
  def calculate_total_sum(items)
    items.sum
  end
end