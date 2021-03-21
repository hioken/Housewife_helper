class OutlinesController < ApplicationController
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
end
