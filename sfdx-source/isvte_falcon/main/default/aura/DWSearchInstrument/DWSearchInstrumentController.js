({
    doInit: function(component, event, helper) {
       
    },
    searchSymbol: function(component, event, helper) {
        helper.searchSymbol(component, helper);
    },
    placeOrder: function(component, event, helper){
        var data = event.getSource().get("v.value");
        var evt = component.getEvent('EvtInstrumentInfo');
        evt.setParams({
            "instrument": data,
            "context": "DWSearchInstrument.cmp"
        });
        component.find('utils').log('Firing EvtInstrumentInfo Event: ' + evt);
        evt.fire();

    }
})