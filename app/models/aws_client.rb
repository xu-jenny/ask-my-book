require 'singleton'

class AwsClient
    include Singleton
    BUCKET='askmybook'

    private
    Aws.config.update(
            region: 'us-east-1',
            credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
        )
    @s3_client = Aws::S3::Client.new(region: 'us-east-1')

    def self.download_object(filename, objKey)
        s3_client.get_object(
            response_target: filename,
            bucket: bucketName,
            key: objKey
        )
    end
end
