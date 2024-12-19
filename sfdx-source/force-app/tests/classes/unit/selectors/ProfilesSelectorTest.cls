/**
 * @author BizApps
 * @date 11 April 2024
 * @description Test class for ProfilesSelector class.
 */
@isTest(SeeAllData=false)
private class ProfilesSelectorTest {
    /**
     * @description To test Contructor instantiation.
     **/
    @IsTest
    private static void testWhenClassInstantiatesThenCall() {
        Schema.SObjectType typeOfObject = ProfilesSelector.newInstance().SObjectType();
        List<Schema.SObjectField> profileFieldsMock = new List<Schema.SObjectField>{
            Profile.Id,
            Profile.Name
        };

        List<Schema.SObjectField> sObjectFields = ProfilesSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            Profile.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Profile'
        );
        System.assertEquals(
            profileFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    @IsTest
    static void testWhenSelectingByNameThenReturnProfiles() {
        List<Profile> adminProfiles = ProfilesSelector.newInstance()
            .selectById(new Set<Id>{ SandboxRefreshPostProcessor.systemAdminProfileId });
        System.assertEquals(
            1,
            adminProfiles.size(),
            'One, and only one, Admin proile should be returned based on its ID'
        );

        adminProfiles = ProfilesSelector.newInstance()
            .selectByNames(new Set<String>{ adminProfiles[0].Name });
        System.assertEquals(
            1,
            adminProfiles.size(),
            'One, and only one, Admin proile should be returned based on its Name'
        );
    }
}