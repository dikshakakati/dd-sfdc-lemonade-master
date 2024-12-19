/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Controller used to fetch LWC generated Form Response and
 * enable Copy clipboard functionality.
 */
({
  /**
   * @description Closes the Aura modal when clicked to close.
   */
  closeQuickAction: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },

  /**
   * @description It used to fetch the Merchant Pop Up Response record
   * Id from the dispatched event.
   */
  getRecordValue: function (component, event) {
    var target = event.getParam("url");
    component.set("v.responseRecordId", target);
  }
});
