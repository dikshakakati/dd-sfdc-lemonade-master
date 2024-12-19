/**
 * @author Deloitte
 * @date 29/04/2024
 * @description Selector Class for Task Object
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public inherited sharing class TaskRelationsSelector extends fflib_SObjectSelector implements ITaskRelationsSelector{
	/**
     * @description Default constructor for the class
     * @return ITaskRelationsSelector - interface of ITaskRelationsSelector.
     */
    public static ITaskRelationsSelector newInstance() {
        return (ITaskRelationsSelector) Application.Selector.newInstance(
            TaskRelation.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method.
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return TaskRelation.SObjectType;
    }
    
    /**
     * @description This method is for getting the fields on TaskRelation
     * @return List<Schema.SObjectField>- TaskRelation fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            TaskRelation.Id,
            TaskRelation.taskId,
            TaskRelation.RelationId
        };
    }
    
    /**
     * @description  It is used to get taskRelation by Task Ids.
     * @param taskIds
     * @return List<TaskRelation>
     */
    public List<TaskRelation> selectByTaskIds(Set<Id> taskIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('taskId IN :taskIds');
        return (List<TaskRelation>) Database.query(query.toSOQL());
    }
}