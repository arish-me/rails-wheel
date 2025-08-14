class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.references :company, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      # Basic Job Information
      t.string :title, null: false
      t.text :description
      t.text :requirements
      t.text :benefits

      # Job Details
      t.string :role_type
      t.string :role_level
      t.string :remote_policy # on_site, remote, hybrid
      t.decimal :salary_min, precision: 10, scale: 2
      t.decimal :salary_max, precision: 10, scale: 2
      t.string :salary_currency, default: 'USD'
      t.string :salary_period # hourly, daily, weekly, monthly, yearly

      # Location
      t.string :location
      t.string :city
      t.string :state
      t.string :country
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      # Status and Visibility
      t.string :status, default: 'draft' # draft, published, closed, archived
      t.boolean :featured, default: false
      t.datetime :published_at
      t.datetime :expires_at

      # Application Settings
      t.boolean :allow_cover_letter, default: true
      t.boolean :require_portfolio, default: false
      t.text :application_instructions

      # SEO and External Integration
      t.string :external_id # For external job board integration
      t.string :external_source # linkedin, indeed, etc.
      t.jsonb :external_data # Store external job board specific data

      # Analytics
      t.integer :views_count, default: 0
      t.integer :applications_count, default: 0

      t.boolean :worldwide, default: true

      t.timestamps
    end

    add_index :jobs, :status
    add_index :jobs, :role_type
    add_index :jobs, :role_level
    add_index :jobs, :remote_policy
    add_index :jobs, :featured
    add_index :jobs, :published_at
    add_index :jobs, :expires_at
    add_index :jobs, :external_id
    add_index :jobs, :external_source
    add_index :jobs, :external_data, using: :gin
    add_index :jobs, [ :company_id, :status ]
    add_index :jobs, [ :status, :published_at ]
  end
end
