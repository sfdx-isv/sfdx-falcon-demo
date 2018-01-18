({
    isValid: function(component, helper) {
        var message = Array(), retVal = true;

    //Check if order quantity has been added and >0
        var field = component.find('symbol');
        if( (field.get('v.validity') != null && field.get('v.validity').valueMissing)  || field.get('v.value')=='') {
            message.push(
                ["ui:message", {
                    'severity': 'error',
                    'body': 'Please enter a symbol to search'
                }]
            );
        }

        if(message.length > 0){
            //Create new components through utility method
            component.find('utils').createComponents(message, component.find('uiMessage'));
            retVal = false;
        }else{
            //Destroy previous components to clear out messages
            component.find('utils').destroyComponents(component.find('uiMessage'));
        }

        return retVal;
    },
    searchSymbol: function(component, helper) {
        if(helper.isValid(component, helper) && component.isValid()) {
            //Spinner when searching for symbol
            component.find('utils').toggleSpinner(component.find('spinner'), true);

            var apexBridge = component.find("ApexBridge");
            apexBridge.callApex({
                component: component,
                data: {
                    operation: "DWSearchInstrument_Controller",
                    input: {
                        symbol: component.get('v.symbol'),
                        AccountID: component.get('v.recordId'),
                        mode: 'searchInstrument'
                    }
                },
                callBackMethod: function (data) {
                    component.find('utils').log('searchInstrument.data: ', data);
                    if(data.output.length <=0 ){
                        var message = Array();
                        message.push(
                            ["ui:message", {
                                'severity': 'error',
                                'body': 'Some error occured while searching for symbol'
                            }]
                        );

                        component.find('utils').createComponents(message, component.find('uiMessage'));
                        
                        component.set('v.instrumentList', null);
                    }else{

                        component.set('v.instrumentList', data.output);

                        component.find('utils').destroyComponents(component.find('uiMessage'));
                    }

                    component.find('utils').toggleSpinner(component.find('spinner'), false);
                }
            });
        }
        /**/
    }
})