/**
 * @author Deloitte
 * @date 27/05/2022
 * @description JavaScript controller for AssignToMe aura component.
 */
({
  /**
   * @description It is used to initialise auto launched flow component.
   **/
  doInit: function (component, event, helper) {
    var flowInstance = component.find("assignToMeFlow");
    var inputVariables = [
      {
        name: "recordId",
        type: "String",
        value: component.get("v.recordId")
      }
    ];
    flowInstance.startFlow("Assign_To_Me", inputVariables);
  },

  /**
   * @description It is used to fire event on flow status change.
   */
  handleStatusChange: function (component, event, helper) {
    if (event.getParam("status") === "FINISHED_SCREEN") {
      $A.get("e.force:refreshView").fire();
      helper.fireShowToastEvent(component, event, helper);
    }
  }
});
