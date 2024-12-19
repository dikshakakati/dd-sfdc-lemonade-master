/**
 * @author atg
 * @date 08/08/2022
 * @description Controller class for reattemptProvisioning lightning web component.
 */
public with sharing class ReattemptProvisioningOnWorkPlanCtrl {
    /**
     * @description It reattempts provisioning on Business References and Xrefs related to a Work Plan
     * @JIRA# LEM-2226
     * @param parentWorkPlanId
     * @return boolean
     */
    @AuraEnabled
    public static boolean reattemptProvisioning(Id parentWorkPlanId) {
        return ReattemptProvisioningService.reattemptProvisioning(parentWorkPlanId);
    }
}