({
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * isValid  - Checks if the details provided for an order are valid.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  isValid: function(component, helper) {
    var message = Array(), retVal = true;

    //If account is not selected then show an error
    var accountID = component.find('accountID');
    if ((accountID.get('v.validity') != null && accountID.get('v.validity').valueMissing) || accountID.get('v.value') == '') {
      message.push(
        ["ui:message", {
          'severity': 'error',
          'body': 'Please select an Account'
        }]
      );
    }

    //Check if order quantity has been added and >0
    var orderQty = component.find('orderQty');
    if ((orderQty.get('v.validity') != null && orderQty.get('v.validity').valueMissing) || orderQty.get('v.value') <= 0) {
      message.push(
        ["ui:message", {
          'severity': 'error',
          'body': 'Please enter a value >0 for Order Quantity'
        }]
      );
    }

    if (message.length > 0) {
      //Create new components through utility method
      component.find('utils').createComponents(message, component.find('uiMessage'));
      retVal = false;
    } 
    else {
      //Destroy previous components to clear out messages
      component.find('utils').destroyComponents(component.find('uiMessage'));
    }

    return retVal;
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * fireEvtOrderCreated  - Fires an APPLICATION event indicating that an order has been 
  *                        successfully placed.
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  fireEvtOrderCreated: function (component, helper) {
    var data = component.get('v.order');

    var appEvent = $A.get("e.c:EvtOrderCreated");
    appEvent.setParams({
      "order": data,
      "context": "DWCreateMarketOrderForm.cmp"
    });

    component.find('utils').log('Firing EvtOrderCreated Event: ' + appEvent);

    appEvent.fire();
  },
  /*
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * submitOrder  - ?????
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
  submitOrder: function(component, helper) {
        if(helper.isValid(component, helper) && component.isValid()) {

            component.find('utils').toggleSpinner(component.find('spinner'), true);

            var apexBridge = component.find("ApexBridge");
            var instrument = component.get('v.instrument');
            apexBridge.callApex({
                component: component,
                data: {
                    operation: "DWCreateOrder_Controller",
                    input: {
                        acc: component.get('v.acc'),
                        orderInfo: component.get('v.dworder'),
                        mode: 'submitOrder',
                        instrument: JSON.stringify(instrument)
                    }
                },
                callBackMethod: function (data) {
                    component.find('utils').log('submitOrder.data: ', data);
                    var data = data.output;

                    var message = Array();

                    if(data.code != null || typeof(data.orderID) == 'undefined' || $A.util.isUndefined(data.orderID)){
                        message.push(
                            ["ui:message", {
                                'severity': 'error',
                                'body': 'Some error occured while placing order: ' + data.message
                            }]
                        );
                    }else{
                        var message = Array();
                        message.push(
                            ["ui:message", {
                                'severity': 'success',
                                'body': 'Market order was succssfully placed'
                            }]
                        );
                        component.set('v.order', data);

                        $A.util.addClass(component.find('createOrderForm'), 'slds-hide');

                        //Fire event to indicate that order has been created
                        helper.fireEvtOrderCreated(component, helper);
                    }
                    component.find('utils').createComponents(message, component.find('uiMessage'));

                    component.find('utils').toggleSpinner(component.find('spinner'), false);

                }
            });
        }
        /**/
    }
})