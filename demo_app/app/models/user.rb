class User < ActiveRecord::Base
  has_one :address, :as => :addressable, :attributes => true, :dependent => :destroy

  validates_presence_of :name
  validates_associated :address
end
