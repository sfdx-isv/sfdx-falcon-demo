({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * doInit - Initialize component attributes.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  doInit : function(component, event, helper) {

    console.log('VMC: doInit has been called for DWOrderForm.cmp');

    // Perform Server Call 

    console.log('VMC: Value of symbolSearchEnabled is -->' + component.get('v.symbolSearchEnabled'));

    // Get a local instance of DWOrderForm_Controller.serverSymbolSearchEnabled
    var serverAction = component.get('c.serverSymbolSearchEnabled');

    // Create a callback that is executed after the server-side action returns
    serverAction.setCallback(this, function(response) {
      console.log('VMC: The callback function has been called66');
      var state = response.getState();
      if (state === 'SUCCESS') {
        console.log('VMC: Call to Apex controller was SUCCESSFUL.  Return Value is: ' + response.getReturnValue());
        component.set('v.symbolSearchEnabled', response.getReturnValue());
      }
      
      else if (state === 'INCOMPLETE') {
        console.log('VMC: Call to Apex controller was INCOMPLETE.');
      }
      
      else if (state === 'ERROR') {
        console.log('VMC: Call to Apex controller returned ERROR');
      }

      console.log('VMC: Deeper in the callback function66.');      
    });

    console.log('VMC: Before calling enqueueAction');
    // Add the server-side action to the queue
    $A.enqueueAction(serverAction);

    console.log('VMC: After calling enqueueAction');

  }
})
