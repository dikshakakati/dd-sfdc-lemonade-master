/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for StagingBulkUploadRequestSelector class.
 */
@isTest
private class StagingBulkUploadRequestSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Staging_Bulk_Upload_Request__c';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final String ASSERT_MESSAGE_STAGING_REQUEST_ORDER_PROTOCOL = 'Unexpected result: Order Protocl is not matching';
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_COUNTRY_CODE = 'US';
    private static final string ACCOUNT_BILLING_STATE_CODE = 'CA';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String SUB_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String STATUS_SUCCESS = 'Success';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        StagingBulkUploadRequestSelector stagingRequestInstance = new StagingBulkUploadRequestSelector();
        Schema.SObjectType typeOfObject = stagingRequestInstance.getSObjectType();
        StagingBulkUploadRequestSelector.newInstance();
        System.assertEquals(
            Schema.Staging_Bulk_Upload_Request__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the Staging Request Records selection when Reference Id is passed.
     */
    @isTest
    private static void testWhenReferenceIdsPassedThenReturnReferenceRequestRecords() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert newContact;

        Staging_Bulk_Upload_Reference__c stagingReferenceRec = new Staging_Bulk_Upload_Reference__c();
        stagingReferenceRec.Type__c = TYPE_MARKETING_KIT;
        stagingReferenceRec.Request_Type__c = TYPE_MARKETING_KIT;
        stagingReferenceRec.Status__c = STATUS_SUCCESS;
        insert stagingReferenceRec;

        Staging_Bulk_Upload_Request__c stagingRequestRec = new Staging_Bulk_Upload_Request__c();
        stagingRequestRec.Staging_Upload_Ref__c = stagingReferenceRec.Id;
        stagingRequestRec.Order_Protocol__c = TYPE_TABLET;
        stagingRequestRec.Address__CountryCode__s = ACCOUNT_BILLING_COUNTRY_CODE;
        stagingRequestRec.Address__Street__s = ACCOUNT_BILLING_STREET;
        stagingRequestRec.Address__City__s = ACCOUNT_BILLING_CITY;
        stagingRequestRec.Address__StateCode__s = ACCOUNT_BILLING_STATE_CODE;
        stagingRequestRec.Address__PostalCode__s = ACCOUNT_BILLING_POSTAL_CODE;
        stagingRequestRec.Business_ID__c = businessAccount.Id;
        stagingRequestRec.Contact_Id__c = newContact.Id;
        stagingRequestRec.Store_ID__c = storeAccount.Id;
        insert stagingRequestRec;

        Test.startTest();
        Database.QueryLocator bulkUploadRequestRecords = StagingBulkUploadRequestSelector.newInstance().selectStagingRequestsByReferenceIds(new Set<String>{ stagingReferenceRec.id });
        Test.stopTest();

        Database.QueryLocatorIterator iteratorOnBulkUploadRequestRecords = bulkUploadRequestRecords.iterator();
        List<Staging_Bulk_Upload_Request__c> fetchedBulkUploadRequestRecords = new List<Staging_Bulk_Upload_Request__c>();

        while (iteratorOnBulkUploadRequestRecords.hasNext()) {
            fetchedBulkUploadRequestRecords.add((Staging_Bulk_Upload_Request__c) iteratorOnBulkUploadRequestRecords.next());
        }
        System.assertEquals(
            1,
            fetchedBulkUploadRequestRecords.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            TYPE_TABLET,
            fetchedBulkUploadRequestRecords[0].Order_Protocol__c,
            ASSERT_MESSAGE_STAGING_REQUEST_ORDER_PROTOCOL
        );
    }
}
