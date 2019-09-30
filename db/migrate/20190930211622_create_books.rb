class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn 
      t.string :genre 
      t.text :description
    end
  end
end
