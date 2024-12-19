/**
 * @author DoorDash
 * @description Selector class for the Process_Flow_Request_Chunk__c object
**/
public inherited sharing class ProcessFlowRequestChunksSelector extends fflib_SObjectSelector implements IProcessFlowRequestChunksSelector  {
    private static final String CHUNK_STATUS_IN_PROGRESS = 'In Progress';

    /**
     * @description default constructor for the Process_Flow_Request_Chunk__c Selector class
     * @return IProcessFlowRequestChunksSelector - interface of IProcessFlowRequestChunksSelector
     */
    public static IProcessFlowRequestChunksSelector newInstance() {
        return (IProcessFlowRequestChunksSelector) Application.Selector.newInstance(Process_Flow_Request_Chunk__c.SObjectType);
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Process_Flow_Request_Chunk__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Process_Flow_Request__c object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Process_Flow_Request_Chunk__c.Id,
            Process_Flow_Request_Chunk__c.Name,
            Process_Flow_Request_Chunk__c.CreatedDate,
            Process_Flow_Request_Chunk__c.CreatedById,
            Process_Flow_Request_Chunk__c.LastModifiedDate,
            Process_Flow_Request_Chunk__c.LastModifiedById,
            Process_Flow_Request_Chunk__c.OwnerId,
            Process_Flow_Request_Chunk__c.Chunk_Number__c,
            Process_Flow_Request_Chunk__c.Error_Message__c,
            Process_Flow_Request_Chunk__c.Process_Flow_Request__c,
            Process_Flow_Request_Chunk__c.Serialized_Data__c,
            Process_Flow_Request_Chunk__c.Status__c
        };
    }

    /**
     * @description Returns a List of Process_Flow_Request_Chunk__c by their IDs
     * @param idSet - Set of Process_Flow_Request_Chunk__c IDs
     * @return List<Process_Flow_Request_Chunk__c>
     */
    public List<Process_Flow_Request_Chunk__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: idSet');
        return (List<Process_Flow_Request_Chunk__c>) Database.query(query.toSOQL());
    }
    
    /**
     * @description Returns Chunks for a Process Flow Request (PFR)
     * @param flowRequestId - Id of the PFR to retrieve Requests for
     * @return List<Process_Flow_Request_Chunk__c>
    **/
    public List<Process_Flow_Request_Chunk__c> selectByRequestId(Id flowRequestId) {
        fflib_QueryFactory query = newQueryFactory()
                                        .setCondition('Process_Flow_Request__c = :flowRequestId')
                                        .setOrdering('Chunk_Number__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Process_Flow_Request_Chunk__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a limite number of OPEN Chunks for a Process Flow Request (PFR)
     * @param flowRequestId - Id of the PFR to retrieve Requests for
     * @param numberOfChunks - Limit to apply to the query
     * @return List<Process_Flow_Request_Chunk__c>
    **/
    public List<Process_Flow_Request_Chunk__c> selectSubsetOfOpenChunksByRequestId(Id flowRequestId, Integer numberOfChunks) {
        fflib_QueryFactory query = newQueryFactory()
                                        .setCondition('Process_Flow_Request__c = :flowRequestId AND Status__c = :CHUNK_STATUS_IN_PROGRESS')
                                        .setOrdering('Chunk_Number__c', fflib_QueryFactory.SortOrder.ASCENDING)
                                        .setLimit(numberOfChunks);
        return (List<Process_Flow_Request_Chunk__c>) Database.query(query.toSOQL());
    }
}