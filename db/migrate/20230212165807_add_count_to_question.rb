class AddCountToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :count, :integer
    add_index :questions, :question, unique: true
  end
end
