class ComponentsController < ApplicationController
  def index
    puts "components index"
    filepath = './embeddings.csv'
    # helpers.download_object(filepath, 'askmybook', 'minimalist_entrepreneur_embedding.csv')
    $embedding = helpers.load_embedding_csv(filepath)
    answer = helpers.ask("Is Gumroad Profitable?", $embedding)
    puts answer
    # puts helpers.order_document_sections_by_query_similarity("Is Gumroad Profitable?", $embedding)

  end
  
end
