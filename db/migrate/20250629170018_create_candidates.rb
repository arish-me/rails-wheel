class CreateCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :candidates do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
