class Project < ActiveRecord::Base
  has_many :tasks, :attributes => true, :discard_if => proc { |task| task.title.blank? }, :dependent => :destroy

  validates_presence_of :name
end
