require 'test_helper'

class ReloadTest < ActiveRecord::TestCase
  def test_reload_existing_record
    assert_queries(2) do
      # Query 1
      users = User.all

      lifo = users.detect {|u| u.name == 'Lifo'}

      # Query 2 - Reload Lifo
      assert_equal 'Lifo', lifo.reload.name
    end
  end

  def test_reload_newly_created_record
    noob = User.create(:name => 'Noob')

    assert_queries(1) { assert_equal 'Noob', noob.reload.name }
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

end
