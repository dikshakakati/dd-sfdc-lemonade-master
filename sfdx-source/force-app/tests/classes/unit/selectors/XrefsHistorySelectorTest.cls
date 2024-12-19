/**
 * @author Aethereus
 * @date 03/07/2024
 * @description Test class for XrefsHistorySelector class.
 */
@isTest(seeAllData=false)
private class XrefsHistorySelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String AGGREGATE_XREFSCOUNT_FIELD_ALIAS = 'xrefsCount';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_EXTERNAL_ID = 'Unexpected result: External Id does not match';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Xref__c';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final String EXTERNAL_ID = '12345';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String STORE_ID = '2480';
    private static final String POS_INTEGRATION_ID = '1122334455';
    private static final String SUCCESS = 'Success';
    private static final String WAITING_FOR_BUSINESS = 'Waiting for Business';
    static final String MDS = 'MDS';
    static final String FAILURE = 'Failure';
    static final String INTEGRATION_SUCCESS = 'Success';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    /**
     * @description Test method for selectXrefsHistory method.
     * This method tests the behavior when the method is called with valid parameters.
     */
    @isTest
    Private static void testWhenSelectXrefHistoryThenReturnHistories() {

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<String> userIds = System.Label.MINT_Upate_Users .split(';');
        List<User> users = [SELECT ID FROM USER WHERE ID IN : userIds];
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Business_Reference__c businessReference2 = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = SUCCESS
        );
        insert businessReference2;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Integration_Status__c = INTEGRATION_SUCCESS,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;

        Test.startTest();
        xref.Business_Reference__c = businessReference2.Id;
    	update xref;

        List<Xref__History> xrefHistories = XrefsHistorySelector.newInstance().selectXrefHistory(
            new Set<String>{'Field'},
            new Set<String>{'Field'},
            new List<String>{users[0].Id},
            DateTime.now().addDays(-1)
        );
        Test.stopTest();

        System.assertNotEquals(1, xrefHistories.size(), 'No xref history should be returned');

    }


}
