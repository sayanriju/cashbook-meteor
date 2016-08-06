# if Meteor.isServer
#   Meteor.methods
#     testSum: ->
#       t = Transactions.find({},{amount: 1}).fetch()
      

# Template.test.helpers
#   foo: () ->
#     # ...
if Meteor.isClient
  Session.set("Mongol", {
    # 'collections': ['List', 'Your', 'Collections'],
    'display': false,
    # 'opacity_normal': ".7",
    # 'opacity_expand': ".9",
  })