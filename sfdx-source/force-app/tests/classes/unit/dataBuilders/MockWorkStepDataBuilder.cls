/**
 * @author Deloitte
 * @date 24/05/2022
 * @description Test Data Factory class for creating WorkStep record(s)
 * for utilizing in the test classes.
 * Suppressed Warnings since data builder does not require System Assert statements
 * and Test word suffix.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class MockWorkStepDataBuilder {
    private static final Id STORE_ACCOUNT_ID = fflib_IDGenerator.generate(Account.SObjectType);
    private static final Id WORK_ORDER_ID = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    private static final Id WORK_PLAN_ID = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    private static final string WORK_STEP_NAME = 'Setup Banking';
    private static final string WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';

    /**
     * @description To create fake WorkStep record with the passed Status value.
     * @param statusValue
     * @return Fake
     */
    public static Fake createWorkStepRecordWithProvidedStatusValue(String statusValue) {
        return new Fake(WorkStep.class)
            .setField(WorkStep.Name, WORK_STEP_NAME)
            .setField(WorkStep.Status__c, statusValue)
            .setField(WorkStep.Store_Account__c, STORE_ACCOUNT_ID)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_BANKING)
            .setField(WorkStep.WorkOrderId, WORK_ORDER_ID)
            .setField(WorkStep.WorkPlanId, WORK_PLAN_ID)
            .setFakeId();
    }

    /**
     * @description To convert the Fake instance to WorkStep object.
     * @param workStepFakeInstance
     * @return WorkStep
     */
    public static WorkStep convertToWorkStepObject(Fake workStepFakeInstance) {
        return (WorkStep) workStepFakeInstance.toSObject();
    }
}