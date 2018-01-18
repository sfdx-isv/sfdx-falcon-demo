/**
 * Created by jrattanpal on 1/18/17.
 */
({
    log: function(component, event, helper){
        var params = event.getParam('arguments');
        if (params) {
            //var message = params.message;
            helper.log(component, helper, params);
        }
    },
    createComponents: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var componentsToCreate = params.componentsToCreate;
            var componentPlaceholder = params.componentPlaceholder;

            $A.createComponents(componentsToCreate,
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        // set the body of the ui:message to be the ui:outputText
                        componentPlaceholder.set("v.body", components);
                    }
                    else if (status === "INCOMPLETE") {
                        helper.log(component, helper, "No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        helper.log(component, helper, {"Error: ": errorMessage});
                    }
                }
            );
        }
    },
    createComponent: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var componentToCreate = params.componentToCreate;
            var componentParams = params.componentParams;
            var componentPlaceholder = params.componentPlaceholder;

            $A.createComponent(componentToCreate, componentParams,
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        // set the body of the ui:message to be the ui:outputText
                        componentPlaceholder.set("v.body", components);
                    }
                    else if (status === "INCOMPLETE") {
                        helper.log(component, helper, "No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        helper.log(component, helper, {"Error: ": errorMessage});
                    }
                }
            );
        }
    },
    destroyComponents: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var componentPlaceholder = params.componentPlaceholder;
            componentPlaceholder.set("v.body", []);
        }
    },
    toggleSpinner: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var spinner = params.spinnerComponent;
            var isVisible = params.isVisible;
            var evt = spinner.get("e.toggle");

            evt.setParams({'isVisible': isVisible});
            evt.fire();

        }
    }

})