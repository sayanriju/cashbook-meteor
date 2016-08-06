@Transactions = new Mongo.Collection("transactions")
@AccountsCol = new Mongo.Collection("accounts")

# Accounts.ui.config
  # passwordSignupFields: "USERNAME_ONLY"
# Accounts.config
  # forbidClientAccountCreation: false


if (Meteor.isClient)
  Accounts.config
    forbidClientAccountCreation: false

  ## default settings for accounting.js package
  @accounting.settings =
    number:
      precision: 2
      thousand: ","
      decimal : "."


  # Template.body.helpers
  #   whichTemplate: ->
  #     # return 'test0'
  #     navLinks = Session.get "navLinks"  ## set in navbars.coffee within views/shared
  #     return link.text.toLowerCase() for link in navLinks when link.active is true
  #     # console.log navLinks

Router.configure
  layoutTemplate: "appLayout"
  loadingTemplate: "spinner"

