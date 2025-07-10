class CreateSpecializations < ActiveRecord::Migration[7.0]
  def change
    create_table :specializations do |t|
      t.references :specializable, polymorphic: true, null: false
      t.references :candidate_role, null: false, foreign_key: true
      t.timestamps
    end
  end
end
