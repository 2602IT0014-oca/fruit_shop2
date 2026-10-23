class RemoveProductIdAndCountFromOrders < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :product_id, :integer
    remove_column :orders, :count, :integer
  end
end
