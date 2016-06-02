class Collection < ActiveRecord::Base

  has_many :items
  validates :name, presence: true
  belongs_to :owner, class_name: 'User'
  
end
