
# app/controllers/concerns/price_calculations.rb

module PriceCalculations

  # 商品ごとの小計を計算する
  def calculate_item_total(price, count)
    price * count
  end

  # 全商品の合計金額を計算する
  def calculate_total_sum(items)
    items.sum
  end

  # セッションカートの合計金額を計算する
  def cart_calculation
    session[:cart].each do |item|

      # 商品情報を取得する
      product = Product.find(item["id"].to_i)

      # 商品の価格を保存する
      item["price"] = product.price

      # 商品ごとの小計を計算する
      item["item_price"] = calculate_item_total(
        item["price"], item["count"]
      )
    end

    # カート全体の合計金額を計算する
    session[:cart_total] = calculate_total_sum(
      session[:cart].map { |item| item["item_price"] }
    )
  end

  # ログインユーザーのカート合計金額を再計算する
  def user_cart_calculation

    # 現在のユーザーのカートを取得する
    cart = Cart.find_by(user_id: current_user.id)

    # 商品ごとの小計を計算する
    @item_totals = cart.cart_items.map do |item|
      calculate_item_total(item.product.price, item.quantity)
    end

    # カート全体の合計金額を計算する
    @cart_total = calculate_total_sum(@item_totals)

  end

end
