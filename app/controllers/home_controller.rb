class HomeController < ApplicationController
    $counter = 0
    def index
        puts "home index"
    end
    def load
        if @book_id.nil?
            load_tme()
        else
            puts "book_id is not null"
            puts @book_id
        end
    end

    def pdf
        puts pdf_params
        puts pdf_params[:pdf]
    end
    def pdf_params
        params.permit(:pdf)
    end

    def load_tme
        embedding_filepath = "./embeddings.csv"
        helpers.download_object(embedding_filepath, "askmybook", "minimalist_entrepreneur_embedding.csv")
        $embedding = helpers.load_embedding_csv(embedding_filepath)
    end
    def ask
        @question = helpers.process_question(ask_params[:question])
        puts @question
        question_cache = Rails.cache.read(@question)
        puts question_cache
        puts question_cache == nil
        if question_cache == nil
        # Rails.cache.fetch("ask/#{@question}", expires_in: 12.hours) do
            puts "executing the block"
            # $counter++
            # puts $counter
            answer = "this is an answer!"
            temp = Rails.cache.write(@question, answer, expires_in: 1.minute)
            puts temp
            # @q_embedding = helpers.get_embedding(@question)
            # answer = helpers.find_duplicate_question(@question, @q_embedding)
            # if answer != nil
            #     render json: { answer: answer }
            # end
            # answer, prompt = helpers.ask(@question, @q_embedding, $embedding)
            # puts answer
            # Question.create({ question: question, answer: answer, context: prompt, embedding: @q_embedding})
            render json: { answer: answer}
        else 
            render json: { answer: question_cache }
        end
        

    end
    def ask_params
        params.permit(:question)
      end
end
