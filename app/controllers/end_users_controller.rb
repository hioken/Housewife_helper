class EndUsersController < ApplicationController
  before_action :authenticate_end_user!
  def show
  end
  
  def update
    current_user.update(end_user_params)
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:famiry_size, :cooking_time_limit)
    end
end
