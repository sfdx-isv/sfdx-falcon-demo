({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * getOrderList - Makes a server call to fetch a list of orders associated with the Account
  *                specified by the recordId attribute of the component.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  getOrderList: function (component, helper) {
    // Use the ApexBridge library for this server call.
    var apexBridge = component.find("ApexBridge");

    // Make the call using Apex Bridge.
    apexBridge.callApex({
      component: component,
      data: {
        operation: "DWOrderList_Controller",        // Apex class being called
        input: {
          AccountID: component.get('v.recordId'),   // Apex method parameter
          mode: 'getOrders'                         // Apex method being called
        }
      },
      callBackMethod: function (data) {
        console.log('DW: Callback method executed after Apex server call return. Return data--->' + JSON.stringify(data));
        //component.set('v.orders', JSON.parse(data.output)); // TODO: Delete if unused

        // Check if the Apex call returned any data.
        if ($A.util.isUndefined(data.output) || data.output.length <= 0) {
          // No data was returned, meaning that there are no previous orders.
          var message = Array();
          message.push(
            ["ui:message", {
              'severity': 'information',
              'body': 'There are no previous orders'
            }]
          );

          // Set the v.orders array to empty and indicate that this account
          // does not have any order history.
          component.set('v.orders', []);
          component.set('v.hasOrderHistory', false);

          // Use the utils library to create and place a UI Message.
          component.find('utils').createComponents(message, component.find('uiMessage'));

          // Debug
          console.log('VMC77: No order history found by the Apex getOrders method');

        } 
        else {
          // There was at least one order previously placed for this account.
          var orders = [], key;

          // Manually inspect and transform order history data records.
          // TODO: Find out why this is being done.
          for (key in data.output) {
            data.output[key].Executed_When__c = (data.output[key].Executed_When__c == 'Not Executed') 
                                                ? '' 
                                                : helper.dateFromSpecialString(data.output[key].Executed_When__c);
            orders.push({ value: data.output[key], key: key });
          }

          // Debug
          component.find('utils').log('DWOrderStatus.orders: ', orders);
          console.log('VMC77: Order history found-->' + JSON.stringify(orders));


          // Store the transformed orders in the v.orders array attribute.
          component.set('v.orders', orders);

          // Clear any pre-existing "no orders" UI Messages.
          component.find('utils').destroyComponents(component.find('uiMessage'));

          // One last check of number of orders in the array.  It's possible to
          // get here with an empty array,
          if (orders.length > 0) {
            // Set the value of v.hasOrderHistory to TRUE. This should trigger
            // other UI changes (like hiding the "No DW Orders Found" message).
            component.set('v.hasOrderHistory', true);

          }
          else {
            component.set('v.hasOrderHistory', false);
          }


        }
      }
    });
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * dateFromSpecialString - Helper function that converts date into a human-readable format.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  dateFromSpecialString: function(str) {
        try {
            var dateObject = new Date(Date.parse(str));

            return dateObject.toDateString();
        }catch(err){}
        return str;
    },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * fetchStatus - Connects to DriveWealth to fetch the status of a specific DW order.
  *               TODO: There are some possible bugs here.  Results we get back from DW usually
  *                     just say "Invalid Date".
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  fetchStatus: function(component, helper, orderIndex){
    // Get a reference to the currently held orders array attribute.
    var orders = component.get('v.orders');

    // Use the ApexBridge library for this server call.
    var apexBridge = component.find("ApexBridge");

    // Make the call using the Apex Bridge library
    apexBridge.callApex({
      component: component,
      data: {
        operation: "DWOrderList_Controller",
        input: {
          OrderID: orders[orderIndex].key,
          AccountID: component.get('v.recordId'),
          mode: 'fetchStatus'
        }
      },
      callBackMethod: function (data) {
        component.find('utils').log('fetchStatus.data: ', data);
        //component.set('v.orders', data.output);

        if (data.output.length <= 0 || data.output.code != null) {
          var message = Array();
          message.push(
            ["ui:message", {
              'severity': 'error',
              'body': 'Some error occured while fetching status'
            }]
          );

          component.find('utils').createComponents(message, component.find('uiMessage'));
        } else {


          var orders = component.get('v.orders');
          orders[orderIndex].value.Order_Status__c = data.output.ordStatus;
          orders[orderIndex].value.Executed_When__c = (data.output.Executed_When__c == 'Not Executed') ? '' : helper.dateFromSpecialString(data.output.Executed_When__c);
          component.set('v.orders', orders);

          component.find('utils').destroyComponents(component.find('uiMessage'));
        }
      }
    });
  }
})