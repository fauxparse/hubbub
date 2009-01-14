class CompanySlugs < ActiveRecord::Migration
  def self.up
    change_table :companies do |t|
      t.string :slug
    end
  end

  def self.down
    remove_column :companies, :slug
  end
end
