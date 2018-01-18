({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * doInit  - Get info for the current account. The helper getAccountInfo() will make an Apex call
  *           to get the information and will then either show the order wizard or the "no account"
  *           message, prompting the user to create a DW account.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  doInit: function (component, event, helper) {
    console.log('VMC27: DWCreateMarketOrder - doInit just called.');
    helper.getAccountInfo(component, helper);
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleEvtOrderCreated  - When an order is created, show a special "Order Created" message.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleEvtOrderCreated: function (component, event, helper) {
    console.log('VMC28: handleEvtOrderCreated was just called.  Event: ' + event);
    component.find('utils').log('Handling EvtOrderCreated Event: ' + event);

    // Change the v.orderFormHeaderText back to "Step One: Choose Financial Instrument"
    component.set('v.orderFormHeaderText', 'Order Created');
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleEvtAccountCreated  - After a DW Account is created, make the Order Form ready for use.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleEvtAccountCreated: function (component, event, helper) {
    // Update the Account object that is local to this component with the one
    // that is embedded in the event we just caught.
    component.set('v.acc', event.getParam('account'));

    // Allow Orders
    component.set('v.allowOrders', true);
    
    //Show Search Symbol Form
    helper.showSearchSymbolForm(component, helper);

    //Hide/Destroy market order form
    helper.hideCreateMarketOrderForm(component, helper);
    
    // Apply the "flashDWPanel" style to the orderFormContainer div.
    $A.util.addClass(component.find('orderFormContainer'), 'flashDWPanel');

    // After a short delay, remove the 'flashDWPanel' style to the orderFormContainer div.
    // If this style is NOT removed, the Order Panel will re-flash every time the user
    // clicks between the DriveWealth tab and another tab and back again.
    window.setTimeout(
      $A.getCallback(function() {
        $A.util.removeClass(component.find('orderFormContainer'), 'flashDWPanel');
        console.log('VMC77: Removed flashDWPanel after 5sec setTimeout');
      }), 3000
    );

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleEvtInstrumentInfo  - Catches when the user clicks the "Place Order" button inside the 
  *                            results row of the Order Form's "symbol search" table.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleEvtInstrumentInfo: function (component, event, helper) {
    component.find('utils').log('Handling EvtInstrumentInfo Event: ', event);

    //Instrument information will be used when order form is built
    component.set('v.instrument', event.getParam("instrument"));

    helper.showCreateMarketOrderForm(component, helper);
    helper.hideSearchSymbolForm(component, helper);

    // Enable the "Start Again" button.
    component.find('StartAgainButton').set('v.disabled', false);

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * searchSymbol  - Shows the Search Symbol form and hides the Order Form.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  searchSymbol: function (component, event, helper) {
    // Show symbol search form
    helper.showSearchSymbolForm(component, helper);

    // Hide/Destroy market order form
    helper.hideCreateMarketOrderForm(component, helper);

    // Enable the "Start Again" button.
    component.find('StartAgainButton').set('v.disabled', true);
  }
})