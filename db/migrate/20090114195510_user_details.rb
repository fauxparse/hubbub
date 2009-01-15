class UserDetails < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :name
      t.string :display_name
      t.string :email
      t.string :phone
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :name
      t.remove :display_name
      t.remove :email
      t.remove :phone
    end
  end
end
