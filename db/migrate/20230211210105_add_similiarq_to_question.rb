class AddSimiliarqToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :similiarq, :text, array:true, default: []
  end
end
