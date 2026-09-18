class ApplicationController < ActionController::Base
  # Deviseのコントローラ実行時にストロングパラメータを設定
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ログイン後の遷移先を設定
  def after_sign_in_path_for(resource)
    mypage_path(resource)
  end

  # ログアウト後の遷移先を設定
  def after_sign_out_path_for(resource)
    root_path
  end

  protected

  # サインアップ時に name と admin_flg を許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :admin_flg])
  end
end