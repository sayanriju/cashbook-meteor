if (Meteor.isClient)

  Session.set "navLinks",  [
    {text: "Cashbook", active: true}
    {text: "Ledger", active: false}
    {text: "Accounts", active: false}
  ]
  Template.navbar.helpers
    navLinks: ->
      Session.get "navLinks"

  Template.navbar.events
    'click .navlink': ->
      ## Set the active navlink
      links = Session.get "navLinks"
      for link in links
        if link.text is @text then link.active = true else link.active = false
      Session.set "navLinks", links
      ## Load the appropriate views