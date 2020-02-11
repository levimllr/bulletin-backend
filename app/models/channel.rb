class Channel < ApplicationRecord
  validates :channel_id, presence: true, uniqueness: true
  validates :workspace_id, presence: true, uniqueness: true

  belongs_to :workspace
  
end
