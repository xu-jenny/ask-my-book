class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question, null: false
      t.string :answer, null: false
      t.string :audio_src_url
      t.string :context, null: false

      t.timestamps
    end
  end
end
