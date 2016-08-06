if Meteor.isServer
  Meteor.publish "ledger", ->
    [ Transactions.find({}, {sort: {entryDate: 1}}), AccountsCol.find() ]

if Meteor.isClient

  Template.ledgerChart.helpers

    tableData: ->
      ledger_accountID = Session.get "ledger_accountID"
      # console.log ledger_accountID
      # console.log Session.get "transactions"
      transactions = Transactions.find({'isContra': false, 'account._id': ledger_accountID}).fetch()
      # console.log transactions
      ledgerAcName = AccountsCol.findOne(ledger_accountID)?.name
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
        debit: 0.00
        credit: 0.00
      balance =
        isDebit: null
        amount: 0.00

      for item in transactions
        (if item.isDebit then creditsArr else debitsArr).push item
        ## ^^ Debits and Credits are REVERSED for journal & t-accounts

      maxi = Math.max(debitsArr.length, creditsArr.length)

      for idx in [0...maxi]
        # console.log maxi, idx
        trow =
          debit:
            entryDate: null
            account: null
            narration: null
            amount: null
          credit:
            entryDate: null
            account: null
            narration: null
            amount: null

        if debitsArr[idx]?
          trow.debit.entryDate = moment(debitsArr[idx].entryDate).format('DD/MM/YYYY')
          trow.debit.narration = debitsArr[idx].narration
          trow.debit.account = if debitsArr[idx].isCash then "Cash" else "Bank"
          trow.debit.amount = accounting.formatNumber debitsArr[idx].amount
          colTotals.debit += parseFloat(debitsArr[idx].amount)

        if creditsArr[idx]?
          trow.credit.entryDate = moment(creditsArr[idx].entryDate).format('DD/MM/YYYY')
          trow.credit.narration = creditsArr[idx].narration
          trow.credit.account = if creditsArr[idx].isCash then "Cash" else "Bank"
          trow.credit.amount = accounting.formatNumber creditsArr[idx].amount
          colTotals.credit += parseFloat(creditsArr[idx].amount)


        trows.push trow

      ## Calculate a/c balances
      balance.amount = accounting.formatNumber Math.abs( colTotals.debit - colTotals.credit )
      balance.isDebit = (colTotals.debit >= colTotals.credit)

      ## number format the colTotals for display
      colTotals.debit = accounting.formatNumber colTotals.debit
      colTotals.credit = accounting.formatNumber colTotals.credit


      return { trows: trows, colTotals: colTotals, balance: balance, ledgerAcName: ledgerAcName }


      # console.log if Session.get "cb_isContraChecked" then "disabled" else ''
      # if Session.get "cb_isContraChecked" then "disabled" else ''

  Template.ledgerForm.helpers
    accountList: ->
      AccountsCol.find({},{sort: {accountClass: 1, name: 1}}) #.fetch()


  Template.ledgerForm.events
    'submit form': (evt) ->
      evt.preventDefault()
      Session.set "ledger_accountID", evt.target.account_id.value

