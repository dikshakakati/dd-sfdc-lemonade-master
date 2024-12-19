({
    /**
     * @description Invoke action on click of the Save button in the flow.
     */
    invoke: function (component, event, helper) {      
      var currentRecordId = component.get("v.recordId"); 
      helper.showToastEvent(component, event, helper);   
      if (currentRecordId) {
        var redirectToPage = $A.get("e.force:navigateToSObject");
        redirectToPage.setParams({
          recordId: currentRecordId
        });
        redirectToPage.fire();
      }else{
        
        component.find("publishEvent").publish({ refreshPage: true });
      }
      
    }
  });