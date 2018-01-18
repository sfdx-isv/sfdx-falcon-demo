({
    isValid: function(component, helper) {
        var message = Array(), retVal = true;

        var fname= component.get('v.fname');
        var lname = component.get('v.lname');
        var uname= component.get('v.uname');
        var passwd = component.get('v.passwd');
        var email = component.get('v.simpleRecord').DW_Email__c;

        //If account is not selected then show an error
        if($A.util.isEmpty(fname)) {
            message.push(
                ["markup://ui:message", {
                    'severity': 'error',
                    'body': 'Please select an First Name'
                }]
            );
        }

        if($A.util.isEmpty(email)){
            message.push(
                ["markup://ui:message", {
                    'severity': 'error',
                    'body': 'Please make sure that this account has an email address'
                }]
            );
        }

        if($A.util.isEmpty(lname)){
            message.push(
                ["markup://ui:message", {
                    'severity': 'error',
                    'body': 'Please select an Last Name'
                }]
            );
        }
        if($A.util.isEmpty(uname)){
            message.push(
                ["markup://ui:message", {
                    'severity': 'error',
                    'body': 'Please select an User Name'
                }]
            );
        }
        if($A.util.isEmpty(passwd) || passwd.length<=8 || passwd.length>=90){
            message.push(
                ["markup://ui:message", {
                    'severity': 'error',
                    'body': 'Password must be more than 8 characters and less than 90 characters.'
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
    fireEvtAccountCreated: function(component, helper) {
        var data = component.get('v.acc');

        var evt = $A.get("e.c:EvtAccountCreated");
        evt.setParams({
            "account": data,
            "context": "DWCreateAccountform.cmp"
        });

        component.find('utils').log('Firing EvtAccountCreated Event: ' + evt);

        console.log("VMC-About to fire the EvtAccountCreated event." + evt + "<----EVENT");

        evt.fire();
    },
    createAccount: function(component, helper) {

        console.log("VMC: The createAccount helper function just got called.");

        if(helper.isValid(component, helper) && component.isValid()) {

            component.find('utils').toggleSpinner(component.find('spinner'), true);

            var apexBridge = component.find("ApexBridge");

            apexBridge.callApex({
                component: component,
                data: {
                    operation: "DWCreateAccount",
                    input: {
                        acc: component.get('v.acc'),
                        FirstName: component.get('v.fname'),
                        LastName: component.get('v.lname'),
                        UserName: component.get('v.uname'),
                        Password: component.get('v.passwd'),
                        mode: 'createAccount'
                    }
                },
                callBackMethod: function (data) {
                    component.find('utils').log('createAccount.data: ', data);
                    var output = data.output;

                    var message = Array();

                    if(output==null || $A.util.isUndefined(output) || $A.util.isUndefined(output.DW_Accounts__r)){

                        var msg = (typeof(data.messages.Errors) != 'undefined' && typeof(data.messages.Errors[0]) != 'undefined')?data.messages.Errors[0]:'';
                        message.push(
                            ["ui:message", {
                                'severity': 'error',
                                'body': 'Some error occured while creating DriveWealth Account: ' + msg
                            }]
                        );
                    }else{
                        var message = Array();
                        message.push(
                            ["ui:message", {
                                'severity': 'success',
                                'body': 'Account was successfully created'
                            }]
                        );
                        component.set('v.acc', output);

                        $A.util.addClass(component.find('createAccountForm'), 'slds-hide');

                        console.log("VMC-About to call the helper.fireEvtAccountCreated function.");


                        //Fire event to indicate that order has been created
                        helper.fireEvtAccountCreated(component, helper);
                    }
                    component.find('utils').createComponents(message, component.find('uiMessage'));

                    component.find('utils').toggleSpinner(component.find('spinner'), false);

                }
            });
        }
        /**/
    },

    getAccountInfo: function(component, helper) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            data: {
                operation: "DWCreateAccount",
                input: {
                    AccountID: component.get('v.recordId'),
                    mode: 'getAccount'
                }
            },
            callBackMethod: function (data) {
                var acc = data.output;
                component.find('utils').log('DWCreateAccountForm:getAccountInfo().data: ', data);
                component.set('v.acc', acc);


                var message = Array();

                var msg = (typeof(data.messages.Errors) != 'undefined' && typeof(data.messages.Errors[0]) != 'undefined')?data.messages.Errors[0]:'';
                if(msg != '') {

                    message.push(
                        ["ui:message", {
                            'severity': 'error',
                            'body': msg
                        }]
                    );

                    component.find('utils').createComponents(message, component.find('uiMessage'));
                }

            }
        });
    }
})