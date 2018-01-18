/**
 * Created by viyer on 3/2/17.
 */
({
    createAccount: function(component, event, helper) {
        console.log("VMC: createAccount was just triggered.");
        helper.createAccount(component, helper);
    },
    doInit : function(component, event, helper) {
        helper.getAccountInfo(component, helper);
    },
    handleRecordUpdate: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            component.find('utils').log("DWCreateAccountForm.Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {

            // record is changed
            component.find("forceRecord").reloadRecord();
            helper.getAccountInfo(component, helper);

        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})