# registerable Host class
class Host < ActiveRecord::Base
  acts_as_taggable
  validates :fqdn, presence: true, format: { without: /[A-Z]/ }
  alias_attribute :registered_at, :created_at
  alias_attribute :touched_at, :updated_at
end
