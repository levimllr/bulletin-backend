class CreateWorkspaces < ActiveRecord::Migration[6.0]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.string :workspace_id
      t.string :bot_id

      t.timestamps
    end
  end
end
