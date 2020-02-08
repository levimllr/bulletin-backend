class CreateWorkplaces < ActiveRecord::Migration[6.0]
  def change
    create_table :workplaces do |t|
      t.string :team_name
      t.string :team_id
      t.string :bot_id

      t.timestamps
    end
  end
end
