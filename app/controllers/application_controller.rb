class ApplicationController < ActionController::Base
  
end

class Integer
  # 割り切れるか
  def divisible?(number)
    self % number == 0
  end
  
  # form_select用の配列を返す
  def amount_select
    ret = []
    self.times do |amo|
      amo += 1
      ret <<
        if amo < 4
          ["#{amo} / 4", self - amo]
        elsif amo % 4 != 0
          ["#{amo / 4}と#{amo % 4} / 4 ", self - amo]
        else
          [(amo / 4).to_s, self - amo]
        end
    end
    ret
  end
  
  # グラム表記の食材のform_select用の配列を返す
  def gram_select
    ret = []
    (self / 200).times do |amo|
      amo += 1
      amo *= 200
      ret << [(amo / 4).to_s, self - amo]
    end
    ret
  end
end
