/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Test class for MxOnboardingLinksSelector class.
 */
@isTest(SeeAllData=false)
private class MxOnboardingLinksSelectorTest {
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CONTRACT_STATUS = 'Draft';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String NO = 'No';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Mx Onboarding Link';
    private static final String ONBOARDING_SCENARIO = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NSE = 'NSE';
    private static final String QUERY_RETURN_NO_MX_ONBOARDING_LINKS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any Mx_Onboarding_Link__c';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String YES = 'Yes';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        MxOnboardingLinksSelector mxOnboardingLinksInstance = new MxOnboardingLinksSelector();
        Schema.SObjectType typeOfObject = mxOnboardingLinksInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = mxOnboardingLinksInstance.getSObjectFieldList();
        MxOnboardingLinksSelector.newInstance();
        System.assertEquals(
            Schema.Mx_Onboarding_Link__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Mx_Onboarding_Link__c.Business_Account__c,
                Mx_Onboarding_Link__c.Contract__c,
                Mx_Onboarding_Link__c.Expiration_Date_Time__c,
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                Mx_Onboarding_Link__c.One_Time_Mx_Link__c,
                Mx_Onboarding_Link__c.Payment_Method__c,
                Mx_Onboarding_Link__c.Payload__c,
                Mx_Onboarding_Link__c.Product_on_Contract__c,
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                Mx_Onboarding_Link__c.Source__c,
                Mx_Onboarding_Link__c.UUID__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test Mx onboarding link is returned using the passed contract Id.
     */
    @isTest
    private static void testWhenSelectByContractIdsCalledThenReturnMxOnboardingLink() {
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
        Test.startTest();
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .selectByContractIds(new Set<Id>{ contractInstance.Id });
        Test.stopTest();
        System.assertEquals(
            !mxOnboardingLinks.isEmpty(),
            true,
            QUERY_RETURN_NO_MX_ONBOARDING_LINKS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Mx onboarding link and related Onboarding Details and Store details are returned using the passed contract Id.
     */
    @isTest
    private static void testWhenMxOnboardingLinkIdsPassedThenReturnOnboardingLinksAndRelatedInformation() {
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
        Business_Onboarding_Detail__c businessOnboardingDetails = new Business_Onboarding_Detail__c(
            Mx_Onboarding_Link__c = mxOnboardingLink.Id
        );
        Store_Detail__c storeDetails = new Store_Detail__c(
            Mx_Onboarding_Link__c = mxOnboardingLink.Id
        );
        insert businessOnboardingDetails;
        insert storeDetails;
        Test.startTest();
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .selectByMxOnboardingLinkIds(new Set<Id>{ mxOnboardingLink.Id });
        Test.stopTest();
        System.assertEquals(
            !mxOnboardingLinks.isEmpty(),
            true,
            QUERY_RETURN_NO_MX_ONBOARDING_LINKS_ASSERT_MESSAGE
        );
    }

    /**
     * @description - select mx related records
     * @author Soumya Dash | 08-19-2024
     **/
    @isTest
    private static void testWhenIdThenSelectRelatedStoreAndBUsinessOnboardingRecord() {
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
            Onboarding_Scenario__c = ONBOARDING_SCENARIO_NSE,
            Rep_Collecting_On_Mx_Behalf__c = NO,
            Expiration_Date_Time__c = System.today().addDays(10),
            Status__c = STATUS_ACTIVE,
            Record_Creation_Status__c = STATUS_SUCCESS
        );
        insert mxOnboardingLink;
        Business_Onboarding_Detail__c businessOnboardingDetails = new Business_Onboarding_Detail__c(
            Mx_Onboarding_Link__c = mxOnboardingLink.Id
        );
        Store_Detail__c storeDetails = new Store_Detail__c(
            Mx_Onboarding_Link__c = mxOnboardingLink.Id
        );
        insert businessOnboardingDetails;
        insert storeDetails;
        Test.startTest();
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .selectByIdWithPayloadAndRelated(mxOnboardingLink.Id);
        Test.stopTest();

        System.assertEquals(
            !mxOnboardingLinks.isEmpty(),
            true,
            QUERY_RETURN_NO_MX_ONBOARDING_LINKS_ASSERT_MESSAGE
        );
    }
}