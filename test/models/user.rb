class User < ActiveRecord::Base
  has_many :posts
  has_many :comments, :through => :posts

  # Polymorphic source
  has_many :tags, :through => :posts

  has_one :last_post, :class_name => 'Post'
  has_one :last_comment, :through => :last_post, :source => :last_comment

  # Just for skip_test.rb
  has_many :lol_posts, :class_name => 'Post', :finder_sql => 'select * from posts limit 2'
  has_many :recent_posts, :class_name => 'Post', :limit => 5
  has_many :ordered_posts, :class_name => 'Post', :order => 'posts.title DESC'
  has_many :hello_posts, :class_name => 'Post', :conditions => "posts.title = 'Hello'"

  has_many :unique_tags, :through => :posts, :source => :tags, :uniq => true

  validates_presence_of :name
end
