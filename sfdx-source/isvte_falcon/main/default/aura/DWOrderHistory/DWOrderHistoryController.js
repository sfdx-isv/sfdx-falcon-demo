({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * toggleOrderHistoryPanel - Opens and closes the Order History panel.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  toggleOrderHistoryPanel : function(component, event, helper) {
    var panelButton = event.getSource();
    var orderHistoryPanel = component.find("OrderHistoryPanel");
    // Toggle the panel.
    $A.util.toggleClass(orderHistoryPanel, "slds-is-open");
    // Toggle the panel's button icon.
    panelButton.set("v.iconName", 
                    panelButton.get("v.iconName") == "utility:chevrondown" ?
                        "utility:chevronright" : "utility:chevrondown");
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleRecordUpdate - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleRecordUpdate : function(component, event, helper) {
    // Pull event parameters to inspect for data record state.
    var eventParams = event.getParams();

    // Create handler logic for each record status flag.
    if (eventParams.changeType === "LOADED") {
      // record is loaded
      
    } 
    else if (eventParams.changeType === "CHANGED") {
      // record is changed
      component.find("forceRecord").reloadRecord();
    } 
    else if(eventParams.changeType === "REMOVED") {
      // record is deleted
    } 
    else if(eventParams.changeType === "ERROR") {
      // error with record
    }
  }
})
