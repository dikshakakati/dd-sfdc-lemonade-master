/**
 * @author Deloitte
 * @date 30/03/2022
 * @description WorkStep object trigger handler.
 */
public class WorkStepsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - WorkSteps record list
     */
    public WorkStepsHandler(List<WorkStep> sObjectList) {
        super(sObjectList);
        setContextBypass(WorkStep.SObjectType, WorkStepsHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        WorkSteps.newInstance(this.records).onAfterInsertHandleRelatedRecords();
    }

    /**
     * @description Called to perform processing during the after update phase.
     * @param existingRecords - The map of old Work Steps
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        IWorkSteps workStepsInstance = WorkSteps.newInstance(this.records);
        workStepsInstance.onAfterUpdateHandleRelatedRecords((Map<Id, WorkStep>) existingRecords);
        new IntegrationCriteriaEvaluator()
            .evaluateInitialCriteriaForEmailIntegration(this.records, existingRecords);
    }

    /**
     * @description Called to perform processing during the before insert phase.
     */
    public override void onBeforeInsert() {
        IWorkSteps workStepsInstance = WorkSteps.newInstance(this.records);
        workStepsInstance.onBeforeInsertValidateAndUpdateWorkStepFields();
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords - The map of old Work Steps
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        IWorkSteps workStepsInstance = WorkSteps.newInstance(this.records);
        workStepsInstance.onBeforeUpdateValidateAndUpdateWorkStepFields(
            (Map<Id, WorkStep>) existingRecords
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return WorkStepsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WorkStepsHandler(sObjectList);
        }
    }
}