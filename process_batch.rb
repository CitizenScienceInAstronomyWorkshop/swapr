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

count        = 0
skip_count   = 0
average_time = 0

space_warp_classifications.ensure_index(:created_at => 1 )


start_from   = Time.new(2014, 1, 9)

Agent.all.destroy
Subject.all.destroy

total_to_do =1000000# space_warp_classifications.find({:created_at => {:$gt => start_from}}).limit(1000000).count 

space_warp_classifications.find({:created_at => {:$gt => start_from}}).sort(:created_at => 1).limit(1000000).each do |classification|
    start_time  = Time.now

    begin
    if count%1000 == 0
      puts "done #{count} of #{total_to_do}, #{count*100.0/total_to_do.to_f}% ,  skip #{skip_count} average time is #{average_time/1000.0}"; 
      average_time = 0 
    end
    count += 1

    user_id           = (classification["user_id"] || classification["user_ip"]).to_s

    subject  = Subject.find_or_create_by(ouroboros_subject_id: classification["subject_ids"].first.to_s)

    if subject.status!="active" and subject.category=='test'
      next
    end


    if subject.kind == "unknown"

      ouroboros_subject = space_warp_subjects.find_one({:_id => classification["subject_ids"].first})

      unless ouroboros_subject
        skip_count += 1
        next
      end


      training = ouroboros_subject["metadata"]["training"]


      if training and training.count >0 and training.first["type"]
        if ["lensing cluster", "lensed quasar", "lensed galaxy"].include? training.first["type"]
          subject.category = 'training'
          subject.kind     = 'sim'
        elsif  training.first["type"] == "empty"
          subject.category = 'training'
          subject.kind     = 'dud'
        end
      else 
        subject.kind ='test'
      end

      subject.url  = ouroboros_subject["location"]["standard"]

      subject.save

    end

    agent    = Agent.find_or_create_by(user_id: user_id)

    no_markers = classification["annotations"].select{|a| a.keys.include? "x"}.count

    if subject.kind == "sim"
      if classification["annotations"].select{|a| a.keys.include? "simFound"}.count > 0  and classification["annotations"].select{|a| a.keys.include? "simFound"}.first["simFound"] == "true"
        user_said = "LENS"
      else
        user_said = "NOT"
      end
    elsif subject.category == "test" || subject.kind == "dud"
        if no_markers > 0
          user_said = "LENS"
        else 
          user_said = "NOT"
        end
    end


    subject.update_prob( agent, user_said ) unless subject.category=="training" and subject.status!="active"
    # agent.update_confusion(user_said, subject.kind) if subject.category == 'training'
    agent.update_confusion_unsupervised(user_said, subject.probability) # if subject.category == 'training'


    rescue Exception => e
      binding.pry
    end

    average_time += Time.now - start_time
    
end
