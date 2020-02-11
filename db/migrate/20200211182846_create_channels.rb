class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.string :channel_id
      t.references :workspace, index: true

      t.timestamps
    end
  end
end
