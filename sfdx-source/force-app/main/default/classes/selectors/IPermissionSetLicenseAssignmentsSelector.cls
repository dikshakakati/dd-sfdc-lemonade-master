/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Interface to PermissionSetLicenseAssign selector class methods
 */
public interface IPermissionSetLicenseAssignmentsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on PermissionSetLicenseAssign
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting PermissionSetLicenseAssignment records by AssigneeIds
     * @param assigneeIds
     * @return List<PermissionSetLicenseAssign>
     */
    List<PermissionSetLicenseAssign> selectByAssigneeIds(Set<Id> assigneeIds);
}