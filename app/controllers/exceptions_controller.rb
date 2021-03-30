class ExceptionsController < ApplicationController
  def show
    set_rescue_variable("予期せぬエラーが発生しました。\n早急に原因を調査して修正致します。\nご迷惑をおかけして申し訳ございません。")
  end
end
