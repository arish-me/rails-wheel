class CreateJobBoardFieldMappings < ActiveRecord::Migration[8.0]
  def change
    create_table :job_board_field_mappings do |t|
      t.references :job_board_integration, null: false, foreign_key: true
      t.string :local_field, null: false
      t.string :external_field, null: false
      t.string :field_type, null: false, default: 'string'
      t.boolean :is_required, null: false, default: false
      t.string :default_value

      t.timestamps
    end

    add_index :job_board_field_mappings, [ :job_board_integration_id, :local_field ], unique: true, name: 'index_field_mappings_on_integration_and_local_field'
    add_index :job_board_field_mappings, [ :job_board_integration_id, :external_field ], unique: true, name: 'index_field_mappings_on_integration_and_external_field'
    add_index :job_board_field_mappings, :field_type
    add_index :job_board_field_mappings, :is_required
  end
end
