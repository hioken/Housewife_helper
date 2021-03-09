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
    if unit == 'option' || unit == '合'
      ''
    elsif unit == 'g'
      (self / 4).to_s
    else
      result = self.divmod(4)
      if result[1] == 0
        result[0].to_s
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

class Hash
  def subtract!(rob, all_key_string: false)
    if all_key_string
      h_2 = self.map { |k, v| [k.to_s, v] }.to_h
      self.delete_if { |k, v| k.class != String }
      self.merge!(h_2)
      rob.each { |k, v| self[k.to_s] = self[k.to_s].to_i - v }
    else
      rob.each { |k, v| self[k] = self[k].to_i - v }
    end
  end
end