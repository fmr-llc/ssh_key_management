# local instance variable @ldap_entry holds all the LDAP attributes
module UserLDAP

  LDAP_EXTRA = YAML.load_file Rails.root.join 'config', 'ldap_extra.yml'
  LDAP_EXTRA['alias_attributes'].each { |attr| alias_attribute *attr.map(&:intern) }

  attr_accessor *LDAP_EXTRA['attributes']

  # loop to set all instance vars for LDAP attributes
  LDAP_EXTRA['attributes'].each do |attr|
    define_method attr do
      return instance_variable_get "@#{attr}" if instance_variable_get "@#{attr}"
      values = ldap_entry[attr] if ldap_entry
      (values.size == 1 ? values.first.to_s : values.map(&:to_s)) if values
    end
  end

  def to_s
    dn
  end

  # memoize the user's LDAP info
  def ldap_entry
    @ldap_entry ||= Devise::LDAP::Adapter.get_ldap_entry login
  end

  def reload
    super
    LDAP_EXTRA['attributes'].each {|attr| instance_variable_set("@#{attr}", nil) }
    ldap_entry
    nil
  end
end
