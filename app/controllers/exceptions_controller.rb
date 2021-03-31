class ExceptionsController < ApplicationController
  def show
    set_rescue_variable(ERROR_MESSAGE[:unexpected])
    @url = '/end_users' if @url == nil || @url.match?(/exceptions$/)
  end
end
