/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Selector class for PermissionSetAssignment object.
 */
public inherited sharing class PermissionSetAssignmentsSelector extends fflib_SObjectSelector implements IPermissionSetAssignmentsSelector {
    private static final String PERMISSIONSET_STRATEGYANDOPERATIONS = 'Strategy_and_Operations';

    /**
     * @description Default constructor for the PermissionSetAssignment selector class.
     * @return IPermissionSetAssignmentsSelector
     */
    public static IPermissionSetAssignmentsSelector newInstance() {
        return (IPermissionSetAssignmentsSelector) Application.Selector.newInstance(
            PermissionSetAssignment.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on PermissionSetAssignment object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PermissionSetAssignment.Id,
            PermissionSetAssignment.AssigneeId,
            PermissionSetAssignment.PermissionSetId,
            PermissionSetAssignment.PermissionSetGroupId
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.SObjectType;
    }

    /**
     * @description This method is used for getting PermissionSetAssignment record by AssigneeIds
     * and is not of type profile
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     */
    public List<PermissionSetAssignment> selectByAssigneeIds(Set<Id> assigneeIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('permissionSet.IsOwnedByProfile = FALSE AND Assignee.Id IN: assigneeIds');
        return (List<PermissionSetAssignment>) Database.query(query.toSOQL());
    }

    /**
     * @description Used for getting PermissionSetAssignment record by AssigneeIds..
     * and Permission Set name Strategy_and_Operations
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     */
    public List<PermissionSetAssignment> selectByStrategyandOperationsAndAssigneeIds(
        Set<Id> assigneeIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'permissionSet.NAME =: PERMISSIONSET_STRATEGYANDOPERATIONS AND Assignee.Id IN: assigneeIds'
            );
        return (List<PermissionSetAssignment>) Database.query(query.toSOQL());
    }

    /**
     * @description Gets PSAs from the Permission Set Names and Assignee IDs
     * @param permissionSetNames
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     **/
    public List<PermissionSetAssignment> selectByPermissionSetNameAndAssigneeId(
        Set<String> permissionSetNames,
        Set<Id> assigneeIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'permissionSet.NAME IN :permissionSetNames AND Assignee.Id IN :assigneeIds'
            );
        return (List<PermissionSetAssignment>) Database.query(query.toSOQL());
    }

    /**
     * @description Gets PSAs from the Permission Set Group Names
     * @param psgName
     * @return List<PermissionSetAssignment>
     **/
    public List<PermissionSetAssignment> selectByPermissionSetGroupName(String psgName) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('PermissionSetGroup.DeveloperName = :psgName');
        return (List<PermissionSetAssignment>) Database.query(query.toSOQL());
    }

    /**
     * @description Gets PSAs from the Permission Set Names and Assignee IDs
     * @param permissionSetGroupName
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     **/
    public List<PermissionSetAssignment> selectByPermissionSetGroupNameAndAssigneeId(
        String permissionSetGroupName,
        Set<Id> assigneeIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'AssigneeId IN :assigneeIds AND PermissionSetGroup.DeveloperName = :permissionSetGroupName'
            );
        return (List<PermissionSetAssignment>) Database.query(query.toSOQL());
    }
}