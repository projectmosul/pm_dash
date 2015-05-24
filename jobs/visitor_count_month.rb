require 'google/api_client'
require 'date'
 
client = Google::APIClient.new(application_name: 'Project Mosul', application_version: '0.01')
key_file = File.join 'project-f22fdc45263f.p12' # File containing your private key

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, ENV['GOOGLE_KEY_SECRET'])
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => ENV['GOOGLE_SERVICE_ACCOUNT_EMAIL'],
  :signing_key => key)
 
# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
 
  # Request a token for our service account
  client.authorization.fetch_access_token!
 
  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')
 
  # Start and end dates
  startDate = (DateTime.now << 1).strftime("%Y-%m-%d")  # first day of current month
  endDate = DateTime.now.strftime("%Y-%m-%d")  # now
 
  # Execute the query
  visitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    # 'dimensions' => "ga:month",
    'metrics' => "ga:users",
    # 'sort' => "ga:month" 
  })
 
  # Update the dashboard
  # Note the trailing to_i - See: https://github.com/Shopify/dashing/issues/33
  send_event('visitor_count_month',   { current: visitCount.data.rows[0][0].to_i })
end