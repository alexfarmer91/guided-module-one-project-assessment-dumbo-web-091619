class CreateBorrowers < ActiveRecord::Migration[5.2]
  def change
    create_table :borrowers do |t|
      t.string :name 
      t.string :password
      t.text :bio
    end
  end
end
