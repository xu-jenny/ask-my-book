class AddEmbeddingToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :embedding, :text, array: true, default: []
  end
end
