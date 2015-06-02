# initial migration for Credentials
class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :user, index: true, foreign_key: true, required: true
      t.text :public_key, required: true
      t.string :host, required: true
      t.string :username, required: true
      t.string :logon, required: true, index: true

      t.timestamps null: false
    end
  end
end
