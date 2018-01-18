({
    loadAccount : function(component) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            data: {
                operation: "DWCommunityWrapper_Controller",
                input: {
                    mode: 'loadAccount'
                }
            },
            callBackMethod: function (data) {
                component.find('utils').log('loadAccount.data: ', data);
                if(!$A.util.isUndefined(data.output.AccountId)){
                    component.set('v.AccountId', data.output.AccountId)
                }
            }
        });
    }
})