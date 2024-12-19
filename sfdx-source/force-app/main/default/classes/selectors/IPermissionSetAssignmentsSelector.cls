/**
 * @author Deloitte
 * @date 27/02/2023
 * @description Interface to PermissionSetAssignment selector class methods.
 */
public interface IPermissionSetAssignmentsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on PermissionSetAssignment
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting PermissionSetAssignment records by AssigneeIds
     * and is not of type profile
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     */
    List<PermissionSetAssignment> selectByAssigneeIds(Set<Id> assigneeIds);

    /**
     * @description This method is used for getting PermissionSetAssignment record by AssigneeIds
     * and Permission Set name Strategy_and_Operations.
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     */
    List<PermissionSetAssignment> selectByStrategyandOperationsAndAssigneeIds(Set<Id> assigneeIds);

    /**
     * @description Gets PSAs from the Permission Set Names and Assignee IDs
     * @param permissionSetNames
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     **/
    List<PermissionSetAssignment> selectByPermissionSetNameAndAssigneeId(
        Set<String> permissionSetNames,
        Set<Id> assigneeIds
    );

    /**
     * @description Gets PSAs from the Permission Set Group Names
     * @param psgName
     * @return List<PermissionSetAssignment>
     **/
    List<PermissionSetAssignment> selectByPermissionSetGroupName(String psgName);

    /**
     * @description Gets PSAs from the Permission Set Names and Assignee IDs
     * @param permissionSetGroupName
     * @param assigneeIds
     * @return List<PermissionSetAssignment>
     **/
    List<PermissionSetAssignment> selectByPermissionSetGroupNameAndAssigneeId(
        String permissionSetGroupName,
        Set<Id> assigneeIds
    );
}