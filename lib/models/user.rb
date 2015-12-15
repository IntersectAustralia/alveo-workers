class User < ActiveRecord::Base

  has_many :collections, inverse_of: :owner, foreign_key: :owner_id

end