class Workspace < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :workspace_id, presence: true, uniqueness: true
  validates :bot_id, presence: true, uniqueness: true

  has_many :channels

  def self.bot_id?(id)
    bot_ids.include?(id)
  end

  def self.bot_ids
    Workspace.all.map{ |place| place.bot_id }
  end
end
