class CreateJobBoardProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_providers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :api_documentation_url
      t.string :auth_type, null: false, default: 'api_key'
      t.string :base_url, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :job_board_providers, :slug, unique: true
    add_index :job_board_providers, :status
    add_index :job_board_providers, :settings, using: :gin
  end
end
