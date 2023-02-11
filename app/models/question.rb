class Question < ApplicationRecord
    validates :question, presence: true
    validates :answer, presence: true
    validates :context, presence: true
end
