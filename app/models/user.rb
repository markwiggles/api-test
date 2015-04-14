class User < ActiveRecord::Base

  validates :name, presence: true

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  def self.authenticate(name,password)
    user = self.find_by(name: name)
    name ==  user.name && password == user.password
  end


  # flag record as archived
  def archive
    self.archived = true
    self.save
  end

end
