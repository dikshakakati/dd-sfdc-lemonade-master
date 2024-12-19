/**
 * @author Deloitte
 * @date 08/04/2022
 * @description WorkPlan object trigger handler.
 */
public class WorkPlansHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - WorkPlans record list
     */
    public WorkPlansHandler(List<WorkPlan> sObjectList) {
        super(sObjectList);
        setContextBypass(WorkPlan.SObjectType, WorkPlansHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        WorkPlans.newInstance(this.records).onAfterInsertHandleRelatedRecords();
    }

    /**
     * @description Called to perform processing during the after update phase.
     * @param existingRecords - The map of old Work Plans
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        WorkPlans.newInstance(this.records)
            .onAfterUpdateHandleRelatedRecords((Map<Id, WorkPlan>) existingRecords);

        List<WorkPlan> updatedParentWorkPlans = new List<WorkPlan>(
            (List<WorkPlan>) getChangedRecords(getParentWorkPlanUpdatedFields())
        );

        WorkPlans.newInstance(updatedParentWorkPlans)
            .collectParentWorkPlansWithUpdatedInformation(updatedParentWorkPlans);
        List<WorkPlan> workPlansWithChangedStatus = new List<WorkPlan>(
            (List<WorkPlan>) getChangedRecords(new Set<SObjectField>{WorkPlan.Status__c})
        );
        WorkPlans.newInstance(workPlansWithChangedStatus)
        .evaluateAndInitiateMarketingKitWorkOrderCreation();
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords - The map of old Work Plans
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        WorkPlans.newInstance(this.records)
            .onBeforeUpdateValidateAndUpdateWorkPlanFields((Map<Id, WorkPlan>) existingRecords);
    }

    /**
     * @description Fetch work Plans having updated values on Notes__c
     * @return List<WorkPlan>
     */
    private Set<SObjectField> getParentWorkPlanUpdatedFields() {
        Map<String, Schema.SObjectField> workPlanSobjectFields = WorkPlan.SObjectType.getDescribe()
            .fields.getMap();
        Set<SObjectField> workPlanFields = new Set<SObjectField>();
        Schema.FieldSet fieldSetObj = SObjectType.WorkPlan.FieldSets.Parent_Fields_To_Sync_On_Childs;
        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = String.valueOf(fieldSetMember.getSObjectField());
            if (workPlanSobjectFields.get(fieldName) != null) {
                workPlanFields.add(workPlanSobjectFields.get(fieldName));
            }
        }
        return workPlanFields;
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable.
         * @param sObjectList - List of SObjects
         * @return WorkPlansHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WorkPlansHandler(sObjectList);
        }
    }
}