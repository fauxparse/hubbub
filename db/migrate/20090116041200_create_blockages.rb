class CreateBlockages < ActiveRecord::Migration
  def self.up
    create_table :blockages do |t|
      t.belongs_to :user
      t.belongs_to :assignment
      t.belongs_to :blocker
      t.timestamps
    end
  end

  def self.down
    drop_table :blockages
  end
end
