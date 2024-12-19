/**
 * @author DoorDash
 * @description Selector interface for the Process_Flow_Request_Chunk__c object
**/
public interface IProcessFlowRequestChunksSelector extends fflib_ISObjectSelector  {
    
    /**
     * @description Retrieves a List of Process_Flow_Request_Chunk__c by a Set of their IDs
     * @param idSet
     * @return List<Process_Flow_Request_Chunk__c> - List of Process_Flow_Request_Chunk__c
     */
    List<Process_Flow_Request_Chunk__c> selectById(Set<Id> idSet);

    /**
     * @description Retrieves a List of Process_Flow_Request_Chunk__c by a a PFR ID
     * @param flowRequestId
     * @return List<Process_Flow_Request_Chunk__c> - List of Process_Flow_Request_Chunk__c
     */
    List<Process_Flow_Request_Chunk__c> selectByRequestId(Id flowRequestId);

    /**
     * @description Returns a limite number of OPEN Chunks for a Process Flow Request (PFR)
     * @param flowRequestId - Id of the PFR to retrieve Requests for
     * @param numberOfChunks - Limit to apply to the query
     * @return List<Process_Flow_Request_Chunk__c>
    **/
    List<Process_Flow_Request_Chunk__c> selectSubsetOfOpenChunksByRequestId(Id flowRequestId, Integer numberOfChunks);
}