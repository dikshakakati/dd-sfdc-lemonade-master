/**
 * author Deloitte
 * @date 27/05/2022
 * @description JavaScript helper for OverrideFlowSaveButton component.
 */
({
  /**
   * @description It is used to show the toast message on click of the Save button in the flow.
   */
  showToastEvent: function (component, event, helper) {
    var title = component.get("v.title");
    var message = component.get("v.message");
    var type = component.get("v.type");
    var mode = component.get("v.mode");
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      type: type,
      mode: mode
    });
    toastEvent.fire();
  }
});
