class ExceptionsController < ApplicationController
  def show
    @exception_message = ERROR_MESSAGE[:unexpected]
  end
end
