class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.belongs_to :account
      t.string :type
      t.timestamps
    end
    add_index :companies, :account_id
    
    change_table :accounts do |t|
      t.belongs_to :agency
    end
  end

  def self.down
    remove_column :accounts, :agency_id
    drop_table :companies
  end
end
