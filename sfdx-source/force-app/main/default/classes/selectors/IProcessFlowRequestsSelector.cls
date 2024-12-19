/**
 * @author DoorDash
 * @description Selector interface for the Process_Flow_Request__c object..
**/
public interface IProcessFlowRequestsSelector extends fflib_ISObjectSelector {

    /**
     * @description Retrieves a List of Process_Flow_Request__c by a Set of their IDs
     * @param idSet
     * @return List<Process_Flow_Request__c> - List of Process_Flow_Request__c
     */
    List<Process_Flow_Request__c> selectById(Set<Id> idSet);

    /**
     * @description Returns Requests for a Contract
     * @param contractId - Id of the Contract to retrieve Requests for
     * @return List<Process_Flow_Request__c>
    **/
    List<Process_Flow_Request__c> selectByContractId(Id contractId);

    /**
     * @description Returns OPEN Requests for the Contract from the current running user
     * @param contractId - Id of the relevant Contract
     * @return List<Process_Flow_Request__c>
    **/
    List<Process_Flow_Request__c> selectOpenRequestsForContractAndUser(Id contractId);

    /**
     * @description It accept the record id, and fetch the process flow request for the current user and for the Opportunity record which is not closed yet.
     * It works for the flow initiated from the Opportunity
     * @param recordId - Id of the relevant Opportunity
     * @return List<Process_Flow_Request__c>
    **/
    List<Process_Flow_Request__c> selectOpenBrandAndBusinessRequestsForOpportunityAndUser(Id recordId);

     /**
     * @description It accept the record id, and fetch the process flow request for the current user and for the Opportunity record which is not closed yet.
     * It works for the flow initiated from the Contract
     * @param recordId - Id of the relevant Contract
     * @return List<Process_Flow_Request__c>
    **/
    List<Process_Flow_Request__c> selectOpenBrandAndBusinessRequestsForContractAndUser(Id recordId);

    /**
     * @description Returns a List of Brand and Business Process_Flow_Request__c by their IDs
     * @param idSet - Set of Process_Flow_Request__c IDs
     * @return List<Process_Flow_Request__c>
     */
    List<Process_Flow_Request__c> selectBrandAndBusinessFlowByIds(Set<Id> idSet);

    /**
     * @description Returns a List of Brand and Business Process_Flow_Request__c by contract or Opportunoty Ids
     * @param recordIdSet - list of contract or opporunity Ids
     * @return List<Process_Flow_Request__c>
     */
    List<Process_Flow_Request__c> selectBrandAndBusinessFlowByContractOrOpportunityIds(List<Id> recordIdSet);
}