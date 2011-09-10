ActiveRecord::Schema.define do
  original_stdout = $stdout
  $stdout = StringIO.new

  create_table :users, :force => true do |t|
    t.string :name
  end

  create_table :posts, :force => true do |t|
    t.string :title
    t.string :content
    t.belongs_to :user
  end

  add_index :posts, :user_id

  create_table :comments, :force => true do |t|
    t.string :body
    t.string :author_name
    t.belongs_to :post
  end

  add_index :comments, :post_id

  create_table :tags, :force => true do |t|
    t.string :name
    t.belongs_to :taggable, :polymorphic => true
  end

  add_index :tags, [:taggable_id, :taggable_type]

  $stdout = original_stdout
end
