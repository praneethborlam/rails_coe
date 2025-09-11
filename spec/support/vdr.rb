require 'vcr'

VCR.configure do |config|
  # Where to store cassettes (recorded HTTP interactions)
  config.cassette_library_dir = 'spec/vcr_cassettes'
  
  # Use WebMock to stub HTTP requests
  config.hook_into :webmock
  
  # Allow connections to localhost (for test database, etc.)
  config.ignore_localhost = true
  
  # Configure RSpec integration
  config.configure_rspec_metadata!
  
  # Filter sensitive data (API keys, passwords, etc.)
  config.filter_sensitive_data('<API_KEY>') { ENV['EXTERNAL_API_KEY'] }
  config.filter_sensitive_data('<SECRET_TOKEN>') { ENV['SECRET_TOKEN'] }
  
  # Default cassette options
  config.default_cassette_options = {
    record: :once,                    # Record only once, then replay
    allow_unused_http_interactions: false
  }
  
  # Allow real HTTP requests in development
  config.allow_http_connections_when_no_cassette = false
  
  # Debug mode (uncomment for debugging)
  # config.debug_logger = File.open(Rails.root.join('log', 'vcr.log'), 'w')
end

# RSpec configuration for VCR
RSpec.configure do |config|
  # Automatically use VCR for any spec tagged with :vcr
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end