class Book < ApplicationRecord
    validates :name, presence: true
    validates :filename, presence: true
    after_initialize :default_values

    private
        def default_values
            self.embedding_bucket = "askmybook"
            self.header ||= "Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful:"
        end
end
