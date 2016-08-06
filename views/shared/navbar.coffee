if (Meteor.isClient)
  Template.navbar.created = ->
    Session.set "navLinks",  [
      {text: "Cashbook", active: true, url: "/cashbook"}
      {text: "Ledger", active: false, url: "/ledger"}
      {text: "Accounts", active: false, url: "/accounts"}
    ]
    document.title = "Cashbook"

  Template.navbar.helpers
    navLinks: ->
      Session.get "navLinks"

  Template.navbar.events
    'click .navlink': ->
      # Session.set "navlinks", ''
      links = Session.get "navLinks"
      for link in links
        if link.text is @text then link.active = true else link.active = false
      document.title = @text
      Session.set "navLinks", links