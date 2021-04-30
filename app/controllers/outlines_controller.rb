class OutlinesController < ApplicationController
  skip_before_action :authenticate_end_user!
  skip_before_action :check_untreated
  before_action :set_unconfirmed
  
  def show
  end

  def edit
    @outline = Outline.find_by(user: current_end_user.id)
  end

  def update
    Outline.find_by(user: current_end_user.id).update(outline_params)
    redirect_to user_menus_path
  end
  
  private
    def outline_params
      params.require(:outline).permit(:today)
    end
    
    def set_unconfirmed
      @unconfirmed = []
    end
end
