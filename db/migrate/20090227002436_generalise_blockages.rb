class GeneraliseBlockages < ActiveRecord::Migration
  def self.up
    create_table "blockages", :force => true do |t|
      t.belongs_to :task
      t.belongs_to :user
      t.belongs_to :blocker
      t.text       :description
      t.timestamps
    end
    
    change_table :assignments do |t|
      t.remove :blockages_count
    end

    change_table :tasks do |t|
      t.integer :blockages_count
    end
  end

  def self.down
    create_table "blockages", :force => true do |t|
      t.integer  "user_id"
      t.integer  "blocker_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "assignment_id"
      t.text     "description"
    end

    change_table :tasks do |t|
      t.remove :blockages_count
    end
  end
end
