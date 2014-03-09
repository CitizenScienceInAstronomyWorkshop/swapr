Public.Stats = Ember.Object.extend()

Public.Stats.reopenClass(
	fetch:->
		Public.Ajax.get("/stats").then (results)->
			Public.Stats.create results 
)