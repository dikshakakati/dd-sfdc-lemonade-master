/**
 * @author Deloitte
 * @date 13/07/2022
 * @description JavaScript controller for WorkOrderUpdateListener aura component.
 */
({
  /**
   * @description It listens to field changes and shows a toast message
   * about re-evaluating Work Plans.
   **/
  listenToUpdates: function (component, event, helper) {
    var changeType = event.getParams().changeType;
    // check change type is CHANGED
    if (
      changeType === $A.get("$Label.c.Work_Order_Listener_Change_Type_Changed")
    ) {
      helper.validateChangedFields(event.getParams().changedFields, helper);
    }
  }
});
