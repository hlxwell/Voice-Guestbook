class AddMediaFilenameToThreadPosts < ActiveRecord::Migration
  def self.up
    add_column :thread_posts, :media_filename, :string
  end

  def self.down
    remove_column :thread_posts, :media_filename
  end
end
