require 'sinatra'
require './config/config'
require 'json'
require './lib/agent.rb'
require './lib/subject.rb'
require 'pry'
require 'rack/cors'

use Rack::Cors do |config|
	config.allow do |allow|
		allow.origins "*"
		allow.resource "*"
	end
end

before do
   content_type 'application/json'
end





get '/stats' do
	active 	 	  = Subject.where(:status => "active").count
	rejected 	  = Subject.where(:status => "rejected").count
	detected 	  = Subject.where(:status => "detected").count
	found_sims 	  = Subject.where({:status => "detected", :kind =>"sim"}).count
	rejected_duds = Subject.where({:status => "rejected", :kind =>"dud"}).count
	total_sims 	  = Subject.where({:kind =>"sim"}).count
	total_duds 	  = Subject.where({:kind =>"dud"}).count
	{active: active, rejected: rejected, detected: detected, found_sims: found_sims, rejected_duds: rejected_duds, total_sims: total_sims, total_duds: total_duds}.to_json
end

get '/subjects' do 
	count = params["count"] || 20
	Subject.limit(count).all.to_json
end

get '/subjects/:id' do 
	Subject.where(ouroboros_subject_id: params[:id]).first.to_json
end

get '/recovered_training' do 
	Subject.where(category:"training", status: "detected").to_json
end

get '/rejected_training' do 
	Subject.where(category:"training", status: "rejected").to_json
end
get '/random_sims' do 
	limit = params[:limit] || 20
	Subject.where(:kind => "sim").limit(limit).all.to_json
end

get '/random_tests' do 
	limit = params[:limit] || 20
	Subject.where(:kind => "test").limit(limit).all.to_json
end

get '/random_duds' do 
	limit = params[:limit] || 20
	Subject.where(:kind => "dud").limit(limit).all.to_json
end

get '/agents' do 
	count = params["count"] || 20
	Agent.limit(count).all.to_json
end

get '/agents/:id' do 
	Agent.where(user_id: params[:id]).first.to_json
end


get '/candidates' do 
	Subject.where({:kind=>"test", :status => "detected"}).all.to_json
end
