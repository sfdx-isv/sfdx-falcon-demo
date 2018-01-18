({
    showModal: function(component, event, helper) {
        var modalShell = component.find("modalShell");
        var modalBackdrop = component.find("modalBackDrop");

        // Read Event Params of ShowModal Event.
        var modalTitle = event.getParam("title");
        if (!$A.util.isEmpty(modalTitle)) {
            component.set("v.title", modalTitle);
        }
        var modalTagline = event.getParam("tagline");
        if (!$A.util.isEmpty(modalTagline)) {
            component.set("v.tagline", modalTagline);
        }
        var componentName = event.getParam("componentName");
        if (!$A.util.isEmpty(componentName)) {
            var componentParams = event.getParam("componentParams");

            if ($A.util.isEmpty(componentParams)) {
                componentParams = {};
            }

            // Inject Component
            $A.createComponent(
                componentName,
                componentParams,
                function(modalContent) {
                    console.log(modalContent);
                    component.set('v._modalContent', modalContent);
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(modalContent);
                        component.set("v.body", body);
                    }
                    $A.util.addClass(modalShell, 'slds-fade-in-open');
                    $A.util.addClass(modalBackdrop, 'slds-backdrop--open');
                });
        }
    },
    hideModal: function(component, event, helper) {
        var modalShell = component.find("modalShell");
        var modalBackdrop = component.find("modalBackDrop");
        $A.util.removeClass(modalShell, 'slds-fade-in-open');
        $A.util.removeClass(modalBackdrop, 'slds-backdrop--open');


        if (component.get('v._modalContent') != null) {
            component.get('v._modalContent').destroy(true);
        }
    }
})