({
    setSpinner :function(component, event, helper) {
        component.set("v.spinner", component.get('v.spinnerSync'));
    },
})