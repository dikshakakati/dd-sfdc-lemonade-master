/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Service class for ShowDecisionMakersOnWorkPlanController related logic.
 */
public inherited sharing class ShowDecisionMakersOnWorkPlanService {
    /**
     * @description It is used to get decision maker phone details using the passed Work Plan Id.
     * @JIRA# LEM-15997
     * @param workPlanId
     * @return List<DecisionMakerWrapper>
     */
    public static List<DecisionMakerWrapper> getDecisionMakerPhoneDetails(Id workPlanId) {
        return service().getDecisionMakerPhoneDetails(workPlanId);
    }

    /**
     * @description It is used to update Number_of_Call_Attempts__c field on Work Plan.
     * @JIRA# LEM-15997
     * @param decisionMakerDetailsJSON
     */
    public static void updateNumberOfCallAttemptsOnWorkPlan(String decisionMakerDetailsJSON) {
        service().updateNumberOfCallAttemptsOnWorkPlan(decisionMakerDetailsJSON);
    }

    /**
     * @description It creates instance of ShowDecisionMakersOnWorkPlanServiceImpl class.
     * @return IShowDecisionMakersOnWorkPlanService - return instance of ShowDecisionMakersOnWorkPlanServiceImpl
     */
    private static IShowDecisionMakersOnWorkPlanService service() {
        return (IShowDecisionMakersOnWorkPlanService) Application.Service.newInstance(
            IShowDecisionMakersOnWorkPlanService.class
        );
    }
}