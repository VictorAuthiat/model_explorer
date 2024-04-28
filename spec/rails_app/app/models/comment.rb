class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :content, presence: true

  enum status: {draft: 0, published: 1, archived: 2}

  scope :with_status, ->(status) { where(status: status) }
end
