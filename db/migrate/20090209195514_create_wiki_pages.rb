class CreateWikiPages < ActiveRecord::Migration
  def self.up
    create_table :wiki_pages do |t|
      t.belongs_to :company
      t.string     :title
      t.text       :body
      t.belongs_to :author
      t.timestamps
    end
  end

  def self.down
    drop_table :wiki_pages
  end
end
