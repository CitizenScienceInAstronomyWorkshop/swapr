Public.Agent = Ember.Object.extend()

Public.Agent.reopenClass(
	fetchRandom:(count=10)->
		Public.Ajax.get("/agents?count=#{count}").then (results)->
			Em.A(Public.Agent.create(result) for result in results)
			
	ffetch:(id)->
		Public.Ajax.get("/agent/#{id}").them (result)->
			Public.Agent.create(result)
)