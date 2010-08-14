class AddParentIdToThreadPosts < ActiveRecord::Migration
  def self.up
    add_column :thread_posts, :parent_id, :integer
  end

  def self.down
    remove_column :thread_posts, :parent_id
  end
end
