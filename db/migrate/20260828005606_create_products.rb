class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false    # 商品名
      t.text :description            
      t.integer :price, null: false  # 価格

      t.timestamps
    end
  end
end
