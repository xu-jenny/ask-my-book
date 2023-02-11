require "ruby/openai"
require './env'
require 'matrix'

EMBEDDING_MODEL="text-embedding-ada-002"
$client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_KEY'])

def get_embedding(text)
    $client.embeddings(
        parameters: {
            model: EMBEDDING_MODEL,
            input: text
        }
    )["data"][0]["embedding"]
end

def vector_similarity(x, y)
    return Vector.send(:new, x).inner_product(Vector.send(:new, y))
end

# question1="Why is the name of your book 'the minimalist entrepreneur'?"
# question2="how did you come up with 'the minimalist entrepreneur' as the name of your book?"
# 0.9684168588941271

# question1="What is the best way to distribute surveys to test my product idea?"
# question2="What is the best way to distribute surveys?"
# 0.9558237899126465  # this would be a negative example, these two questions are not equivelent

# question1="How do you know, when to quit"
# question2="when is the right time to quit?"
# 0.9169382771898864

# question1="How to choose what business to start?"
# question2="What is the right business to begin with?"
# 0.9363716798284702

# question1="Why is the name of your book 'the minimalist entrepreneur'"
# question2="Why did you choose the name 'the minimalist entrepreneur' for your book?"
# 0.9770928016033772

# question1="What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?"
# question2="Tell me a business idea for the minimalist entrepreneur that isn't being pursued yet"
# 0.9362871755185718

e1 = get_embedding(question1)
e2 = get_embedding(question2)

puts e1.length()
puts e2.length()
puts vector_similarity(e1, e2)
