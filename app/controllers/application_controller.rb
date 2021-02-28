class ApplicationController < ActionController::Base
  before_action :authenticate_end_user!
  
end

class Integer
  # 割り切れるか
  def divisible?(number)
    self % number == 0
  end
  
  #amountのユーザー向け表記を返す
  def regular_amount(unit)
    if unit == 'g'
      self / 4
    else
      result = self.divmod(4)
      if result[1] == 0
        result[0]
      elsif result[1] == 2
        result[0] > 0 ? "#{result[0]}と1/2" : '1/2'
      else
        result[0] > 0 ? "#{result[0]}と#{result[1]}/4" : "#{result[1]}/4"
      end
    end
  end
  
  # form_select用の配列を返す
  def amount_select(unit)
    ret = []
    if unit != 'g'
      self.times do |amo|
        amo += 1
        ret <<
          if amo < 4
            ["#{amo} / 4" + unit, self - amo]
          elsif amo % 4 != 0
            ["#{amo / 4}と#{amo % 4} / 4 #{unit}", self - amo]
          else
            [(amo / 4).to_s + unit, self - amo]
          end
      end
    else
      (self / 200).times do |amo|
        amo += 1
        amo *= 200
        ret << [(amo / 4).to_s + unit, self - amo]
      end
      ret << ["#{(self / 4)}g", 0] if self / 200 == 0
    end
    ret
  end
end