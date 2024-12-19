/**
 * @author Deloitte
 * @date 27/05/2022
 * @description JavaScript helper for AssignToMe aura component.
 */
({
  /**
   * @description It is used to show toast Message on the button click event.
   */
  fireShowToastEvent: function (component, event, helper) {
    var currentOutput;
    var message;
    var outputVariables = event.getParam("outputVariables");
    var toastEvent = $A.get("e.force:showToast");
    var title;
    var type;
    for (
      var outputIterator = 0;
      outputIterator < outputVariables.length;
      outputIterator++
    ) {
      currentOutput = outputVariables[outputIterator];
      //The string values are Assign To Me flow variables.
      switch (currentOutput.name) {
        case "messageTitle":
          title = currentOutput.value;
          break;
        case "messageType":
          type = currentOutput.value;
          break;
        case "successMessage":
          message = currentOutput.value;
          break;
        default:
          break;
      }
    }
    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  }
});
