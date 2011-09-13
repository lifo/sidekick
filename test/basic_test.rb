require 'test_helper'

class BasicTest < ActiveRecord::TestCase
  def test_has_many
    # user = User.preload(:posts).all
    # puts user.detect {|u| u.name == 'Lifo' }.inspect
    # puts user.detect {|u| u.name == 'Lifo' }.posts.inspect
    assert_queries(3) do
      # Query 1
      users = User.all

      # Query 2 - Load all the posts
      lifo = users.detect {|u| u.name == 'Lifo' }
      lifo_posts = lifo.posts
      assert_equal ["Cramp 1.0", "Say hi to Cramp", "First post"].sort, lifo_posts.map(&:title).sort

      bob = users.detect {|u| u.name == 'Bob' }
      bob_posts = bob.posts
      assert_equal ["Hello"], bob_posts.map(&:title).sort

      # Query 3 - Load all the comments
      cramp_update_post = lifo_posts.detect {|p| p.title == 'Cramp 1.0' }
      assert_equal ['Congrats'], cramp_update_post.comments.map(&:body)

      bob_hello_post = bob_posts.first
      assert_equal ["Welcome Bob!", "Thanks Lifo."].sort, bob_hello_post.comments.map(&:body).sort
    end
  end

  def test_has_many_through
    assert_queries(3) do
      # Query 1
      users = User.all

      # Query 2 & 3 - Load all the posts and all the comments
      lifo = users.detect {|u| u.name == 'Lifo' }
      assert_equal 4, lifo.comments.length

      bob = users.detect {|u| u.name == 'Bob' }
      assert_equal 2, bob.comments.length
    end
  end

  def test_has_many_through_polymorphic_source
    assert_queries(3) do
      # Query 1
      users = User.all

      # Query 2 & 3 - Load all the posts and all the comments
      assert_equal ["first", "cramp", "first", "welcome"].sort, users.map(&:tags).flatten.map(&:name).sort
    end
  end

  def test_belongs_to
    assert_queries(2) do
      # Query 1
      posts = Post.all

      # Query 2 - Load all the authors
      assert_equal ["Lifo", "Bob"], posts.map(&:user).map(&:name).uniq
    end
  end

  def test_belongs_reload
    assert_queries(4) do
      # Query 1
      posts = Post.all
      hello_post = posts.detect {|p| p.title == 'Hello' }

      # Query 2 - Load all the users
      assert_equal 'Bob', hello_post.user.name

      # Query 3 & 4- Reload Bob. Also fires SHOW TABLES query.
      assert_equal 'Bob', hello_post.user.reload.name
    end
  end

  def test_has_one
    assert_queries(2) do
      # Query 1
      users = User.all

      # Query 2 - Load all the last posts
      assert_equal ["Cramp 1.0", "Hello"].sort, users.map(&:last_post).map(&:title).sort
    end
  end

  def test_has_one_through
    assert_queries(3) do
      # Query 1
      users = User.all

      # Query 2 & 3 - Load all the last posts and then last comments
      assert_equal ["Bob", "Lifo"].sort, users.map(&:last_comment).flatten.compact.map(&:author_name).sort
    end
  end

  def test_polymorphic_has_many
    assert_queries(2) do
      # Query 1
      posts = Post.all

      # Query 2 - Load all the tags
      assert_equal ["first", "cramp", "welcome"].sort, posts.map(&:tags).flatten.map(&:name).uniq.sort
    end
  end

  def test_polymorphic_belongs_to
    assert_queries(2) do
      # Query 1
      tags = Tag.all

      # Query 2 - Load all the posts
      tags.first.taggable

      assert_equal ["Say hi to Cramp", "First post", "Hello", "First post"].sort, tags.map(&:taggable).map(&:title).sort
    end
  end

end
