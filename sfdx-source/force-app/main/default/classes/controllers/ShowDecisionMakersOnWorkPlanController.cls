/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Controller class for showDecisionMakersOnWorkPlan lightning web component.
 */
public with sharing class ShowDecisionMakersOnWorkPlanController {
    /**
     * @description It is used to get decision maker phone details using the passed Work Plan Id.
     * @JIRA# LEM-15997
     * @param workPlanId
     * @return List<DecisionMakerWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static List<DecisionMakerWrapper> getDecisionMakerPhoneDetails(Id workPlanId) {
        return ShowDecisionMakersOnWorkPlanService.getDecisionMakerPhoneDetails(workPlanId);
    }

    /**
     * @description It is used to update Number_of_Call_Attempts__c field on Work Plan.
     * @JIRA# LEM-15997
     * @param decisionMakerDetailsJSON
     */
    @AuraEnabled
    public static void updateNumberOfCallAttemptsOnWorkPlan(String decisionMakerDetailsJSON) {
        ShowDecisionMakersOnWorkPlanService.updateNumberOfCallAttemptsOnWorkPlan(
            decisionMakerDetailsJSON
        );
    }
}