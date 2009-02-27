class BlockagesHaveDescriptions < ActiveRecord::Migration
  def self.up
    change_table :blockages do |t|
      t.text :description
    end
  end

  def self.down
    change_table :blockages do |t|
      t.remove :description
    end
  end
end
