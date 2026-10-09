
class ApplicationController < ActionController::Base

  # 共通の計算処理を読み込む
  include PriceCalculations

  # 商品詳細ページを閲覧した際に商品IDを記録する
  before_action :store_recent_product

  # Deviseのストロングパラメータを設定する
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ログイン中のユーザーのカートを準備する
  before_action :prepare_cart, if: :user_signed_in?

  # ログイン後の遷移先を設定する
  def after_sign_in_path_for(resource)
    mypage_path(resource)
  end

  # ログアウト後の遷移先を設定する
  def after_sign_out_path_for(resource)
    session.delete(:cart_merged)
    root_path
  end

  protected

  # サインアップ時にnameとadmin_flgを許可する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:name, :admin_flg]
    )
  end

  private

  # 最近見た商品をセッションに保存する
  def store_recent_product

    # 商品詳細ページの場合のみ処理する
    if params[:controller] == 'products' && params[:action] == 'show'

      # 商品IDを整数に変換する
      product_id = params[:id].to_i

      # セッションを初期化する
      session[:recent_product_ids] ||= []

      # 重複する商品IDを削除する
      session[:recent_product_ids].delete(product_id)

      # 新しい商品IDを先頭に追加する
      session[:recent_product_ids].unshift(product_id)

      # 最近見た商品を最大5件まで保存する
      session[:recent_product_ids] = session[:recent_product_ids].take(5)

    end
  end

  # セッションのカート情報をDBのカートにマージする
  def prepare_cart

    # マージ済み、または管理者の場合は処理しない
    return if session[:cart_merged] || current_user.admin_flg?

    # ユーザーのカートを検索し、なければ新規作成する
    cart = Cart.find_or_create_by(user_id: current_user.id)

    # セッションにカートがなければ処理を終了する
    return if !session[:cart]

    # セッション内の商品を順番に処理する
    session[:cart].each do |item|

      # 同じ商品があれば取得し、なければ新規作成する
      cart_item = cart.cart_items.find_or_initialize_by(
        product_id: item["id"]
      )

      # 商品の数量を加算する
      cart_item.quantity += item["count"].to_i

      # カート情報をDBに保存する
      cart_item.save

    end

    # マージ後のセッションカートを削除する
    session.delete(:cart)

    # マージ済みフラグを設定する
    session[:cart_merged] = true

  end

end
