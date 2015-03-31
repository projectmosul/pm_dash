require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'ZOFDn9atQGHrTylx11gZCLjyo'
  config.consumer_secret = 'cJMSR6gkpHouwnkQzRfC4LxOMOZRAXlupexOObCL2emMeIHkDl'
  config.access_token = '3092733227-h12QRn8znm4vocdwVNtJlfSc8F07JeAwubXuqQ5'
  config.access_token_secret = 'drL16l8BJrhEnBKA1HIxfr2hiNmyYHMnW3AGOYqL9Mky5'
end

search_term = URI::encode('#projectmosul')

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")

    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', comments: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end