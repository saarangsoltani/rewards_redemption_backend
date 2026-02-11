class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :points_cost, null: false
      t.integer :qty_available, null: false
      t.string :image_url, null: false

      t.timestamps
    end
  end
end
