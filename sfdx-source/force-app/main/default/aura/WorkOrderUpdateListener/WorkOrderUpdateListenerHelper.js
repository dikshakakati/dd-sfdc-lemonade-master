({
  /**
   * @description It evaluates changed fields received from recordData
   * and display the banner message accordingly.
   **/
  validateChangedFields: function (changedFields, helper) {
    if (changedFields) {
      var fieldsToListen = $A.get("$Label.c.Fields_To_Listen_Work_Order_Update");
      var shouldSkip = false;
      Object.keys(changedFields).forEach(function (eachKey) {
        if (shouldSkip) {
          return;
        }
        // old value check is required for preventing unexpected toast message on inline edit
        if (fieldsToListen.includes(eachKey)
          && (Object.prototype.hasOwnProperty.call(changedFields[eachKey], "oldValue")
            && changedFields[eachKey].oldValue !== undefined)) {
          shouldSkip = true;
          helper.showToast();
        }
      });
    }
  },

  /**
   * @description To display the banner message.
   **/
  showToast: function () {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: $A.get("$Label.c.Toast_Mode_Sticky"),
      message: $A.get("$Label.c.Work_Order_Update_Banner_Message"),
      type: $A.get("$Label.c.Toast_Variant_Info")
    });
    toastEvent.fire();
  }
})