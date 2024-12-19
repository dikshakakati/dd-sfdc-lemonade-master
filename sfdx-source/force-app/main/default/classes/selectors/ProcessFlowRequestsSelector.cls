/**
 * @author DoorDash
 * @description Selector class for the Process_Flow_Request__c SObject.
**/
public inherited sharing class ProcessFlowRequestsSelector extends fflib_SObjectSelector implements IProcessFlowRequestsSelector {
	private static final Id BULK_ONBOARDING_RECORD_TYPE_ID = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
        .get(System.Label.Bulk_Onboarding_Record_Type_Name)
        .getRecordTypeId();
    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;
    private static final Id BRANDANDBUSINESSFLOW_RECORDTYPE_RECORD_TYPE_ID = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
    .get(System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name)
    .getRecordTypeId();

    /**
     * @description default constructor for the Process_Flow_Request__c Selector class
     * @return IProcessFlowRequestsSelector - interface of IProcessFlowRequestsSelector
     */
    public static IProcessFlowRequestsSelector newInstance() {
        return (IProcessFlowRequestsSelector) Application.Selector.newInstance(
            Process_Flow_Request__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Process_Flow_Request__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Process_Flow_Request__c object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Process_Flow_Request__c.Id,
            Process_Flow_Request__c.Name,
            Process_Flow_Request__c.CreatedDate,
            Process_Flow_Request__c.CreatedById,
            Process_Flow_Request__c.LastModifiedDate,
            Process_Flow_Request__c.LastModifiedById,
            Process_Flow_Request__c.OwnerId,
            Process_Flow_Request__c.Batch_Delay_Number__c,
            Process_Flow_Request__c.Contract__c,
            Process_Flow_Request__c.Fixed_Store_IDs__c,
            Process_Flow_Request__c.Fixed_Stores_Count__c,
            Process_Flow_Request__c.Opportunity__c,
            Process_Flow_Request__c.Is_Closed__c,
            Process_Flow_Request__c.Removed_Stores__c,
            Process_Flow_Request__c.Result__c,
            Process_Flow_Request__c.Serialized_Object_Data__c,
            Process_Flow_Request__c.Stage__c,
            Process_Flow_Request__c.Status__c,
            Process_Flow_Request__c.Upload_Attempts__c,
            Process_Flow_Request__c.User_Feedback__c,
            Process_Flow_Request__c.Work_Order__c,
            Process_Flow_Request__c.Work_Order_Selection_Method__c,
            Process_Flow_Request__c.Serialized_Entitlements_Data__c,
            Process_Flow_Request__c.Group__c,
            Process_Flow_Request__c.CCP_ANSO_flow__c,
            Process_Flow_Request__c.CCP_Applied__c
        };
    }

    /**
     * @description Returns a List of Process_Flow_Request__c by their IDs
     * @param idSet - Set of Process_Flow_Request__c IDs
     * @return List<Process_Flow_Request__c>
     */
    public List<Process_Flow_Request__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Work_Order__r.Id');
        query.selectField('Work_Order__r.OwnerId');
        query.selectField('Work_Order__r.Owner.Email');
        query.selectField('Work_Order__r.WorkOrderNumber');
        query.selectField('Contract__r.AccountId');
        query.selectField('Contract__r.ContractNumber');
        query.setCondition('Id IN: idSet AND RecordTypeId = :BULK_ONBOARDING_RECORD_TYPE_ID');
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns Requests for a Contract
     * @param contractId - Id of the Contract to retrieve Requests for
     * @return List<Process_Flow_Request__c>
    **/
    public List<Process_Flow_Request__c> selectByContractId(Id contractId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contract__c = :contractId AND RecordTypeId = :BULK_ONBOARDING_RECORD_TYPE_ID'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns OPEN Requests for the current running user
     * @param contractId - Id of the relevant Contract
     * @return List<Process_Flow_Request__c>
     **/
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Process_Flow_Request__c> selectOpenRequestsForContractAndUser(Id contractId) {
        Id currentUserId = UserInfo.getUserId(); // Dynamic SOQL can only handle "simple" bindings, so we need this variable
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'OwnerId = :currentUserId AND Contract__c = :contractId AND RecordTypeId = :BULK_ONBOARDING_RECORD_TYPE_ID AND Is_Closed__c = false'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns OPEN Requests for Brand_and_Business_Reference_Flow Record Type initiated from Opportunity for the current running user
     * @param recordId - Id of the relevant Opportunity
     * @return List<Process_Flow_Request__c>
    **/
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Process_Flow_Request__c> selectOpenBrandAndBusinessRequestsForOpportunityAndUser(Id recordId) {
        Id currentUserId = UserInfo.getUserId(); // Dynamic SOQL can only handle "simple" bindings, so we need this variable
        fflib_QueryFactory query = newQueryFactory()
                                        .setCondition('OwnerId = :currentUserId AND Opportunity__c = :recordId AND RecordTypeId = :BRANDANDBUSINESSFLOW_RECORDTYPE_RECORD_TYPE_ID AND Is_Closed__c = false')
                                        .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
    * @description Returns OPEN Requests for Brand_and_Business_Reference_Flow Record Type initiated from Contract for the current running user
    * @author rishab.goyal | 03-15-2024
    * @param recordId
    * @return List<Process_Flow_Request__c>
    **/
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Process_Flow_Request__c> selectOpenBrandAndBusinessRequestsForContractAndUser(Id recordId) {
        Id currentUserId = UserInfo.getUserId(); // Dynamic SOQL can only handle "simple" bindings, so we need this variable

        fflib_QueryFactory query = newQueryFactory()
                                        .setCondition('OwnerId = :currentUserId AND Contract__c = :recordId AND RecordTypeId = :BRANDANDBUSINESSFLOW_RECORDTYPE_RECORD_TYPE_ID AND Is_Closed__c = false')
                                        .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a List of Brand and Business Process_Flow_Request__c by their IDs
     * @param idSet - Set of Process_Flow_Request__c IDs
     * @return List<Process_Flow_Request__c>
     */
    public List<Process_Flow_Request__c> selectBrandAndBusinessFlowByIds(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('CreatedBy.FirstName');
        query.selectField('CreatedBy.Name');
        query.selectField('CreatedBy.Email');
        query.setCondition('Id IN: idSet AND RecordTypeId = :BRANDANDBUSINESSFLOW_RECORDTYPE_RECORD_TYPE_ID');
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a List of Brand and Business Process_Flow_Request__c by contract or Opportunoty Ids
     * @param recordIdSet - list of contract or opporunity Ids
     * @return List<Process_Flow_Request__c>
     */
    public List<Process_Flow_Request__c> selectBrandAndBusinessFlowByContractOrOpportunityIds(List<Id> recordIdSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('(Contract__c IN: recordIdSet OR Opportunity__c IN :recordIdSet) AND RecordTypeId = :BRANDANDBUSINESSFLOW_RECORDTYPE_RECORD_TYPE_ID');
        return (List<Process_Flow_Request__c>) Database.query(query.toSOQL());
    }
}