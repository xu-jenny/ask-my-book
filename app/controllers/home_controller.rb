class HomeController < ApplicationController
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
    def load_tme
        embedding_filepath = "./embeddings.csv"
        # helpers.download_object(embedding_filepath, "askmybook", "minimalist_entrepreneur_embedding.csv")
        $embedding = helpers.load_embedding_csv(embedding_filepath)
    end
    def ask
        answer = helpers.ask(ask_params[:question], $embedding)
        puts answer
        render json: { answer: answer }

    end
    def ask_params
        params.permit(:question)
      end
end
