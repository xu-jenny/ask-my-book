module HomeHelper
    EMBEDDING_MODEL="text-embedding-ada-002"
    COMPLETIONS_MODEL = "text-davinci-003"
    MAX_SECTION_LEN = 1000

    # def generate_key(file_name)
    #     # Append a unique id to distinguish 2 files with same name.
    #     # We can use timestamp as well in place of uuid.
    #     random_file_key = SecureRandom.uuid
    #     "#{Rails.env}/attachment/#{random_file_key}-#{file_name}"
    #   end

    # def upload_file(file, objKey, body)
    #     Aws.config.update(
    #         region: 'us-east-1',
    #         credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
    #     )
    #     s3_client = Aws::S3::Client.new(region: 'us-east-1')
    #     s3_bucket = Aws::S3::Resource.new.bucket(
    #         Rails.application.credentials.aws.fetch("ask-my-book")
    #     )
    #     s3_client.put_object(
    #         bucket: "askmybook",
    #         key: objKey,
    #         body: body
    #     )
    # end


    def client() = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

    def download_object(filename, bucketName, objKey)
        Aws.config.update(
            region: 'us-east-1',
            credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
        )
        s3_client = Aws::S3::Client.new(region: 'us-east-1')
        # response = s3_client.list_objects_v2(bucket: '')
        # response.contents.each do |object|
        #     puts object.key
        # end

        s3_client.get_object(
            response_target: filename,
            bucket: bucketName,
            key: objKey
        )
    end

    def load_embedding_csv(filepath)
        embedding = CSV.read(filepath)
        hash = Hash.new()
        embedding.each do |page|
            hash[page[0]] = [page[1].gsub("[", "").gsub("]", "").split(/\s*,\s*/).map(&:to_f), page[2], page[3]]
        end
        return hash
    end

    ### ASK QUESTION FUNCTIONS ###
    def process_question(question)
        if question[-1] != '?'
            question += '?'
        end
        return question.downcase.strip.squish.tr('"', "'")
    end

    def find_similiar_question(question)
        Question.where
    end

    def find_duplicate_question(question, q_embedding)
        # check if question string exist in db
        q = Question.find_by question: question
        if q != nil
            return q.answer
        end
        # todo: check for similar questions arr
        q = Question.where("similiarq LIKE ?", "%"+question+"%")
        puts "similiar q:"
        puts q.any?
        puts q[0]
        puts q[0].answer
        if q.any?
            return q[0].answer
        end
        puts "check for similiar questions using vec_sim"
        # answer = find_similiar_question_vec(question, q_embedding)
        # return answer
    end

    def find_similiar_question_vec(question, q_embedding)
        @answers = []
        Question.pluck(:embedding, :answer).each do |e|
            puts e[0].class
            puts e[0].split.length()
            sim = vector_similarity(e[0].split.map(&:to_f), q_embedding)
            puts sim
            if sim > 0.97
                @answers << [sim, e[1]]
            end
        end
        # puts @answers
        if @answers.length() > 0
            top_answer = @answers.sort_by{|x,y|x}[0][1]
            q = Question.find_by answer: top_answer
            puts q
            #  check if not aldrey exist
            q.similiarq << question
            puts q.similiarq
            q.save
        end
        return nil
        # @embedding_hash = Hash.new() #Question.pluck(:id, :embedding).uniq
        # @embedding_list = Question.select("embedding")

        # Question.pluck(:embedding).each do |e|
        #     sim = vector_similarity(e.map(&:to_i), q_embedding)
        #     @embedding_hash[id] = sim
        # end

        # @temp = @embedding_list.map(|x| vector_similarity(x, q_embedding))
        # @embedding_list.each {|id, embedding|
        #     sim = vector_similarity(embedding, q_embedding)
        #     if sim > 0.96
        #         @embedding_hash[id] = sim
        #     end}
        # puts "embedding_hash:"
        # if @embedding_hash.size >= 1
        #     # max_sim = @embedding_hash.max_by{|k,v| v}
        #     question_key = @embedding_hash.key(@embedding_hash.values.max)
        #     temp = Question.where(question: question_key)
        #     return temp

        # end
        # return nil
    end

    def get_embedding(text, model=EMBEDDING_MODEL)
        client.embeddings(
            parameters: {
                model: model,
                input: text
            }
        )["data"][0]["embedding"]
    end

    def vector_similarity(x, y)
        return Vector.send(:new, x).inner_product(Vector.send(:new, y))
    end

    def order_document_sections_by_query_similarity(query_embedding, context)
        # data = get_embedding(query, EMBEDDING_MODEL)
        # query_embedding = data["data"][0]["embedding"]
        document_similarities = Hash.new()
        puts "context in order_document_sections_by_query_similarity:"
        # puts context
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

    def construct_query_promopt(embedding, question, header, question_embedding)
        most_relevant_document_sections = order_document_sections_by_query_similarity(question_embedding, embedding)
        chosen_sections = choose_sections(embedding, most_relevant_document_sections)

        # questions = ["\n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small.",
        # "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!",
        # "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!",
        # "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary.",
        # "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…",
        # "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work.",
        # "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step.",
        # "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline.",
        # "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free.",
        # "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."]

        prompt = header + chosen_sections.join('')  + "\n\n Q: " + question + "\n A:"
        return prompt
    end

    def ask_question(prompt)
        return client.completions(
            parameters: {
                prompt: prompt,
                temperature: 0.0,
                max_tokens: 300,
                model: COMPLETIONS_MODEL,
            }
        )
    end

    def ask(question, question_embedding, embedding)
        header = """Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n"""
        prompt = construct_query_promopt(embedding, question, header, question_embedding)
        answer = ask_question(prompt)
        return answer["choices"][0]["text"]
    end
end
