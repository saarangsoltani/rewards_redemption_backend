class CreateRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :redemptions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :reward, null: false, foreign_key: true, index: true
      t.integer :points_consumed, null: false

      t.timestamps
    end

    add_index :redemptions, [ :user_id, :reward_id ] # Non-uniq to allow multiple redemptions per user/reward
  end
end
