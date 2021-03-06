require 'rest-client'
require 'json'
require 'date'
 
git_project = "projectmosul"
git_issue_label = "LABELS,TO,TRACK"
 
## Change this if you want to run more than one set of issue widgets
event_name = "git_issues_labeled_defects"
 
## the endpoint we'll be hitting
uri = "https://api.github.com/repos/#{ENV['GIT_OWNER']}/#{git_project}/issues?state=open&per_page=100&access_token=#{ENV['GIT_TOKEN']}"

 
SCHEDULER.every '1h', :first_in => 0 do |job|
    puts "Getting #{uri}"
    response = RestClient.get uri
    issues = JSON.parse(response.body, symbolize_names: true)
 
    current_defects = issues.length
 
    send_event('git_issues_labeled_defects', { current: current_defects }) 
end # SCHEDULER