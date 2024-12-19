/**
 * @author Deloitte
 * @date 04/30/2024
 * @description sbaa__Approval__c Trigger handler class.
 */
public class ApprovalsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList
     */
    public ApprovalsHandler(List<sbaa__Approval__c> sObjectList) {
        super(sObjectList);
        setContextBypass(sbaa__Approval__c.SObjectType, ApprovalsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description It implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects
         * @return ApprovalsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new ApprovalsHandler(sObjects);
        }
    }

    /**
     * @description It is used to perform before Insert processing.
     * @JIRA #LEM-15260
     */
    public override void onBeforeInsert() {
        Approvals.newInstance(this.records)
            .updateRequestedReasonFromQuote();
    }
    
    /**
     * @description It is used to perform before update processing.
     * @JIRA #LEM-13987
     * @param existingApprovals
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingApprovals) {
        Approvals.newInstance(this.records)
            .updateApprovalFieldsWithExistingValues(existingApprovals);
    }

    /**
     * @description It is used to perform after update processing.
     * @JIRA #LEM-13987
     * @param existingApprovals
     */
    public override void onAfterUpdate(Map<Id, SObject> existingApprovals) {
        Approvals.newInstance(this.records)
            .initiateAdvancedApprovalsAPI(
                (List<sbaa__Approval__c>) getChangedRecords(
                    new Set<Schema.SObjectField>{
                        sbaa__Approval__c.Approval_Status__c,
                        sbaa__Approval__c.sbaa__CommentsLong__c
                    }
                )
            );
    }
}