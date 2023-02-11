require 'resemble'

Resemble.api_key = 'iyjENIBVr750HudFHRbhgwtt'

project_uuid = '9ad46ece-askmybook'
voice_uuid = ''
body = 'This is a sync test'

response = Resemble::V2::Clip.create_sync(
  project_uuid,
  voice_uuid,
  body,
  title: nil,
  sample_rate: nil,
  output_format: nil,
  precision: nil,
  include_timestamps: nil,
  is_public: nil,
  is_archived: nil,
  raw: nil
)

clip = response['item']
puts clip
