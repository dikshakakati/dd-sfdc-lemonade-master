/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Interface for service class of ShowDecisionMakerOnWorkPlan controller related logic.
 */
public interface IShowDecisionMakersOnWorkPlanService {
    /**
     * @description It is used to get decision maker phone details using the passed Work Plan Id.
     * @JIRA# LEM-15997
     * @param workPlanId
     * @return List<DecisionMakerWrapper>
     */
    List<DecisionMakerWrapper> getDecisionMakerPhoneDetails(Id workPlanId);

    /**
     * @description It is used to update Number_of_Call_Attempts__c field on Work Plan.
     * @JIRA# LEM-15997
     * @param decisionMakerDetailsJSON
     */
    void updateNumberOfCallAttemptsOnWorkPlan(String decisionMakerDetailsJSON);
}