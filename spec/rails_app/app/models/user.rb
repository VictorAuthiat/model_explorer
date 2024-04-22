class User < ActiveRecord::Base
  devise :database_authenticatable

  has_many :posts
  has_many :comments
end
