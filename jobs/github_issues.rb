#!/usr/bin/env ruby
require 'rest-client'
require 'json'
require 'date'
 
git_token = "2c428bd0bd323c066c9b291c40db0ed3f69c48a0"
git_owner = "neshmi"
git_project = "projectmosul"
git_issue_label = "LABELS,TO,TRACK"
 
## Change this if you want to run more than one set of issue widgets
event_name = "git_issues_labeled_defects"
 
## the endpoint we'll be hitting
uri = "https://api.github.com/repos/#{git_owner}/#{git_project}/issues?state=open&per_page=100&access_token=#{git_token}"

 
## Create an array to hold our data points
points = []
 
## One hours worth of data for, seed 60 empty points (rickshaw acts funny if you don't).
(0..60).each do |a|
  points << { x: a, y: 0.01 }
end
 
## Grab the last x value
last_x = points.last[:x]
 
 
SCHEDULER.every '1h', :first_in => 0 do |job|
    puts "Getting #{uri}"
    response = RestClient.get uri
    issues = JSON.parse(response.body, symbolize_names: true)
 
    current_defects = issues.length
 
    ## Drop the first point value and increment x by 1
    points.shift
    last_x += 1
 
    ## Push the most recent point value
    points << { x: last_x, y: current_defects  }
 
    send_event(event_name, {
            text: current_defects, points:points
        })
 
end # SCHEDULER