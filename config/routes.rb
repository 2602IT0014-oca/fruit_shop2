
Rails.application.routes.draw do

  # ==============================
  # ユーザー認証（ログイン・新規登録）
  # ==============================
  devise_for :users

  # ==============================
  # トップページ
  # ==============================
  root to: "homes#top"

  # ==============================
  # 商品管理
  # ==============================
  resources :products

  # ==============================
  # マイページ
  # ==============================
  get "mypage/show"
  resources :mypage, only: [:show]

  # ==============================
  # カート関連
  # ==============================
  resources :carts, only: [:show, :index] do

    # セッションカートに商品を追加する
    collection do
      post :add_product
    end

    # カート内の商品を削除・数量変更する
    member do
      delete :remove_item
      post :update_quantity
    end

  end

  # ==============================
  # 注文関連
  # ==============================
  resources :orders, only: [:index, :new, :create] do

    # 注文内容を確認する
    collection do
      post :confirm
    end

    # 注文完了画面を表示する
    member do
      get :complete
    end

  end

  # ==============================
  # Railsのヘルスチェック
  # ==============================
  get "up" => "rails/health#show",
      as: :rails_health_check
    # ユーザーのカート内の商品操作
  resources :cart_items, only: [:create, :update, :destroy]  

end
