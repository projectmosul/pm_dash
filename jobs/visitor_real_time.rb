require 'google/api_client'
require 'date'
max_amount = 100

client = Google::APIClient.new(application_name: 'Project Mosul', application_version: '0.01')
key_file = File.join 'lib','project-f22fdc45263f.p12' # File containing your private key

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, ENV['GOOGLE_KEY_SECRET'])
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => ENV['GOOGLE_SERVICE_ACCOUNT_EMAIL'],
  :signing_key => key)

visitors = []

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Execute the query
  response = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => "ga:" + profile_id,
    'metrics' => "ga:activeVisitors",
  })

  visitors << { x: Time.now.to_i, y: response.data.rows }
  if visitors.size > max_amount
    visitors.shift
  end
  # Update the dashboard
  send_event('visitor_count_real_time', points: visitors)
end