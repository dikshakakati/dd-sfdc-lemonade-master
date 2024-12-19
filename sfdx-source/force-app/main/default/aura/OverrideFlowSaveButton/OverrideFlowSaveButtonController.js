/**
 * @author Deloitte
 * @date 27/05/2022
 * @description JavaScript controller for OverrideFlowSaveButton component.
 */
({
  /**
   * @description Invoke action on click of the Save button in the flow.
   */
  invoke: function (component, event, helper) {
    var currentRecordId = component.get("v.recordId");
    if (currentRecordId) {
      var redirectToPage = $A.get("e.force:navigateToSObject");
      redirectToPage.setParams({
        recordId: currentRecordId
      });
      redirectToPage.fire();
    }
    helper.showToastEvent(component, event, helper);
    if (component.get("v.enableRefreshView")) {
      $A.get('e.force:refreshView').fire();
    }
  }
});
