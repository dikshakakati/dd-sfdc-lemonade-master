/**
 * @author BizApps
 * @date 07/08/2023
 * @description Controller class for reattemptProvisioning lightning web component called from WorkOrder.
 */
public with sharing class ReattemptProvisioningOnWorkOrderCtrl {
    /**
     * @description It reattempts provisioning on Business References and Xrefs related to a Parent WorkOrder
     * @JIRA# LEM-7366
     * @param parentWorkOrderId
     * @return boolean
     */
    @AuraEnabled
    public static boolean reattemptProvisioning(Id parentWorkOrderId) {
        return ReattemptProvisioningService.reattemptProvisioningOnWorkOrder(parentWorkOrderId);
    }
}