if Meteor.isServer
  Meteor.publish "allAccounts", ->
    AccountsCol.find({})

if (Meteor.isClient)
  # Meteor.subscribe "allAccounts"

  Template.acTable.helpers
    trows: () ->


  Template.acAddForm.events
    'submit form': (evt) ->
      evt.preventDefault()
      if  evt.target.name.value ## Prevent entering blank records by mistakenly clicking twice on submit
        AccountsCol.insert({
          name: evt.target.name.value
          accountClass: evt.target.accountClass.value
          description: evt.target.description.value
        }, evt.target.reset())
      else
        alert "Please Enter Account Name"
        evt.target.name.focus()

  Template.acTable.helpers
    accountRows: ->
      AccountsCol.find {}, {sort: {accountClass: 1, name: 1}}