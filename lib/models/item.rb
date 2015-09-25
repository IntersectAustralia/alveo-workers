class Item < ActiveRecord::Base

  has_many :documents, dependent: :destroy

#  belongs_to :collection

  validates :uri, presence: true
  #validates :collection_id, presence: true
  validates :handle, presence: true, uniqueness: {case_sensitive: false}

end
