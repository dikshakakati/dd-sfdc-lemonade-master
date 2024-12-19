/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Test class for OrgWideEmailAddressesSelector class.
 */
@isTest(SeeAllData=false)
private class OrgWideEmailAddressesSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Org Wide Email Address.';
    private static final String OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The Org Wide Email Address is not returned.';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        OrgWideEmailAddressesSelector orgWideEmailSelectorInstance = new OrgWideEmailAddressesSelector();
        Schema.SObjectType typeOfObject = orgWideEmailSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = orgWideEmailSelectorInstance.getSObjectFieldList();
        OrgWideEmailAddressesSelector.newInstance();
        System.assertEquals(
            Schema.OrgWideEmailAddress.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                OrgWideEmailAddress.Id,
                OrgWideEmailAddress.Address,
                OrgWideEmailAddress.DisplayName
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Org Wide Email Address details are selected based on passed address.
     */
    @isTest
    private static void testWhenAddressArePassedThenReturnOrgWideEmailAddress() {
        OrgWideEmailAddress testOrgWideEmailAddress = [
            SELECT Id, DisplayName
            FROM OrgWideEmailAddress
            LIMIT 1
        ][0];
        List<OrgWideEmailAddress> queryResult = OrgWideEmailAddressesSelector.newInstance()
            .selectOrgWideAddressByDisplayNames(
                new Set<String>{ testOrgWideEmailAddress.DisplayName }
            );
        System.assertEquals(
            testOrgWideEmailAddress.Id,
            queryResult[0].Id,
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}