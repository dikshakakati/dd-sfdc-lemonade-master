/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Selector class for PermissionSetLicenseAssignment object.
 */
public inherited sharing class PermissionSetLicenseAssignmentsSelector extends fflib_SObjectSelector implements IPermissionSetLicenseAssignmentsSelector {
    /**
     * @description Default constructor for the PermissionSetLicenseAssignment selector class.
     * @return IPermissionSetLicenseAssignmentsSelector
     */
    public static IPermissionSetLicenseAssignmentsSelector newInstance() {
        return (IPermissionSetLicenseAssignmentsSelector) Application.Selector.newInstance(
            PermissionSetLicenseAssign.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on PermissionSetLicenseAssignment object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ PermissionSetLicenseAssign.Id };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PermissionSetLicenseAssign.SObjectType;
    }

    /**
     * @description This method is used for getting PermissionSetLicenseAssignment records by AssigneeIds
     * @param assigneeIds
     * @return List<PermissionSetLicenseAssign>
     */
    public List<PermissionSetLicenseAssign> selectByAssigneeIds(Set<Id> assigneeIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Assignee.Id IN: assigneeIds');
        return (List<PermissionSetLicenseAssign>) Database.query(query.toSOQL());
    }
}