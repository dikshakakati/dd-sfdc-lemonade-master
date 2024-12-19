/**
 * @author Aethereus
 * @date 01/03/2024
 * @description This class is used to get the data for the Non-Contractual Updates component on the Work Order page.
 * @last modified on  : 05-10-2024
 * @last modified by  : Smruti
 */
public with sharing class NonContractualUpdatesWorkOrderMINTCtrl {

    private static final String ENTITY_ID = 'EntityId';

    /**
     * @description Represents the parameters for XRef.
     */
    public class XRefParams {
        /**
         * @description The account IDs.
         */
        public Set<Id> accIds {get; set;}
        /**
         * @description The work order created date.
         */
        public DateTime woCreatedDate {get; set;}
        /**
         * @description The user IDs.
         */
        public List<String> userIds {get; set;}
        /**
         * @description The look up XRef tracking.
         */
        public Map<String, String> lookUpXrefTracking {get; set;}


   /**
     * @description Represents the parameters for XRef.
     * @param accIds The account IDs.
     * @param woCreatedDate The work order created date.
     * @param userIds The user IDs.
     * @param lookUpXrefTracking The look up XRef tracking.
     * @param woDriveType The work order drive type.
     * @constructor
     */
        public XRefParams(Set<Id> accIds, DateTime woCreatedDate, List<String> userIds, Map<String, String> lookUpXrefTracking, Boolean woDriveType) {
            this.accIds = accIds;
            this.woCreatedDate = woCreatedDate;
            this.userIds = userIds;
            this.lookUpXrefTracking = lookUpXrefTracking;
        }
    }


    /**
     * @description Retrieves the data for the Non-Contractual Updates component on the Work Order page.
     * @param workOrderId The ID of the work order.
     * @return The MINTDataWrapper object containing the data.
     */
    @AuraEnabled(cacheable=true)
    public static MINTDataWrapper getNonContractualDataByMINT(String workOrderId){


        MINTDataWrapper retVal = new MINTDataWrapper();

        populateAccountFieldSetMap(retVal);
        populateXRefFieldSetMap(retVal);
        Map<String, String> lookUpXrefTracking = populateLookUpXrefTracking();
        Set<Id> accIds = new Set<Id>();
        List<String> userIds = System.Label.MINT_Upate_Users .split(';');
        DateTime woCreatedDate;
        Boolean woDriveType;
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectWorkOrdersByParentId(workOrderId);
        for(WorkOrder wo : workOrders){
            accIds.add(wo.AccountId);
            if(woDriveType == null){
                woCreatedDate = wo.ParentWorkOrder.CreatedDate;
                woDriveType = wo.ParentWorkOrder.Type__c == 'Drive' ? true : false ;
            }
        }
        if(!accIds.isEmpty()){
            XRefParams params = new XRefParams(accIds, woCreatedDate, userIds, lookUpXrefTracking, woDriveType);
            populateAccountHistories(retVal, accIds, userIds, woCreatedDate);
            populateXRefs(retVal, params, woDriveType);
        }
        retVal.xRefFieldSetMap.putAll(lookUpXrefTracking);
        retVal.entityIdWithValues = businessReferenceIdToExternalId(retVal.xRefs);
        return retVal;
    }

     /**
     * @description Populates a map having business refernce V/S external id map
     * @param xrefList
     * @return Map<String,String> business refernce V/S external id map
     */
    @TestVisible
    private static Map<String,String> businessReferenceIdToExternalId( List<Xref__c> xrefList){
        Set<Id> businessReferenceIDs = new Set<Id>();
        Map<String,String> businessIdVsExternalId = new MAp<String,String>();
        for (Xref__c xrefs : xrefList){
            for(Xref__History xrefHistory : xrefs.Histories){
                if(xrefHistory.NewValue != NULL && xrefHistory.DATATYPE == ENTITY_ID){
                    businessReferenceIDs.add(String.valueOf(xrefHistory.NewValue));
                }
                if(xrefHistory.OldValue != NULL && xrefHistory.DATATYPE == ENTITY_ID){
                    businessReferenceIDs.add(String.valueOf(xrefHistory.OldValue));
                }
            }
        }
        List<Business_Reference__c> listOfBizRefs = BusinessReferencesSelector.newInstance().selectByIds(businessReferenceIDs);
        for (Business_Reference__c bizRefs : listOfBizRefs){
            businessIdVsExternalId.put(bizRefs.id,bizRefs.External_ID__c);
        }
        return businessIdVsExternalId;
    }

    /**
     * @description Populates account field sets.
     * @param retVal
     */
        @TestVisible
        private static void populateAccountFieldSetMap(MINTDataWrapper retVal) {
            for(FieldSetMember x:
            SObjectType.Account
            .FieldSets.getMap()
            .get('MINT_Histories')
            .getFields()
           ){
               String fieldAPIName = x.getFieldPath() == 'Name' ? 'TextName' : x.getFieldPath();
               retVal.accountFieldSetMap.put(fieldAPIName, x.getLabel());
           }
        }

     /**
     * @description Populates xref field sets.
     * @param retVal
     */
        @TestVisible
        private static void populateXRefFieldSetMap(MINTDataWrapper retVal) {
            for(FieldSetMember x:
            SObjectType.Xref__c
            .FieldSets.getMap()
            .get('MINT_Histories')
            .getFields()
           ){
               retVal.xRefFieldSetMap.put(x.getFieldPath(), x.getLabel());
           }

        }

     /**
     * @description Populates xref lookup field sets.
     * @return Map<String, String>
     */
        @TestVisible
        private static Map<String, String> populateLookUpXrefTracking() {
            Map<String, String> lookUpXrefTracking = new Map<String, String>();
            for(FieldSetMember x:
                SObjectType.Xref__c
                .FieldSets.getMap()
                .get('MINT_Histories_Lookup')
                .getFields()
               ){
                   lookUpXrefTracking.put(x.getFieldPath(), x.getLabel());
               }
			return lookUpXrefTracking;
        }

     /**
     * @description Populates account history track.
     * @param retVal
     * @param accIds
     * @param userIds
     * @param woCreatedDate
     */
        @TestVisible
        private static void populateAccountHistories(MINTDataWrapper retVal, Set<Id> accIds, List<String> userIds, DateTime woCreatedDate) {
            retVal.accountHistories.addAll(AccountHistorySelector.newInstance().selectAccountHistory(retVal.accountFieldSetMap.keySet(), accIds, userIds, woCreatedDate));
        }

     /**
     * @description Populates xref history track.
     * @param retVal
     * @param params
     * @param woDriveType
     */
        @TestVisible
        private static void populateXRefs(MINTDataWrapper retVal, XRefParams params, Boolean woDriveType) {
        XrefHistoryFilterWrapper xrefFilterWrapper = new XrefHistoryFilterWrapper();
        xrefFilterWrapper.allxrefFieldSet = retVal.xRefFieldSetMap.keySet();
        xrefFilterWrapper.alllookUpXref = params.lookUpXrefTracking.keySet();
        xrefFilterWrapper.excludeEntity = retVal.replaceEntityLabel.keySet();

            if(woDriveType){
            retval.xRefs.addAll(XrefsSelector.newInstance().selectDriveDbXrefsByAccountAndIntegrationStatus(params.accIds, params.woCreatedDate, params.userIds, xrefFilterWrapper));

            }
            else{
            retval.xRefs.addAll(XrefsSelector.newInstance().selectMDSXrefsByAccountAndIntegrationStatus(params.accIds, params.woCreatedDate, params.userIds,xrefFilterWrapper));
            }

    }

    /**
     * Wrapper class for MINT data.
     * @description This class is used to wrap the data for the Non-Contractual Updates component on the Work Order page.
     */
    public class MINTDataWrapper{
        @AuraEnabled
        public Map<String,String> accountFieldSetMap = new Map<String, String>();
        @AuraEnabled
        public Map<String,String> xRefFieldSetMap = new Map<String, String>();
        @AuraEnabled
        public List<AccountHistory> accountHistories = new List<AccountHistory>();
        @AuraEnabled
        public List<Xref__c> xRefs = new List<Xref__c>();
        @AuraEnabled
        public Map<String, String> entityIdWithValues = new Map<String, String>();
        @AuraEnabled
        public final Map<String, String> replaceEntityLabel = new Map<String, String>{
            'Business_Reference__c' => 'BusinessID__c'
        };
    }

    /**
     * Wrapper class for xrefs History Filteration.
     * @description This class is used to store all the filters used to send xrefSelectors.
     */
    public class XrefHistoryFilterWrapper{
        public Set<String> allxrefFieldSet;
        public Set<String> alllookUpXref;
        public Set<String> excludeEntity;
    }
}