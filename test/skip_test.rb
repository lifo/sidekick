require 'test_helper'

class BasicTest < ActiveRecord::TestCase
  def setup
    @users = User.all

    @lifo = @users.detect {|u| u.name == 'Lifo' }
    @bob = @users.detect {|u| u.name == 'Bob' }
  end

  def test_skip_on_finder_sql
    assert_queries(2) do
      @lifo.lol_posts.to_a

      assert ! @bob.lol_posts.loaded?
      @bob.lol_posts.to_a
    end
  end

  def test_skip_on_order
    assert_queries(2) do
      @lifo.ordered_posts.to_a

      assert ! @bob.ordered_posts.loaded?
      @bob.ordered_posts.to_a
    end
  end

  def test_skip_on_limit
    assert_queries(2) do
      @lifo.recent_posts.to_a

      assert ! @bob.recent_posts.loaded?
      @bob.recent_posts.to_a
    end
  end

  def test_skip_on_conditions
    assert_queries(2) do
      @lifo.hello_posts.to_a

      assert ! @bob.hello_posts.loaded?
      @bob.hello_posts.to_a
    end
  end

  def test_skip_on_uniq
    assert_queries(2) do
      @lifo.unique_tags.to_a

      assert ! @bob.unique_tags.loaded?
      @bob.unique_tags.to_a
    end
  end

end
