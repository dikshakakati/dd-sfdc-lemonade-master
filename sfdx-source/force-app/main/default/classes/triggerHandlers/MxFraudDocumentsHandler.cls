/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Trigger handler class for Mx Fraud Document object.
 */
public class MxFraudDocumentsHandler extends ApplicationDomainHandler {
    /**
     * @description Default constructor method.
     * @param sObjectsList
     */
    public MxFraudDocumentsHandler(List<Mx_Fraud_Document__c> sObjectsList) {
        super(sObjectsList);
        setContextBypass(Mx_Fraud_Document__c.SObjectType, MxFraudDocumentsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description This method implements construct class in fflib_SObjectDomain.
         * @param sObjectsList
         * @return MxFraudDocumentsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectsList) {
            return new MxFraudDocumentsHandler(sObjectsList);
        }
    }

    /**
     * @description Called to perform processing during the after insert phase.
     * @JIRA LEM-15836
     */
    public override void onAfterInsert() {
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(this.records);
    }

    /**
     * @description Called to perform processing during the after update phase.
     * @JIRA LEM-15836
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Mx_Fraud_Document__c> changedWorkOrders = new List<Mx_Fraud_Document__c>(
            (List<Mx_Fraud_Document__c>) getChangedRecords(
                new Set<SObjectField>{ Mx_Fraud_Document__c.Document_Version__c }
            )
        );
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(changedWorkOrders);
    }
}