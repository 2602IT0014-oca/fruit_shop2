class ApplicationController < ActionController::Base
  # 各アクションの前に実行される。
  # 商品詳細ページ（products#show）を見た場合のみ、セッションに商品IDを記録する
  before_action :store_recent_product
  # ユーザがログインしている場合、セッションのカート情報をDBのカートにマージする
  before_action :prepare_cart, if: :user_signed_in? # 追加

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
  # 最近見た商品をセッションに保存するメソッド
  def store_recent_product
    # 今見ているページが products コントローラーの show アクション（＝商品詳細ページ）のときだけ処理
    if params[:controller] == 'products' && params[:action] == 'show'
      product_id = params[:id].to_i  # パラメータから商品IDを取得（文字列→整数に変換）
      session[:recent_product_ids] ||= []  # セッションに recent_product_ids がなければ空配列で初期化
      session[:recent_product_ids].delete(product_id)  # 重複を防ぐために、すでにあるIDを削除
      session[:recent_product_ids].unshift(product_id) # 商品IDを配列の先頭に追加（新しい順に並べる）
      session[:recent_product_ids] = session[:recent_product_ids].take(5)  # 配列の先頭5件だけを残す（＝最大5件まで表示）
    end

  end
# セッションのカート情報をユーザごとのDBカートにマージするメソッド
  def prepare_cart
     # セッションにカートがマージ済みであるか、または管理者ユーザの場合は何もしない
    return if session[:cart_merged] || current_user.admin_flg?
    # find_or_create_byは、指定した条件でレコードを検索し、存在しなければDBに新規作成するメソッド
    cart = Cart.find_or_create_by(user_id: current_user.id)
    return if !session[:cart]  # セッションのカートが空なら何もしない
    session[:cart].each do |item|
    # カート内に同じ商品がある場合は数量を更新ない場合は新規作成
      cart_item = cart.cart_items.find_or_initialize_by(product_id: item["id"])
      cart_item.quantity += item["count"].to_i # 数量を加算
      cart_item.save
    end
    session.delete(:cart)
    session[:cart_merged] = true  # セッションにマージ済みフラグを設定
  end
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
