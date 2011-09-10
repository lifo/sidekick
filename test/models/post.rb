class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :tags, :as => :taggable

  has_one :last_comment, :class_name => 'Comment'

  validates_presence_of :title, :content
end
