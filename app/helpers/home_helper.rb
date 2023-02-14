module HomeHelper
    MAX_SECTION_LEN = 1000

    def load_embedding_csv(filepath)
        embedding = CSV.read(filepath)
        hash = Hash.new()
        embedding.each do |page|
            hash[page[0]] = [page[1].gsub("[", "").gsub("]", "").split(/\s*,\s*/).map(&:to_f), page[2], page[3]]
        end
        return hash
    end

    ### FIND DUPLICATE QUESTION FUNCTIONS ###

    def find_existing_question(question)
        # check if question exist in cache
        q = Cache.get_question(question)
        if q != nil
            return q
        end

        # check if question string exist in db
        q = Question.get(question)
        if q != nil
            return q.answer
        end

        # check for similiar questions
        q = Question.find_similiarq(question)
        if q != nil
            return q.answer
        end
        return nil
    end

    def find_similiar_question(question_embedding)
        answers = []
        Question.pluck(:embedding, :answer).each do |e|
            sim = vector_similarity(e[0].split.map(&:to_f), question_embedding)
            if sim > 0.95
                answers << [sim, e[1]]
            end
        end
        if answers.length() > 0
            return answers.sort_by{|x,y|x}[0][1]
        end
        return nil
    end

    ### ASK QUESTION

    def vector_similarity(x, y)
        return Vector.send(:new, x).inner_product(Vector.send(:new, y))
    end

    def order_document_sections_by_query_similarity(query_embedding, context)
        document_similarities = Hash.new()
        context.each do |key, page|
            sim = vector_similarity(query_embedding, page[0])
            document_similarities[key] = sim
        end
        sorted_docs = document_similarities.sort_by {|k,v| v}
        return sorted_docs.reverse.to_h
    end

    def choose_sections(embedding, most_relevant_document_sections)
        chosen_sections_len = 0
        chosen_sections = []
        most_relevant_document_sections.each do |key, relevance|
            row = embedding[key]
            tokens = Integer(row[1])
            chosen_sections_len += tokens
            if chosen_sections_len >= MAX_SECTION_LEN
                break
            end
            chosen_sections << row[2]
        end
        return chosen_sections
    end

    def construct_query_promopt(embedding, question, question_embedding)
        most_relevant_document_sections = order_document_sections_by_query_similarity(question_embedding, embedding)
        chosen_sections = choose_sections(embedding, most_relevant_document_sections)
        header = """Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n"""
        prompt = header + chosen_sections.join('')  + "\n\n Q: " + question + "\n A:"
        return prompt
    end

    def ask(question, embedding, question_embedding=nil)
        if question_embedding == nil
            question_embedding = OpenaiClient.get_embedding(question)
        end
        p "start construct_query_promopt", DateTime.now.strftime('%Q')  # 1676302543474
        prompt = construct_query_promopt(embedding, question, question_embedding)   # 66ms
        p "start openai get_completion", DateTime.now.strftime('%Q')    # 1676302543540
        answer = OpenaiClient.get_completion(prompt)    # 3738ms
        return answer["choices"][0]["text"]
    end
end
