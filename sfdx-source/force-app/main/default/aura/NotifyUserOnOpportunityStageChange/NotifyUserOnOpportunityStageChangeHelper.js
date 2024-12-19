({
    /**
     * @description It evaluates changed fields received from recordData
     * and display the banner message accordingly.
     **/
    validateChangedFields: function (component, changedFields, helper, opportunityRecord) {
        if (changedFields) {
            var fieldsToListen = $A.get("$Label.c.Fields_to_Listen_on_Opportunity_Update");
            var shouldSkip = false;
            var isOpportunityRelatedToLineItems = false;
            var action = component.get("c.getOpportunityLineItems");
            action.setParams({ opportunityId: opportunityRecord.Id });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    isOpportunityRelatedToLineItems = response.getReturnValue();
                }
            });
            $A.enqueueAction(action);
            setTimeout(() => {
                Object.keys(changedFields).forEach(function (eachKey) {
                    if (shouldSkip) {
                        return;
                    }
                    // old value check is required for preventing unexpected toast message on inline edit
                    if (fieldsToListen.includes(eachKey)
                        && (Object.prototype.hasOwnProperty.call(changedFields[eachKey], "value")
                            && changedFields[eachKey].value === $A.get("$Label.c.Opportunity_Stage_Closed_Won"))
                        && opportunityRecord.Purchase_Order__c === null && isOpportunityRelatedToLineItems === true) {
                        shouldSkip = true;
                        helper.showToast();
                    }
                });
            }, 2000);
        }
    },

    /**
     * @description To display the banner message.
     **/
    showToast: function () {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: $A.get("$Label.c.Toast_Mode_Sticky"),
            message: $A.get("$Label.c.Opportunity_Update_Banner_Message"),
            type: $A.get("$Label.c.Toast_Variant_Info")
        });
        toastEvent.fire();
    }
})