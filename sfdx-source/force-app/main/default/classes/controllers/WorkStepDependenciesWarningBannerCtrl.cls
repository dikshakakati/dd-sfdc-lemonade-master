/**
 * @author Deloitte
 * @date 11/05/2022
 * @description Controller class for workStepDependenciesWarningBanner lightning web component.
 */
public with sharing class WorkStepDependenciesWarningBannerCtrl {
    /**
     * @description It fetches banner message to be displayed on WorkPlan/WorkStep
     * on basis of controlling WorkSteps' status.
     * @JIRA# LEM-1217
     * @param currentRecordId
     * @return BannerMessageWrapper
     */
    @AuraEnabled(cacheable=true)
    public static BannerMessageWrapper getBannerMessageDetails(Id currentRecordId) {
        return WorkStepDependenciesService.getBannerMessageDetails(currentRecordId);
    }
}