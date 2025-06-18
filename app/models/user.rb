class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def under_stock_limit?
    # se pune user. de la sine
    stocks.count < 10
  end

  def stock_already_tracked?(ticker)
    stock = Stock.check_db(ticker)
    return false unless stock
    stocks.exists?(id: stock.id)
  end

  def can_track_stock?(ticker)
    under_stock_limit? && !stock_already_tracked?(ticker)
  end

  def full_name
    if first_name || last_name
      "#{first_name} #{last_name}"
    else
      "anonymus"
    end
  end

  def self.mathces(field_name, param)
    where("#{ field_name } like ?", "%#{ param }%")
  end

  def self.first_name_matches(param)
    mathces("first_name", param)
  end

  def self.last_name_matches(param)
    mathces("last_name", param)
  end

  def self.email_name_matches(param)
    mathces("email", param)
  end

  def self.search(param)
    param.strip!
    to_send_back = first_name_matches(param) + last_name_matches(param) + email_name_matches(param)
    return nil unless to_send_back
    to_send_back
  end

  def except_current_user(users)
    users.reject { |user| user.id == self.id }
  end

  def not_friends_with?(id_of_friend)
    !self.friends.where(id: id_of_friend).exists?
  end
end
