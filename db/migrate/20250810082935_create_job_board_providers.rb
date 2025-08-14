class CreateJobBoardProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_providers do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :api_documentation_url
      t.string :logo_url
      t.boolean :is_active

      t.timestamps
    end
  end
end
