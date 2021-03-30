class ApplicationController < ActionController::Base
  before_action :authenticate_end_user!
  before_action :time_set
  before_action :check_untreated
  
  # 定数
  RETRY_COUNT = 3
  
  # methods
  def after_sign_in_path_for(resource)
    if (date = Outline.find_by(user: current_end_user.id))
      date.destroy 
    end
    Outline.create(user: current_end_user.id, today: Date.today)
    time_set
    end_users_path
  end
  
  def time_set
    if end_user_signed_in?
      date = Outline.find_by(user: current_end_user.id)
      @set_today = (date ? date.today : Date.today)
    end
  end
  
  def check_untreated
    if end_user_signed_in?
      @unconfirmed = current_end_user.user_menus.eager_load(:recipe).where("is_cooked = ? AND cooking_date < ?", false, @set_today)
    else
      @unconfirmed = []
    end
  end
  
  def set_rescue_variable(message)
    @message = message
    @url = request.referrer
  end
end

# 例外処理用メソッド
module LogSecretary
  def exception_log
    text = "\n"
    text << "\tError:    #{self.class}\n"
    text << "\tMassage:  #{self.message}\n"
    text << "\tBacktrace:\n"
    cnt = 0
    self.backtrace.each do |trace|
      text << "\t\t" + trace + "\n"
      cnt += 1
      if cnt > 20
        cnt = 'over 20'
        break
      end
    end
    text << "\t\t......\n"
    text << "\ttrace_count: #{cnt.to_s}\n"
    Rails.application.config.exception_logger.info(text)
  end
end

module ActiveRecord
  include LogSecretary
end

class Exception
  include LogSecretary
end


# ruby組み込みclassに追加するメソッド
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

