/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description JavaScript controller for RemoveStores aura component.
 */
({
    /**
     * @description It is used to close the quick action panel.
     **/
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});