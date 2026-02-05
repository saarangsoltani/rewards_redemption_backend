class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string :name
      t.text :description
      t.integer :points_cost
      t.integer :qty_available
      t.string :image_url

      t.timestamps
    end
  end
end
