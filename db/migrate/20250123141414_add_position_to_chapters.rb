class AddPositionToChapters < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters, :position, :integer
  end
end
