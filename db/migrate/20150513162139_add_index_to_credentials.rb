# Adds indexes to credentials
# removes 'logon' column no longer needed
class AddIndexToCredentials < ActiveRecord::Migration
  def up
    add_index :credentials, :username
    add_index :credentials, [:username, :host]
    remove_index :credentials, :logon if index_exists?(:credentials, :logon)
    remove_column :credentials, :logon
  end

  def down
    remove_index :credentials, :username if index_exists?(:credentials, :username)
    remove_index :credentials, [:username, :host] if index_exists?(:credentials, [:username, :host])
    add_column :credentials, :logon, :string
    add_index :credentials, :logon
    Credential.reset_column_information
    Credential.all.each(&:save!)
  end
end
