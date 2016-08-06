#  simple-todos.js
# Transactions = new Mongo.Collection("transactions")
# AccountsCol = new Mongo.Collection("accounts")

Meteor.methods
  foo: ->
    all_tmp = Transactions.find({}).fetch()
    sum_tmp = 0
    sum_tmp += parseFloat(i_tmp.amount) for i_tmp in all_tmp when i_tmp.isDebit is true
    return sum_tmp

if Meteor.isServer
  Meteor.publish  "allTransactions", ->
    [ Transactions.find({}, {sort: {entryDate: 1}}), AccountsCol.find() ]

if (Meteor.isClient)
  # Meteor.subscribe "allTransactions"

  ## Datepicker
  # @picker = new Pikaday({ field: document.getElementById('entryDate') })

# This code only runs on the client
  # Session.set "transactions", [
  #   {id: 1, isCash: true, 'account': 'A/c 1', amount: '123.00', isDebit: true, entryDate: '11/12/2014'}
  #   {id: 2, isCash: true, 'account': 'A/c 2', amount: '234.00', isDebit: false, entryDate: '12/12/2014'}
  #   {id: 3, isCash: false, 'account': 'A/c 3', amount: '345.00', isDebit: true, entryDate: '13/12/2014'}
  #   # {id: 1, honorific: 'Mr', firstname: "sayan", title: "chakrabarti"}
  #   # {id: 2, honorific: 'Miss',firstname: "basuri",title: "das"}
  #   # {id: 3, honorific: 'Master', firstname: "gombhu", title: "kutuya"}
  # ]

  Template.cbTable.helpers
    tableData: ->

      # console.log Session.get "transactions"
      transactions = Transactions.find({}).fetch()
      # transactions = [
      #   {id: 1, isCash: true, 'account': 'A/c 1', amount: '123.00', isDebit: true, entryDate: '11/12/2014'}
      #   {id: 2, isCash: true, 'account': 'A/c 2', amount: '234.00', isDebit: false, entryDate: '12/12/2014'}
      #   {id: 3, isCash: false, 'account': 'A/c 3', amount: '345.00', isDebit: true, entryDate: '13/12/2014'}
      # ]
      # console.log transactions
      debitsArr = []
      creditsArr = []
      trows = []
      colTotals =
        debit:
          bank: 0.00
          cash: 0.00
        credit:
          bank: 0.00
          cash: 0.00
      balance =
        bank:
          isDebit: null
          amount: 0.00
        cash:
          isDebit: null
          amount: 0.00


      for item in transactions
        (if item.isDebit then debitsArr else creditsArr).push item

      maxi = Math.max(debitsArr.length, creditsArr.length)

      for idx in [0...maxi]
        # console.log maxi, idx
        trow =
          debit:
            entryDate: null
            account: null
            narration: null
            amount:
              cash: null
              bank: null
            contra: null
          credit:
            entryDate: null
            account: null
            narration: null
            amount:
              cash: null
              bank: null
            contra: null

        if debitsArr[idx]?
          trow.debit.contra = debitsArr[idx].isContra
          trow.debit.entryDate = moment(debitsArr[idx].entryDate).format('DD/MM/YYYY')
          trow.debit.narration = debitsArr[idx].narration
          trow.debit.account = debitsArr[idx].account.name ? debitsArr[idx].account
          ## ^^ for Contra entries, the account field is a String, and not an object
          if debitsArr[idx].isCash
            trow.debit.amount.cash = accounting.formatNumber accounting.formatNumber debitsArr[idx].amount
            colTotals.debit.cash += parseFloat(debitsArr[idx].amount)
          else
            trow.debit.amount.bank = accounting.formatNumber debitsArr[idx].amount
            colTotals.debit.bank += parseFloat(debitsArr[idx].amount)

        if creditsArr[idx]?
          trow.credit.contra = creditsArr[idx].isContra
          trow.credit.entryDate = moment(creditsArr[idx].entryDate).format('DD/MM/YYYY')
          trow.credit.narration = creditsArr[idx].narration
          trow.credit.account = creditsArr[idx].account.name ? creditsArr[idx].account
          ## ^^ for Contra entries, the account field is a String, and not an object
          if creditsArr[idx].isCash
            trow.credit.amount.cash = accounting.formatNumber creditsArr[idx].amount
            colTotals.credit.cash += parseFloat(creditsArr[idx].amount)
          else
            trow.credit.amount.bank = accounting.formatNumber creditsArr[idx].amount
            colTotals.credit.bank += parseFloat(creditsArr[idx].amount)
        # console.log colTotals
        trows.push trow

      ## Calculate a/c balances
      balance.bank.amount = accounting.formatNumber Math.abs( colTotals.debit.bank - colTotals.credit.bank )
      balance.cash.amount = accounting.formatNumber Math.abs( colTotals.debit.cash - colTotals.credit.cash )

      balance.bank.isDebit = (colTotals.debit.bank >= colTotals.credit.bank)
      balance.cash.isDebit = (colTotals.debit.cash >= colTotals.credit.cash)

      ## number format the colTotals for display
      colTotals.debit.bank = accounting.formatNumber colTotals.debit.bank
      colTotals.debit.cash = accounting.formatNumber colTotals.debit.cash
      colTotals.credit.bank = accounting.formatNumber colTotals.credit.bank
      colTotals.credit.cash = accounting.formatNumber colTotals.credit.cash

      Meteor.call 'foo', (err, result)-> Session.set 'test', result
      return { trows: trows, colTotals: colTotals, balance: balance, test: Session.get 'test' }


      # console.log if Session.get "cb_isContraChecked" then "disabled" else ''
      # if Session.get "cb_isContraChecked" then "disabled" else ''


