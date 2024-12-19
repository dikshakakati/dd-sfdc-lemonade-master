/**
 * @author Deloitte
 * @date 04/26/2024
 * @description Interface to add domain class methods of Task Object
 */
public interface ITasks extends fflib_ISObjects {
    /**
     * @description update Call Count on any call
     */
    void updateCallCountWhenAnyCallIsHappened();

    /**
     * @description It is used to update activity dates on related Opportunities for Tasks
     * which are inserted or updated.
     */
    void updateActivityDatesOnOpportunity();

    /**
     * @description It is used to update activity dates on related Opportunities for Tasks
     * which are inserted or updated.
     * @param mxTouchpoint
     * @param stakeholder
     * @return Task
     */
    Task createTaskByPassedMxTouchpointAndStakeholder(
        Initiative__c mxTouchpoint,
        Stakeholder__c stakeholder
    );

    /**
     * @description It is used to clone tasks on work orders (parent) from tasks
     * associated with work plans.
     */
    void cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();

    /**
     * @description It is used to update first and last activity on lead for Tasks
     * which are inserted
     */
    void updateFirstAndLastActivityOnLead();
}