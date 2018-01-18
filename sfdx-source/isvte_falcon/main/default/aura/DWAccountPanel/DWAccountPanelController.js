({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * doInit - Initialize component attributes.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  doInit : function(component, event, helper) {
    console.log("DW: doInit has been called for DWAccountPanel.cmp");

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * toggleAccountPanel - Opens and closes the account info (or account signup) panel.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  toggleAccountPanel : function(component, event, helper) {
    var panelButton = event.getSource();
    var accountPanel = component.find("AccountPanel");

    // Toggle the panel.
    $A.util.toggleClass(accountPanel, "slds-is-open");

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
    // ????
    var eventParams         = event.getParams();
    var accountPanelHeader  = component.find("AccountPanelHeader");

    if (eventParams.changeType === "LOADED") {
      // record is loaded (render other component which needs record data value)
      console.log("DW: DWAccountPanel.Record is loaded successfully.");

      // Choose message for panelTitle based on whehter or not a value exists in 
      // the DW_User_ID__c field from the associated Account record.
      var panelTitle = component.get("v.simpleRecord.DW_User_ID__c") 
                          ? "DriveWealth Configured"
                          : "DriveWealth Not Configured";
    
      component.set("v.panelTitle", panelTitle);
      
    } 
    else if (eventParams.changeType === "CHANGED") {
      // record is changed
      console.log("DW: The Account record tracked by the forceRecord component was changed.");
      component.find("forceRecord").reloadRecord();
    } 
    else if(eventParams.changeType === "REMOVED") {
        // record is deleted
    } 
    else if(eventParams.changeType === "ERROR") {
        // there’s an error while loading, saving, or deleting the record
    }
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * handleEvtAccountCreated - After a DriveWealth Account is created, changes the title and color
  *                           of Account Panel Header and closes the panel itself to hide the DW
  *                           accont info form.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  handleEvtAccountCreated : function(component, event, helper) {
    // Debug
    console.log('DW12: handleEvtAccountCreated was just called');

    // Get component references for later use.
    var accountPanelHeader  = component.find("AccountPanelHeader");
    var accountPanel = component.find("AccountPanel");

    // Change text in header to "DriveWealth Configured"
    component.set("v.panelTitle", "DriveWealth Configured");

    // Change color of header to green.
    $A.util.removeClass(accountPanelHeader, "statusRed");
    $A.util.addClass(accountPanelHeader, "statusGreen");

    // Toggle the Account Panel (this should close it)
    $A.util.toggleClass(accountPanel, "slds-is-open");
    
    // Toggle the panel's button icon. (this should make it point right)
    accountPanelHeader.set("v.iconName", 
                    accountPanelHeader.get("v.iconName") == "utility:chevrondown" ?
                        "utility:chevronright" : "utility:chevrondown");

  }

})
