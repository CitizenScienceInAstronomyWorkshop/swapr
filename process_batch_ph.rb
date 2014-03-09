ENV["MONGOID_ENV"] = 'development'

require './config/config'
require './lib/agent'
require './lib/subject'
require 'mysql2'
require 'pry'



database = Mysql2::Client.new(dbname: "planethunters", hostname: "localhost", user: "root")

annotaitons_query = """
  select answer_id,  zooniverse_user_id, session_id, light_curve_id, static_image, sources.kind, light_curves.zooniverse_id , classifications.created_at
  from annotations,classifications,light_curves,sources  
  where 
  annotations.classification_id = classifications.id and 
  light_curves.id = classifications.light_curve_id and 
  sources.id = light_curves.source_id and 
  task_id = 4  
  limit 100000
"""

count_query = """
  select count(*) from annotations where task_id = 4 
"""

count        = 0
skip_count   = 0
average_time = 0

start_from   = Time.new(2010, 12, 17)

Agent.all.destroy
Subject.all.destroy


total_to_do =  100000 || database.query(count_query).first.keys.first

database.query(annotaitons_query,:stream=>true).each do |classification|
    start_time  = Time.now

    begin
    if count%1000 == 0
      puts "done #{count} of #{total_to_do}, #{count*100.0/total_to_do.to_f}% ,  skip #{skip_count} average time is #{average_time/1000.0}"; 
      average_time = 0 
    end

    count += 1



    subject  = Subject.find_or_create_by(ouroboros_subject_id: classification["light_curve_id"])

    if subject.status!="active" and subject.category=='test'
      next
    end



    if subject.kind == "unknown"

      if classification["kind"] == "simulation"
        subject.category = 'training'
        subject.kind     = 'sim'
      elsif  classification["kind"] == "planet"
          subject.category = 'test'
          subject.kind     = 'planet'
      else 
        subject.kind ='test'
      end

      subject.url  = classification["static_image"]

      subject.save

    end


    user_id  = (classification["zooniverse_user_id"] || classification["session_id"]).to_s
    agent    = Agent.find_or_create_by(user_id: user_id)

    if classification["answer_id"] == 9
      user_said = "LENS"
    else
      user_said = "NOT"
    end
    

    subject.update_prob( agent, user_said ) unless subject.category=="training" and subject.status!="active"
    # agent.update_confusion(user_said, subject.kind) if subject.category == 'training'
    agent.update_confusion_unsupervised(user_said, subject.probability) # if subject.category == 'training'



    rescue Exception => e
      binding.pry
    end

    average_time += Time.now - start_time
    
end
