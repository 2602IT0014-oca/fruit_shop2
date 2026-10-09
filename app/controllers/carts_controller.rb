
class CartsController < ApplicationController

  # ログインユーザーのカートを表示する
  def show
    # 現在のユーザーのカートをDBから取得する
    @cart = Cart.find_by(user_id: current_user.id)

    # ユーザーのカートの合計金額を計算する
    user_cart_calculation
  end

  # セッションカートの一覧を表示する
  def index
    # セッションからカートの情報を取得する
    if session[:cart].present?

      # カート内の商品IDを配列にする
      product_ids = session[:cart].map { |item| item["id"] }

      # 商品IDを使ってDBから商品情報を取得する
      @products = Product.where(id: product_ids).index_by(&:id)
    end
  end

  # カートに商品を追加する
  def add_product

    # カートがなければ空の配列を作成する
    session[:cart] ||= []

    # 商品IDから商品情報を取得する
    product = Product.find(cart_params[:product_id])
    count = cart_params[:count].to_i

    # カートに同じ商品がない場合
    if session[:cart].none? { |item| item["id"] == product.id }

      # 新しい商品をカートに追加する
      session[:cart] << { "id" => product.id, "count" => count }

    else
      # 同じ商品がある場合は数量を追加する
      item = session[:cart].find { |item| item["id"] == product.id }
      item["count"] += count if item
    end

    # カートの合計金額を計算する
    cart_calculation

    # カート一覧画面に移動する
    redirect_to carts_path, notice: '商品がカートに追加されました。'
  end

  # カート内の商品の数量を変更する
  def update_quantity

    # 商品IDと変更後の数量を取得する
    product_id = params[:id].to_i
    reduce_count = params[:count].to_i

    # カート内の商品を検索する
    item = session[:cart].find { |item| item["id"] == product_id }

    if item
      # 商品の数量を変更する
      item["count"] = reduce_count

      # 数量が0以下の場合は商品を削除する
      session[:cart].delete(item) if item["count"] <= 0
    end

    # カートの合計金額を再計算する
    cart_calculation

    # カート一覧画面に移動する
    redirect_to carts_path, notice: '商品がカートから削除されました。'
  end

  # カートから商品を削除する
  def remove_item

    # 商品IDを取得する
    product_id = params[:id].to_i

    # 指定した商品をカートから削除する
    session[:cart].delete_if { |item| item["id"] == product_id }

    # カートの合計金額を再計算する
    cart_calculation

    # カート一覧画面に移動する
    redirect_to carts_path, notice: '商品がカートから削除されました。'
  end

  private

  # カートに必要なパラメータを許可する
  def cart_params
    params.permit(:product_id, :count)
  end

end
