class User < ActiveRecord::Base
  attr_accessible :password_confirmation, :avatar, :password, :login, :email, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at
  acts_as_authentic
  has_attached_file :avatar, :styles => { :thumb => "40x40#", :mini => "10x10#" }
end