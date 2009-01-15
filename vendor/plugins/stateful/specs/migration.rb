class CreateSpecModels < ActiveRecord::Migration
  def self.up

    create_table :event_testers do |t|
      t.string     :stateful_state, :null => false
      t.timestamps
    end

    create_table :posts do |t|
      t.string     :name
      t.text       :content
      t.references :author
      t.string     :lifecycle_state, :null => false
      t.datetime   :deleted_at
      t.timestamps
    end

    create_table :spec_models do |t|
      t.string   :type
      t.string   :name
      t.string   :stateful_state
      t.datetime :deleted_at
      t.timestamps
    end

  end

  def self.down
    drop_table :posts, :force => true
    drop_table :spec_models, :force => true
    drop_table :event_testers, :force => true
  end
end
