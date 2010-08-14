class CreateThreadPosts < ActiveRecord::Migration
  def self.up
    create_table :thread_posts do |t|
      t.string :title
      t.text :content
      t.string :voice_file_path
      t.integer :user_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :thread_posts
  end
end
