#  migration file for registered hosts
class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :fqdn

      t.timestamps null: false
    end
  end
end
