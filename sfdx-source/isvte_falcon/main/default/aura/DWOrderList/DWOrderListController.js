({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * doInit - Initialize component by getting a list of any DW Orders associated with this account.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  doInit: function (component, event, helper) {
    helper.getOrderList(component, helper);
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * fetchStatus - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */    
  fetchStatus: function (component, event, helper) {
    var orderIndex = event.getSource().get('v.value');
    helper.fetchStatus(component, helper, orderIndex);
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleEvtOrderCreated - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleEvtOrderCreated: function (component, event, helper) {
    // Debug
    console.log('VMC: DWOrderList.handleEvtOrderCreated was called.');

    //New order is created so refresh the list
    helper.getOrderList(component, helper);
  }
})