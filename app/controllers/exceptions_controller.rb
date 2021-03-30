class ExceptionsController < ApplicationController
  def show
    set_rescue_variable(ERROR_MESSAGE[:unexpected])
    # 正規表現で訂正
    
    @url = '/end_users' if @url == nil || @url == '/exceptions'
  end
end