########## cbAddForm stuff ################
  Template.cbAddForm.helpers
    isContraChecked: ->
      Session.get "cb_isContraChecked"

    accountList: ->
      AccountsCol.find({},{sort: {accountClass: 1, name: 1}}) #.fetch()
      # ...
#   {id: 1, isCash: true, 'account': 'A/c 1', amount: '123.00', isDebit: true, entryDate: '11/12/2014'}

  Template.cbAddForm.events
    'submit form': (evt) ->
      # alert evt.target.entryDate.value + '-----'
      evt.preventDefault()
      # console.log AccountsCol.findOne evt.target.account_id.value
      newTransaction =
        isCash: !!parseInt(evt.target.isCash.value)
        isDebit: !!parseInt(evt.target.isDebit.value)
        isContra: !!evt.target.isContra.checked
        amount: evt.target.amount.value
        entryDate:
          if evt.target.entryDate.value isnt ''
            moment(evt.target.entryDate.value, 'DD/MM/YYYY').toDate()
          else
            moment().toDate()
        # entryDate: moment(evt.target.entryDate.value, 'DD/MM/YYYY').toDate() || moment().toDate()
        narration: evt.target.narration.value
        # account: AccountsCol.findOne parseInt(evt.target.account_id.value, 10)
        account:
          if evt.target.isContra.checked
            if !!parseInt(evt.target.isCash.value) then "Bank" else "Cash"
          else
            AccountsCol.findOne evt.target.account_id.value

      if newTransaction.amount ## prevent blank entries
        if newTransaction.isContra
          newTransaction.contraLinkID = uuid() # Useful for deleting
          Session.set "cb_isContraChecked", false
        Transactions.insert newTransaction, evt.target.reset(); evt.target.isDebit.focus()
      else
        alert "Please Enter Amount"
        evt.target.amount.focus()

      ## Auto enter contra entry for isContra
      if newTransaction.isContra
        contraTransaction =
          isCash: not newTransaction.isCash
          isDebit: not newTransaction.isDebit
          isContra: true
          contraLinkID: newTransaction.contraLinkID # Useful for deleting
          amount: newTransaction.amount
          entryDate: newTransaction.entryDate
          narration: newTransaction.Narration
          account: if newTransaction.account is "Bank" then "Cash" else "Bank"

        Transactions.insert contraTransaction


    'change #isContra': (evt) ->
      Session.set "cb_isContraChecked", evt.target.checked


  Template.cbAddForm.rendered = ->
    # if Meteor.userId?
    picker = new Pikaday
      field: document.getElementById('entryDate')
      trigger: document.getElementById('pickDate')
      format: 'DD/MM/YYYY'

