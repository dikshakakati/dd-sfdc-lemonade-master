/**
 * @author Deloitte
 * @date 11/13/2022
 * @description JavaScript controller for NotifyUserOnOpportunityStageChange aura component.
 */
({
    /**
     * @description It listens to stage changes and shows a toast message
     * notifying users about an empty Purchase Order.
     **/
    listenToUpdates: function (component, event, helper) {
        var changeType = event.getParams().changeType;
        var opportunityRec = component.get("v.opportunityRecord");
        // check change type is CHANGED
        if (
            changeType === $A.get("$Label.c.Work_Order_Listener_Change_Type_Changed")
        ) {
            helper.validateChangedFields(component, event.getParams().changedFields, helper, opportunityRec);
        }
    }
});