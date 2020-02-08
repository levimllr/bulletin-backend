class Workplace < ApplicationRecord
  def self.bot_id?(id)
    bot_ids.include?(id)
  end

  def self.bot_ids
    Workplace.all.map{ |place| place.bot_id }
  end
end
