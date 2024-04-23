class User < ActiveRecord::Base
  devise :database_authenticatable

  has_many :posts
  has_many :comments

  has_one :first_post, -> { order(created_at: :asc) }, class_name: "Post"
end
