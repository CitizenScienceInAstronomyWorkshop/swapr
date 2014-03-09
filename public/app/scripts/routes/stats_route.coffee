Public.StatsRoute = Ember.Route.extend
	model:->
		Em.RSVP.all([
			Public.Subject.fetchRandom(10),
			Public.Agent.fetchRandom(10),
			Public.Stats.fetch()
		]).then (result)->
			return {subjects: result[0], users: result[1], stats: result[2]}