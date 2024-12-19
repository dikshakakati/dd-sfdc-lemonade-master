/**
 * @author Deloitte
 * @date 07/08/2024
 * @description Test class for AccountPlansSelector class.
 */
@isTest(seeAllData=false)
private class AccountPlansSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Xref__c';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String ACTIVE = 'Active';
    private static final String INACTIVE = 'Inactive';
    private static final String ACCOUNT_PLAN_NAME = 'Acc Q1 Netflix';
    private static final String ACCOUNT_SEGMENT_SMB= 'SMB';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        AccountPlansSelector accountPlansInstance = new AccountPlansSelector();
        Schema.SObjectType typeOfObject = accountPlansInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = accountPlansInstance.getSObjectFieldList();
        AccountPlansSelector.newInstance();
        System.assertEquals(
            Schema.Account_Plan__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Account_Plan__c.Id,
                Account_Plan__c.Name,
                Account_Plan__c.Status__c,
                Account_Plan__c.Account__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test when account ids are passed then active account plans are returned.
     */
    @isTest
    private static void testWhenAccountIdPassedThenActiveAccountPlanRetrieved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
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

        Account_Plan__c accountPlan = new Account_Plan__c(
            Name = ACCOUNT_PLAN_NAME,
            Status__c = ACTIVE,
            Account__c = businessAccount.Id
        );
        insert accountPlan;

        AccountPlansSelector accountPlansInstance = new AccountPlansSelector();
        List<Account_Plan__c> activeAccountPlans = accountPlansInstance.selectActiveAccountPlanByAccounts(
            new Set<Id>{ businessAccount.Id }
        );

        System.assertEquals(1, activeAccountPlans.size(), 'Account Plan List size does not match');
    }

    /**
     * @description To test when account ids are passed then inactive account plans are not returned.
     */
    @isTest
    private static void testWhenAccountIdPassedThenInActiveAccountPlanNotReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
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

        Account_Plan__c accountPlan = new Account_Plan__c(
            Name = ACCOUNT_PLAN_NAME,
            Status__c = INACTIVE,
            Account__c = businessAccount.Id
        );
        insert accountPlan;

        AccountPlansSelector accountPlansInstance = new AccountPlansSelector();
        List<Account_Plan__c> activeAccountPlans = accountPlansInstance.selectActiveAccountPlanByAccounts(
            new Set<Id>{ businessAccount.Id }
        );

        System.assertEquals(0, activeAccountPlans.size(), 'Account Plan List size does not match');
    }
}