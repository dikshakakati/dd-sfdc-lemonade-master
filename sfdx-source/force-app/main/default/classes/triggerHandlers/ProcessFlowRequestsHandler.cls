/**
 * @description       :
 * @author            : rishab.goyal
 * @group             :
 * @last modified on  : 03-26-2024
 * @last modified by  : rishab.goyal
**/
public with sharing class ProcessFlowRequestsHandler extends ApplicationDomainHandler  {
    private static final String PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED = 'External Ids Created';
    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;

    /**
     * @description Constructor Method
     * @param sObjectList - ProcessFlowRequest Record List
     */
    public ProcessFlowRequestsHandler(List<Process_Flow_Request__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Process_Flow_Request__c.SObjectType, ProcessFlowRequestsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return ProcessFlowRequestsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ProcessFlowRequestsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        ProcessFlowRequests.newInstance(getStatusChangedProcessFlowRequestsWithStageExternalIdCreated())
                                        .sendNotifcationsForProcessFlowRequestWithExternalIdsCreated();

    }

   /**
   * @description get the Changed Process Flow Requests With Stage External Id Created for brandAndBusinessFlow Record Type
   * @author rishab.goyal | 03-22-2024
   * @return List<Process_Flow_Request__c>
   **/
    @Testvisible
   private List<Process_Flow_Request__c> getStatusChangedProcessFlowRequestsWithStageExternalIdCreated() {
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
        .get(BRANDANDBUSINESSFLOW_RECORDTYPE)
        .getRecordTypeId();
        List<Process_Flow_Request__c> processFlowRequestWithStageChangedToExternalIdCreated = new List<Process_Flow_Request__c>();
        for (
            Process_Flow_Request__c eachProcessFlowRequest : (List<Process_Flow_Request__c>) getChangedRecords(new Set<SObjectField>{ Process_Flow_Request__c.Stage__c })
        ) {
            if (eachProcessFlowRequest.Stage__c == PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED &&
                eachProcessFlowRequest.RecordTypeId == brandAndBusinessFlowRecordTypeId) {
                    processFlowRequestWithStageChangedToExternalIdCreated.add(eachProcessFlowRequest);
            }
        }

        return processFlowRequestWithStageChangedToExternalIdCreated;
    }
}