({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * getAccountInfo  - Initializes the order form area by either...
  *                   1. Showing the symbol lookup component.
  *                   2. Showing the financial instrument order form.
  *                   3. Showing the "You must create a DW account" message.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */    
  getAccountInfo: function (component, helper) {
    var apexBridge = component.find("ApexBridge");
    apexBridge.callApex({
      component: component,
      data: {
        operation: "DWCreateOrder_Controller",
        input: {
          AccountID: component.get('v.recordId'),
          mode: 'getAccount'
        }
      },
      callBackMethod: function (data) {
        // Expected return from the server method is an Account record.
        var acc = data.output;
        
        // ────────────────────────────────────────────────────────────────────┐
        // Determine if the account that this component is attached to could
        // be successfully found AND that it has a list of related DW_Account__c 
        // records.
        // NOTE: This was designed to someday support the ability for one 
        //       SFDC account to use multiple DriveWealth accounts.  As of
        //       January 2018, the actual design in place is one DW account per
        //       SFDC account.
        // ────────────────────────────────────────────────────────────────────┘
        if ($A.util.isUndefined(acc) || $A.util.isUndefined(acc.DW_Accounts__r)) {
          console.log('VMC24: No DW Accounts found.  Disallow the Market Order form.');

          // Disallow Market Orders
          component.set('v.allowOrders', false);

        } 
        else {
          console.log('VMC: At least one DW Account was found. Allow Market Order form.');


          console.log('VMC58: The value of v.acc inside of getAccountInfo()-->' + JSON.stringify(acc));


          // Allow Orders
          component.set('v.allowOrders', true);
          
          // Bind the returned account to the local "acc" attribute.
          component.set('v.acc', acc);

          //Show Search Symbol Form
          helper.showSearchSymbolForm(component, helper);

          //Hide/Destroy market order form
          helper.hideCreateMarketOrderForm(component, helper);
          
        }
      }
    });
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * showSearchSymbolForm  - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */    
  showSearchSymbolForm: function (component, helper) {
    // Build the search instrument component.
    var cmpArr = Array();
    cmpArr.push(
      ["c:DWSearchInstrument",
        {
          debug: component.get('v.debug'),
          debugClient: component.get('v.debugClient'),
          recordId: component.get('v.recordId'),
          allowOrderPlacement: true,
          showHeader: false
        }
      ]
    );

    // Use the utils library to create the component.
    component.find('utils').createComponents(cmpArr, component.find('searchSymbol'));

    // Reset instrument data to search again
    component.set('v.instrument', null);

    // Update the title of the Order Form Header.
    component.set('v.orderFormHeaderText', 'Step One: Choose Financial Instrument');

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * hideSearchSymbolForm  - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */    
  hideSearchSymbolForm: function (component, helper) {
    // Kill the "search symbol" form
    component.find('utils').destroyComponents(component.find('searchSymbol'));

    // Update the title of the Order Form Header.
    component.set('v.orderFormHeaderText', 'Step Two: Specify Order Details');

    // DEV-DEBUG: Can be deleted before going to production.
    console.log("VMC: The order form title should now be different");

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * showCreateMarketOrderForm  - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  showCreateMarketOrderForm: function (component, helper) {
    // Array var that will hold the components we want to create.
    var cmpArr = Array();

    // Workaround for strange bug where related records are not loaded the first time.
    var acc = component.get('v.acc');

    // Define component and add to the array.
    cmpArr.push(
      ["c:DWCreateMarketOrderForm",
        {
          debug:        component.get('v.debug'),
          debugClient:  component.get('v.debugClient'),
          instrument:   component.get('v.instrument'),
          acc:          component.get('v.acc'),
          //Workaround for strange bug where related records are not loaded the first time
          dwAccRecords: acc.DW_Accounts__r.records
        }
      ]
    );

    component.find('utils').log('cmpArr:', cmpArr);
    component.find('utils').createComponents(cmpArr, component.find('createMarketOrderForm'));

    // Update the title of the Order Form Header.
    component.set('v.orderFormHeaderText', 'Totally Tubular!');    

  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * hideCreateMarketOrderForm  - ????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  hideCreateMarketOrderForm: function (component, helper) {
    component.find('utils').destroyComponents(component.find('createMarketOrderForm'));
  }
})