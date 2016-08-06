## Using Iron Router
# Router.map () ->
#   @route 'cashbook', {
#     path: '/cashbook'
#     data:
#       'pageTitle': "Cashbook"
#     }

#   @route 'ledger', {
#     path: '/ledger'
#     date:
#       'pageTitle': "Ledger"
#     }

#   @route 'accounts', {
#     path: '/accounts'
#     date:
#       'pageTitle': "Accounts Chart"
#     }

@CashbookController = RouteController.extend
  waitOn: -> Meteor.subscribe "allTransactions"
  action: -> @render 'cashbook'

Router.route "/",
  controller: "CashbookController"


Router.route "/cashbook",
  name: "cashbook"
  # controller: "CashbookController"

Router.route "/ledger",
  waitOn: -> Meteor.subscribe "allTransactions"
  action: -> @render 'ledger'

Router.route "/accounts",
  waitOn: -> Meteor.subscribe "allAccounts"
  action: -> @render 'accounts'

Router.route "/test/:arg"
, ->
  arg = @params.arg
  # console.log arg
  @render 'test',
    data:
      id: arg
,
  name: 'routename'

