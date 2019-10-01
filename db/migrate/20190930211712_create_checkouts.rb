class CreateCheckouts < ActiveRecord::Migration[5.2]
  def change
    create_table :checkouts do |t|
      t.integer :borrower_id 
      t.integer :book_id 
      t.timestamps null:false
    end
  end
end
