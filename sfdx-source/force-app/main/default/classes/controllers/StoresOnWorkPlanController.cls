/**
 * @author Deloitte
 * @date 27/04/2022
 * @description Controller class for storesOnWorkPlan lightning web component.
 */
public with sharing class StoresOnWorkPlanController {
    /**
     * @description It fetches unique stores from current WorkPlan.
     * @JIRA# LEM-1158
     * @param currentWorkPlanRecordId
     * @return StoresOnWorkPlanWrapper
     */
    @AuraEnabled(cacheable=true)
    public static StoresOnWorkPlanWrapper fetchStoresByWorkPlan(Id currentWorkPlanRecordId) {
        return StoresOnWorkPlansService.fetchStoresByWorkPlan(currentWorkPlanRecordId);
    }

    /**
     * @description It fetches store details using passed accountWrapper.
     * @JIRA# LEM-1158
     * @param accountWrapper
     * @return List<SectionWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static List<SectionWrapper> fetchStoresData(String accountWrapper) {
        return StoresOnWorkPlansService.fetchStoresData(accountWrapper);
    }
}