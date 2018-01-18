({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * toggleSymbolSearchPanel - Opens and closes the Symbol Search Panel.
  * NOTE: There is likely a more graceful way of creating a single "togglePanel" handler method.
  *       for the sake of speed, I'm doing this the ugly, stupid way for now.
  *       TODO: Come make this better someday.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  toggleSymbolSearchPanel : function(component, event, helper) {
    var panelButton = event.getSource();
    var symbolSearchPanel = component.find("SymbolSearchPanel");
    // Toggle the panel.
    $A.util.toggleClass(symbolSearchPanel, "slds-is-open");
    // Toggle the panel's button icon.
    panelButton.set("v.iconName", 
                    panelButton.get("v.iconName") == "utility:chevrondown" ?
                        "utility:chevronright" : "utility:chevrondown");
  }
})
