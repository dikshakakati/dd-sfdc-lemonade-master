/**
 * @author Deloitte
 * @date 27/06/2022
 * @description JavaScript controller for AddStores aura component.
 */
({
  /**
   * @description It is used to close the quick action panel.
   **/
  closeModal: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  }
});
