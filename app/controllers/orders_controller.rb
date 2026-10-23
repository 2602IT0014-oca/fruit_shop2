class OrdersController < ApplicationController
  before_action :authenticate_user! # ログイン必須（Deviseの場合）

  def new
    @order = Order.new
    # パラメータに product_id が存在しない場合は商品一覧へ安全に遷移させる
    if params[:product_id].present?
      @product = Product.find(params[:product_id])
    else
      redirect_to products_path, alert: "商品が選択されていません。"
    end
  end

  def index
    @orders = current_user.orders.order(created_at: :desc) # ユーザーに紐付いた注文履歴（新着順）
  end

  # 注文内容の確認画面
  def confirm
    @order = Order.new(order_params)
    @order.user = current_user

    if order_params[:product_id].present?
      @product = Product.find(order_params[:product_id])
      
      if @order.valid?
        @order.total_price = cal_total_price(@product.price, @order.count)
      else
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to products_path, alert: "商品情報が不足しています。"
    end
  end

  # 注文登録
  def create
    @order = Order.new(order_params)
    @order.user = current_user

    if @order.save
      redirect_to complete_order_path(@order), notice: "注文が完了しました。"
    else
      @product = Product.find_by(id: @order.product_id)
      render :new, status: :unprocessable_entity
    end
  end

  # 注文完了
  def complete
    @order = current_user.orders.find(params[:id]) # セキュリティのため current_user から検索
    @product = Product.find_by(id: @order.product_id)
  end

  private

  # 許可する注文パラメータの設定（ストロングパラメータ）
  def order_params
    params.require(:order).permit(:total_price, :address, :count, :product_id)
  end

  # 合計金額を計算
  def cal_total_price(price, count)
    return 0 if price.nil? || count.nil?
    price * count
  end
end