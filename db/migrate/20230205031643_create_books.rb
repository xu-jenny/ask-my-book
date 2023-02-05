class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :name
      t.string :embedding_url
      t.string :header

      t.timestamps
    end
  end
end
