class DirectoryInfo < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string  :extension, :length => 24
      t.string  :mobile, :length => 24
      t.string  :avatar_file_name
      t.string  :avatar_content_type
      t.integer :avatar_file_size
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :extension
      t.remove :mobile
      t.remove :avatar_file_name
      t.remove :avatar_content_type
      t.remove :avatar_file_size
    end
  end
end
