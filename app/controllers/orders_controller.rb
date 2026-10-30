class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_items, only: [:new, :create]
  before_action :ensure_cart_not_empty, only: [:new, :create]

  # 注文入力画面
  def new
    @order = Order.new
    build_order_details_from_cart(@order)
    calculate_order_totals
  end

  # 注文履歴
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  # 注文内容の確認画面
  def confirm
    @order = current_user.orders.build(order_params)
    @cart_items = current_user.cart.cart_items.includes(:product)

    if @cart_items.empty?
      redirect_to products_path, alert: "カートに商品がありません。"
      return
    end

    # カート内のアイテムを取得し、order_details を build
    @order_details = @cart_items.map do |item|
      @order.order_details.build(
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    calculate_order_totals

    unless @order.valid?
      render :new, status: :unprocessable_entity
    end
  end

  # 注文登録
  def create
    @order = current_user.orders.build(order_params)
    build_order_details_from_cart(@order)
    calculate_order_totals

    ActiveRecord::Base.transaction do
      @order.save!
      current_user.cart.cart_items.destroy_all
    end

    redirect_to complete_order_path(@order), notice: "注文が完了しました。"

  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  # 注文完了
  def complete
    @order = current_user.orders.find(params[:id])
    @order_details = @order.order_details.includes(:product)
  end

  private

  # ストロングパラメータ
  def order_params
    params.require(:order).permit(:address)
  end

  def set_cart_items
    @cart_items = current_user.cart.cart_items.includes(:product)
  end

  def ensure_cart_not_empty
    if @cart_items.empty?
      redirect_to products_path, alert: "カートに商品がありません。"
    end
  end

  # カートの商品情報から order_details を構築
  def build_order_details_from_cart(order)
    @order_details = @cart_items.map do |item|
      order.order_details.build(
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.product.price
      )
    end
  end

  # 合計金額の計算
  def calculate_order_totals
    item_totals = @order.order_details.map do |detail|
      calculate_item_total(detail.price, detail.quantity)
    end
    @order.total_price = calculate_total_sum(item_totals)
  end

  def calculate_item_total(price, quantity)
    price * quantity
  end

  def calculate_total_sum(item_totals)
    item_totals.sum
  end
end