class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.timestamps
    end
    add_index :accounts, :subdomain, :unique => true
    
    change_table :users do |t|
      t.belongs_to :account
      t.boolean :admin, :defult => false
    end
  end

  def self.down
    remove_column :users, :account_id
    remove_column :users, :admin
    
    remove_index :accounts, :subdomain
    drop_table :accounts
  end
end
