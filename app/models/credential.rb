require 'sshkey'
# SSH Credential class
class Credential < ActiveRecord::Base
  acts_as_taggable

  EXPIRED_AGE = 365
  EXPIRING_AGE = 305

  belongs_to :user
  before_validation :normalize_data

  validates :public_key, :user, :username, presence: true
  validates :username, format: /\A[a-z0-9_]+\z/
  validate :public_key_rfc4716, if: :public_key?
  validate :resolv_host, unless: :default_key?
  validates :host, format: { without: /[A-Z]/ } unless :default_key?

  def self.public_keys_for(username, host = nil)
    Credential.where(username: username, host: [host, nil]).pluck('DISTINCT public_key')
  end

  def self.key_info?(key)
    info = { valid: key_valid?(key) }
    info.merge!(bits: key_bits(key), fingerprint: key_fingerprint(key)) if info[:valid]
    info
  end

  def default_key?
    !host?
  end

  def host
    host? ? self[:host] : I18n.t('activerecord.values.credential.host.blank')
  end

  def self.key_valid?(key)
    SSHKey.valid_ssh_public_key? key
  end

  def expire_at
    created_at + EXPIRED_AGE.days
  end

  def expired?
    created_at < EXPIRED_AGE.days.ago
  end

  def expiring?
    (created_at < EXPIRING_AGE.days.ago) && !expired?
  end

  def nonexpired?
    !expired?
  end

  def logon
    "#{username}@#{host}"
  end

  def status
    if expired?
      'Expired'
    elsif expiring?
      'Expiring'
    else
      'Valid'
    end
  end

  def expiration_percentage(time = Time.zone.now)
    if expired?
      100
    else
      ((time - created_at) / (expire_at - created_at) * 100).round
    end
  end

  def copy_text_attr
    :public_key
  end

  private

  def normalize_data
    self[:host] = nil if host.eql? I18n.t('activerecord.values.credential.host.blank')
    self[:host] = host.to_s.downcase unless default_key?
    self[:username] = username.to_s.downcase
    self[:public_key] = public_key
                        .to_s
                        .encode('ASCII', invalid: :replace, undef: :replace, replace: '')
                        .strip
                        .gsub(/(\n|\r)/, '')
  end

  def self.key_bits(key)
    SSHKey.ssh_public_key_bits(key) if self.key_valid?(key)
  end

  def self.key_fingerprint(key)
    SSHKey.md5_fingerprint(key) if self.key_valid?(key)
  end

  def public_key_rfc4716
    errors.add(:public_key, 'is not valid') unless self.class.key_valid?(public_key)
  end

  def resolv_host
    errors.add(:host, 'does not resolve') unless resolv? host
  end

  def resolv?(hostname)
    true if Resolv.getaddress hostname
  rescue Resolv::ResolvError
    false
  end
end
