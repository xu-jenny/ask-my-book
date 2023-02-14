class Question < ApplicationRecord
    require 'date'
    validates :question, presence: true
    validates :answer, presence: true

    def self.process_question(question)
        if question[-1] != '?'
            question += '?'
        end
        return question.downcase.strip.squish.tr('"', "'")
    end

    def self.get(question)
        return Question.find_by question: question
    end

    def self.find_similiarq(question)
        q = Question.where("similiarq LIKE ?", "%"+question+"%")
        puts "find_similiarq:"
        puts "q.any?", q.any?
        if q.any?
            return q[0]
        end
        return nil
    end

    def self.create_question(question, answer, question_embedding, similiarq="")
        Question.create({ question: question, answer: answer, embedding: question_embedding, similiarq: similiarq })
    end

    def self.update_similiarq(new_q, key)
        # key is answer column
        q = Question.find_by answer: key
        # puts q.include? new_q
        # if !q.include? new_q
        q.similiarq << new_q
        q.save
        # end
    end

end
