# Devise based User model that pulls info from LDAP based on UID attribute
class User < ActiveRecord::Base
  devise :ldap_authenticatable, :rememberable, :trackable, :timeoutable
  attr_accessor :givenname, :sn, :mail
  after_initialize :init_ldap

  has_many :credentials
  validates :login, presence: true

  # Sugary sweet aliases
  alias_attribute :username, :login
  alias_attribute :first_name, :givenname
  alias_attribute :last_name, :sn
  alias_attribute :email, :mail

  def to_s
    dn
  end

  # helper method to return user's full name
  def full_name
    "#{first_name} #{last_name}"
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.strip.downcase) if email
  end

  def reload
    super && ldap_entry
    nil
  end

  private

  # memoize the user's LDAP info
  def ldap_entry
    @ldap_entry ||= Devise::LDAP::Adapter.get_ldap_entry login
  end

  def init_ldap
    ldap_entry.attribute_names.each do |attr|
      create_ldap_method_getter attr
      create_ldap_method_setter attr
    end if ldap_entry
  end

  def create_ldap_getter(method)
    self.class.send :define_method, method do
      return instance_variable_get "@#{method}" if instance_variable_get "@#{method}"
      values = ldap_entry[method] if ldap_entry
      (values.size == 1 ? values.first.to_s : values.map(&:to_s)) if values
    end
  end

  def create_ldap_method_setter(method)
    self.class.send(:define_method, "#{method}=") { |value| instance_variable_set "@#{method}", value }
  end
end
