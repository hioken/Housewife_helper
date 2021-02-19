class ApplicationController < ActionController::Base
end

class Integer
  def regam
    self.divmod(4)
  end
end