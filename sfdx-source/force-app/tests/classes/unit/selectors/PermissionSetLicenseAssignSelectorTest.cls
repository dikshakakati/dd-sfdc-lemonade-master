/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Test class for PermissionSetLicenseAssignmentsSelector class.
 */
@isTest(SeeAllData=false)
private class PermissionSetLicenseAssignSelectorTest {
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Schema.SObjectType typeOfObject = PermissionSetLicenseAssignmentsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> permissionSetLicenseAssignmentFieldsMock = new List<Schema.SObjectField>{
            PermissionSetLicenseAssign.Id
        };
        List<Schema.SObjectField> sObjectFields = PermissionSetLicenseAssignmentsSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            PermissionSetLicenseAssign.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be PermissionSetLicenseAssign'
        );
        System.assertEquals(
            permissionSetLicenseAssignmentFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description This method is used for getting permission set license assignment records when assignee id is passed.
     */
    @isTest
    private static void testWhenSelectByAssigneeIdThenReturnPermissionSetLicenseAssignments() {
        User userWithPermissionSetLicense = TestDataFactory.createUser(true);

        PermissionSetLicense customPermisionSetLicense = [
            SELECT Id
            FROM PermissionSetLicense
            WHERE MasterLabel = 'Salesforce CPQ License'
            LIMIT 1
        ];

        PermissionSetLicenseAssign permissionSetLicenseAssignment = new PermissionSetLicenseAssign(
            AssigneeId = userWithPermissionSetLicense.Id,
            PermissionSetLicenseId = customPermisionSetLicense.Id
        );
        insert permissionSetLicenseAssignment;

        Set<Id> assigneeIds = new Set<Id>{ userWithPermissionSetLicense.Id };
        List<PermissionSetLicenseAssign> permissionSetLicenseAssignmentsReturned = PermissionSetLicenseAssignmentsSelector.newInstance()
            .selectByAssigneeIds(assigneeIds);

        System.assertEquals(
            permissionSetLicenseAssignmentsReturned[0].Id,
            permissionSetLicenseAssignment.Id,
            'Mismatch in PermissionSetLicenseAssign'
        );
    }
}