/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Test class for PermissionSetAssignmentSelector class.
 */
@isTest(SeeAllData=false)
private class UserPackageLicensesSelectorTest {
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Schema.SObjectType typeOfObject = UserPackageLicensesSelector.newInstance().SObjectType();
        List<Schema.SObjectField> userPackageLicenseFieldsMock = new List<Schema.SObjectField>{
            UserPackageLicense.Id
        };
        List<Schema.SObjectField> sObjectFields = UserPackageLicensesSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            UserPackageLicense.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be UserPackageLicense'
        );
        System.assertEquals(
            userPackageLicenseFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description This method is used for getting user package licenses records when user id is passed.
     */
    @isTest
    private static void testWhenSelectByAssigneeIdThenReturnNoRecords() {
        User userWithNoLicense = TestDataFactory.createUser(true);

        Set<Id> userIds = new Set<Id>{ userWithNoLicense.Id };

        List<UserPackageLicense> userLicenseAssignmentsReturned = UserPackageLicensesSelector.newInstance()
            .selectByUserIds(userIds);

        System.assertEquals(
            userLicenseAssignmentsReturned.size(),
            0,
            'Mismatch in UserPackageLicense'
        );
    }
}