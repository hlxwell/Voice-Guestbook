class ThreadPost < ActiveRecord::Base
  attr_accessible :title, :content, :voice_file_path, :user_id, :parent_id, :media_filename, :all_tags

  scope :parent_post, where(:parent_id => nil)
  scope :recent, where(:parent_id => nil).order("updated_at desc")
  scope :by_date_desc, :order => "updated_at DESC"

  belongs_to :user
  belongs_to :parent, :class_name => "ThreadPost"
  has_many :children, :class_name => "ThreadPost", :foreign_key => "parent_id", :dependent => :destroy

  validates_presence_of :title, :if => Proc.new {|p| p.parent_id.blank? }
  validates_presence_of :user_id

  acts_as_taggable

  def ThreadPost.after_create
    self.parent.touch(:updated_at) if self.parent_id.present?
  end

  def all_tags
    self.tag_list.join(",")
  end

  def all_tags=(list)
    self.tag_list = list
  end
end