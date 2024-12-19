({
    /**
     * @description It evaluates changed fields received from recordData
     * and display the banner message accordingly.
     **/
    validateChangedFields: function (component, changedFields, helper) {
        if (changedFields) {
            var formatter = new Intl.DateTimeFormat('en-US', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
            var fieldsToListen = $A.get("$Label.c.Fields_To_Listen_Work_Plan_Update");
            var shouldSkip = false;
            Object.keys(changedFields).forEach(function (eachKey) {
                if (shouldSkip) {
                    return;
                }
                // old value check is required for preventing unexpected toast message on inline edit
                if (fieldsToListen.includes(eachKey)
                    && Object.prototype.hasOwnProperty.call(changedFields[eachKey], "value")
                ) {

                    shouldSkip = true;
                    if (changedFields[eachKey].value === 'Completed') {
                        helper.showToast($A.get("$Label.c.Activation_Checklist_Validation_Success") + ' ' + formatter.format(new Date()), $A.get("$Label.c.Toast_Variant_Success"));
                        helper.notifyActivationChecklist(component);
                    } else if (changedFields[eachKey].value === 'In Progress') {
                        helper.showToast($A.get("$Label.c.Activation_Checklist_Validation_In_progress"), $A.get("$Label.c.Toast_Variant_Warning"));
                        helper.notifyActivationChecklistInProgress(component);
                    } else if (changedFields[eachKey].value === 'Escalated') {
                        helper.showToast($A.get("$Label.c.Activation_Checklist_Validation_Success") + ' ' + formatter.format(new Date()), $A.get("$Label.c.Toast_Variant_Success"));
                        helper.notifyActivationChecklist(component);
                    }
                }
            });
        }
    },

    /**
     * @description To display the banner message.
     **/
    showToast: function (messageToDisplay, variant) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: $A.get("$Label.c.Toast_Mode_Dismissible"),
            message: messageToDisplay,
            type: variant
        });
        toastEvent.fire();
    },

    /**
     * @description To enable 'Validate' button on Activation Checklist.
     **/
    notifyActivationChecklist: function (component) {
        var payload = {
            parentWorkPlanId: component.get('v.recordId'),
            enableValidateButton: false,
            isValidationInProgress: false
        };
        component.find("activationChecklistMessageChannel").publish(payload);
    },

    /**
     * @description To disable 'Validate' button on Activation Checklist during "In Progress".
     **/
    notifyActivationChecklistInProgress: function (component) {
        var payload = {
            parentWorkPlanId: component.get('v.recordId'),
            enableValidateButton: true,
            isValidationInProgress: true
        };
        component.find("activationChecklistMessageChannel").publish(payload);
    }
})