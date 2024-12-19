/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Test class for StoreDetailsSelector class.
 */
@isTest(SeeAllData=false)
private class StoreDetailsSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Busines Onboarding Detail';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String INCOVERAGE = 'In Coverage';
    private static final String TEST_STREET = 'Queensland Street';
    private static final String TEST_CITY_NY = 'New York';
    private static final String REJECTED = 'Rejected';
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CONTRACT_STATUS = 'Draft';
    private static final String NO = 'No';
    private static final String ONBOARDING_SCENARIO = 'Net-New';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        StoreDetailsSelector storeDetailsInstance = new StoreDetailsSelector();
        Schema.SObjectType typeOfObject = storeDetailsInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = storeDetailsInstance.getSObjectFieldList();
        StoreDetailsSelector.newInstance();
        System.assertEquals(
            Schema.Store_Detail__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Store_Detail__c.Menu_Setup_Method__c,
                Store_Detail__c.Menu_to_be_Completed_By__c,
                Store_Detail__c.Sales_Notes_for_Menu_Team__c,
                Store_Detail__c.Address_Verification_Status__c,
                Store_Detail__c.Mx_Onboarding_Link__c,
                Store_Detail__c.Address__CountryCode__s,
                Store_Detail__c.Address__StateCode__s,
                Store_Detail__c.Address__City__s,
                Store_Detail__c.Address__PostalCode__s,
                Store_Detail__c.Address__Street__s,
                Store_Detail__c.Address__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test if Store Details are retuned when Ids are passed.
     */
    @isTest
    private static void testWhenIdsSentThenReturnStoreDetails() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Contract contractInstance = new Contract(
            AccountId = businessAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Mx_Onboarding_Link__c mxOnboardingLink = new Mx_Onboarding_Link__c(
            Business_Account__c = businessAccount.Id,
            Contract__c = contractInstance.Id,
            Onboarding_Scenario__c = ONBOARDING_SCENARIO,
            Rep_Collecting_On_Mx_Behalf__c = NO,
            Expiration_Date_Time__c = System.today().addDays(10),
            Status__c = STATUS_ACTIVE,
            Record_Creation_Status__c = STATUS_SUCCESS
        );
        insert mxOnboardingLink;
        List<Store_Detail__c> storeDetailRecords = new List<Store_Detail__c>{
            new Store_Detail__c(
                Address_Verification_Status__c = REJECTED,
                Address__Street__s = TEST_STREET,
                Address__City__s = TEST_CITY_NY,
                Coverage__c = INCOVERAGE,
                Mx_Onboarding_Link__c = mxOnboardingLink.Id
            ),
            new Store_Detail__c(
                Address_Verification_Status__c = REJECTED,
                Address__Street__s = TEST_STREET,
                Address__City__s = TEST_CITY_NY,
                Coverage__c = INCOVERAGE,
                Mx_Onboarding_Link__c = mxOnboardingLink.Id
            )
        };
        insert storeDetailRecords;
        Test.startTest();
        List<Store_Detail__c> queryResult = StoreDetailsSelector.newInstance()
            .selectById(new Set<Id>{ storeDetailRecords[0].Id, storeDetailRecords[1].Id });
        Test.stopTest();
        System.assertEquals(2, queryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}