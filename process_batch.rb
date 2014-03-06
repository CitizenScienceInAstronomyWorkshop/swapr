ENV["MONGOID_ENV"] = 'development'

require './config/config'
require './lib/agent'
require './lib/subject'
require 'mongo'
require 'pry'

ouroboros_client           = Mongo::MongoClient.new
ouroboros                  = ouroboros_client["ouroboros"]
space_warp_classifications = ouroboros["spacewarp_classifications"]
space_warp_subjects        = ouroboros["spacewarp_subjects"]

group_ids = {"5154a3783ae74086ab000001" => "subject", "5154a3783ae74086ab000002"=> "sim"}

count = 0
skip_count = 0

Agent.all.destroy
Subject.all.destroy

space_warp_classifications.find({}).sort(:created_at => 1).each do |classification|


    begin
    puts "done #{count} skip #{skip_count}" if count%1000 == 0
    count += 1

    user_id           = (classification["user_id"] || classification["user_ip"]).to_s

    subject  = Subject.find_or_create_by(ouroboros_subject_id: classification["subject_ids"].first.to_s)

    if subject.kind == "unknown"

      ouroboros_subject = space_warp_subjects.find_one({:_id => classification["subject_ids"].first})

      unless ouroboros_subject
        skip_count += 1
        next
      end

      type = 'SUBJECT'

      training = ouroboros_subject["metadata"]["training"]


      if training and training.count >0 and training.first["type"]
        if ["lensing cluster", "lensed quasar", "lensed galaxy"].include? training.first["type"]
          type = 'LENS'
        elsif  training.first["type"] == "empty"
          type = "DUD"
        end
      end

      subject.kind = type

      subject.save

    end

    agent    = Agent.find_or_create_by(user_id: user_id)

    if classification["annotations"].select{|a| a.keys.include? "x"}.empty?
      user_said = "NONE"
    elsif classification["annotations"].select{|a| a.keys.include? "simFound"}.count ==1
      if classification["annotations"].select{|a| a.keys.include? "simFound"}.first.values.first
        user_said = "LENS"
      else
        user_said = "NONE"
      end
    else
      user_said = "NONE"
    end


    subject.update_prob( agent, user_said )
    agent.update_confusion(user_said, type) unless type == "SUBJECT"


    rescue Exception => e
      binding.pry
    end
end
