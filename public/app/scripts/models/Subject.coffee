Public.Subject = Ember.Object.extend()

Public.Subject.reopenClass(

	fetchRandom:(count=10)->
		Public.Ajax.get("/subjects?count=#{count}").then (results)->
			Em.A(Public.Subject.create(result) for result in results)

	fetch:(id)->
		Public.Ajax.get("/subjects/#{id}").them (result)->
			Public.Subject.create(result)
)