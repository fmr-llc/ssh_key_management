require 'user_ldap'
# Devise based User model that pulls info from LDAP based on UID attribute
class User < ActiveRecord::Base
  devise :ldap_authenticatable, :rememberable, :trackable, :timeoutable

  include UserLDAP
  has_many :credentials
  validates :login, presence: true

  # helper method to return user's full name
  def full_name
    "#{first_name} #{last_name}"
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.strip.downcase) if email
  end
end
