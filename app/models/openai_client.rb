require 'singleton'

class OpenaiClient
    include Singleton

    EMBEDDING_MODEL="text-embedding-ada-002"
    COMPLETIONS_MODEL = "text-davinci-003"

    private
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

    def self.get_embedding(text, model=EMBEDDING_MODEL)
        @client.embeddings(
            parameters: {
                model: model,
                input: text
            }
        )["data"][0]["embedding"]
    end

    def self.get_completion(prompt)
        @client.completions(
            parameters: {
                prompt: prompt,
                temperature: 0.0,
                max_tokens: 300,
                model: COMPLETIONS_MODEL,
            }
        )
    end
end
