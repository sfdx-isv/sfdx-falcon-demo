({
    log: function(component, helper, message){
        if(component.get('v.debugClient')) {
            console.log(message);
        }
    }
})