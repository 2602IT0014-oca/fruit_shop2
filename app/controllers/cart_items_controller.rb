class CartItemsController < ApplicationController
    def create
    # ユーザーのカートを取得
    cart = current_user.cart
    
    # カートに同じ商品があるか確認
    cart_item = cart.cart_items.find_by(product_id: cart_item_params[:product_id])
    if cart_item
      # 同じ商品がある場合は数量を更新
      cart_item.quantity += cart_item_params[:quantity].to_i
    else
      # 同じ商品がない場合は新しいカートアイテムを作成
      cart_item = cart.cart_items.new(cart_item_params)
    end

    if cart_item.save
        user_cart_calculation  # ユーザのカート合計金額を再計算
        redirect_to cart_path(current_user.cart), notice: '商品がカートに追加されました。'
    else
        redirect_to products_path, notice: '商品をカートに追加できませんでした。'
    end
  end
  
  def update
    # カート内の商品数量を更新するアクション
    cart_item = CartItem.find(params[:id])
    if cart_item.update(cart_item_params)
      user_cart_calculation  # ユーザのカート合計金額を再計算
      redirect_to cart_path(current_user.cart), notice: '商品数量が更新されました。'
    else
      redirect_to cart_path(current_user.cart), notice: '商品数量の更新に失敗しました。'
    end
  end

  def destroy
    # カート内の商品を削除するアクション
    cart_item = CartItem.find(params[:id])
    if cart_item.destroy
      user_cart_calculation # ユーザのカート合計金額を再計算
      redirect_to cart_path(current_user.cart), notice: '商品がカートから削除されました。'
    else
      redirect_to cart_path(current_user.cart), notice: '商品をカートから削除できませんでした。'
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity)
  end
end
end
