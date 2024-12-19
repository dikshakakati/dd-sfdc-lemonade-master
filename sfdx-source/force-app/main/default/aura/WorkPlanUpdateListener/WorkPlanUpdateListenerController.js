/**
 * @author Deloitte
 * @date 19/04/2024
 * @description JavaScript controller for WorkPlanUpdateListener aura component.
 */
({
    /**
     * @description It listens to field changes and shows a toast message
     * about Activation Checklist validations.
     **/
    listenToUpdates: function (component, event, helper) {
        var changeType = event.getParams().changeType;
        // check change type is CHANGED
        if (
            changeType === $A.get("$Label.c.Work_Order_Listener_Change_Type_Changed")
        ) {
            helper.validateChangedFields(component, event.getParams().changedFields, helper);
        }
    }
});