/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Test class for PaymentAccountsSelector class.
 */
@isTest(seeAllData=false)
private class PaymentAccountsSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String CONTACT_EMAIL = 'test@ContactPaymentAccountRelationsSelectTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final String BILLING_CONTACT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Billing Contact Id does not match';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: mismatch in field list';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Payment_Account__c.FieldSets.Encrypted_Fields;
    private static final Id INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Invoice')
        .getRecordTypeId();
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the object type must be Payment_Account__c';
    private static final String PAYMENT_ACCOUNT_BANK_ACCOUNT_NUMBER = '1234567';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        PaymentAccountsSelector paymentAccountsSelectorInstance = (PaymentAccountsSelector) PaymentAccountsSelector.newInstance();
        Schema.SObjectType typeOfObject = paymentAccountsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = paymentAccountsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Payment_Account__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Payment_Account__c.Id,
                Payment_Account__c.Billing_Contact_Name__c,
                Payment_Account__c.Payment_Terms__c,
                Payment_Account__c.NetSuite_ID__c,
                Payment_Account__c.recordTypeId,
                Payment_Account__c.Bank_Account_Number__c,
                Payment_Account__c.Billing_Contact_Email__c,
                Payment_Account__c.Bill_To_Company_Name__c,
                Payment_Account__c.Country_Code_Alpha_2__c,
                Payment_Account__c.Address_Line_1__c,
                Payment_Account__c.State__c,
                Payment_Account__c.Country__c,
                Payment_Account__c.City__c,
                Payment_Account__c.Postal_Code__c,
                Payment_Account__c.Currency__c,
                Payment_Account__c.CurrencyIsoCode,
                Payment_Account__c.DoorDash_Legal_Entity__c,
                Payment_Account__c.Institution_Number__c,
                Payment_Account__c.NetSuite_Sync_Status__c,
                Payment_Account__c.Netsuite_Sync_Initiator__c,
                Payment_Account__c.NetSuite_Sync_Response__c,
                Payment_Account__c.Business_Unit__c,
                Payment_Account__c.RoutingNumber__c,
                Payment_Account__c.Name
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test the query on Payment Account when encrypted FieldSet
     * and Payment Account Ids are passed.
     */
    @isTest
    private static void testWhenFieldSetAndPaymentAccountIdsArePassedThenReturnPaymentAccountFieldsUsingFieldSet() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = storeAccount.Id,
            Email = CONTACT_EMAIL,
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert contact;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Bank_Account_Number__c = PAYMENT_ACCOUNT_BANK_ACCOUNT_NUMBER
        );
        insert paymentAccount;
        Test.startTest();
        List<SObject> sObjects = ((IEncryptedDataSelector) Application.Selector.newInstance(
                paymentAccount.Id.getSobjectType()
            ))
            .selectEncryptedData(
                (Schema.FieldSet) FIELDS_TO_QUERY,
                new Set<Id>{ paymentAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(1, sObjects.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test the query on Payment Account when Payment Account Ids are passed.
     */
    @isTest
    private static void testWhenPaymentAccountIdsPassedThenPaymentAccountsReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = storeAccount.Id,
            Email = CONTACT_EMAIL,
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert contact;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Bank_Account_Number__c = PAYMENT_ACCOUNT_BANK_ACCOUNT_NUMBER,
            Billing_Contact_Name__c = contact.Id
        );
        insert paymentAccount;
        Test.startTest();
        List<Payment_Account__c> paymentAccounts = PaymentAccountsSelector.newInstance()
            .selectById(new Set<Id>{ paymentAccount.Id });
        Test.stopTest();
        System.assertEquals(1, paymentAccounts.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            contact.Id,
            paymentAccounts[0].Billing_Contact_Name__c,
            BILLING_CONTACT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test the query on Payment Account when Payment Account Ids are passed.
     */
    @isTest
    private static void testWhenIdPassedThenPaymentAccountsReturnedWithOAuthConfigFields() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = storeAccount.Id,
            Email = CONTACT_EMAIL,
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert contact;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Address_Line_1__c = 'any street 0909',
            Bank_Account_Number__c = PAYMENT_ACCOUNT_BANK_ACCOUNT_NUMBER,
            Bill_To_Company_Name__c = 'any inc',
            Billing_Contact_Name__c = contact.Id,
            Billing_Contact_Name__r = contact,
            City__c = 'Golden City',
            Country__c = 'United States',
            Currency__c = 'USD',
            Payment_Terms__c = 'Net 30',
            Postal_Code__c = '94808',
            State__c = 'theState'
        );
        insert paymentAccount;
        List<OAuth_Config__c> configs = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Data_Map_Type__c = 'Outbound',
                Name = 'Payment Account',
                Key__c = 'Address_Line_1__c',
                Value__c = 'address.addr1'
            ),
            new OAuth_Config__c(
                Data_Map_Type__c = 'Outbound',
                Name = 'Payment Account',
                Key__c = 'Postal_Code__c',
                Value__c = 'address.zip'
            ),
            new OAuth_Config__c(
                Data_Map_Type__c = 'Outbound',
                Name = 'Payment Account',
                Key__c = 'Bill_To_Company_Name__c',
                Value__c = 'company_name'
            ),
            new OAuth_Config__c(
                Data_Map_Type__c = 'Outbound',
                Name = 'Payment Account',
                Key__c = 'State__c',
                Value__c = 'address.state'
            ),
            new OAuth_Config__c(
                Data_Map_Type__c = 'Outbound',
                Name = 'Payment Account',
                Key__c = 'City__c',
                Value__c = 'address.city'
            )
        };
        insert configs;
        Payment_Account__c expectedPaymentAccount = new Payment_Account__c(
            Id = paymentAccount.Id,
            Address_Line_1__c = 'any street 0909',
            Bill_To_Company_Name__c = 'any inc',
            City__c = 'Golden City',
            Postal_Code__c = '94808',
            State__c = 'theState'
        );
        Test.startTest();
        Payment_Account__c queryResult = PaymentAccountsSelector.newInstance()
            .selectPaymentAccountByIdForNetsuiteIntegration(paymentAccount.Id);
        Test.stopTest();
        system.assertEquals(
            expectedPaymentAccount,
            queryResult,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test the query on Payment Account when related Business Account is queried
     * and Payment Account Ids are passed.
     * @JIRA# LEM-3121
     */
    @isTest
    private static void testWhenAccountIdsArePassedThenReturnRelatedPaymentAccount() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id paymentAccountInvoiceType = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Invoice')
            .getRecordTypeId();
        Account businessAccount = new Account(
            recordTypeId = accRecordTypeBusiness,
            Name = 'Test1',
            CurrencyIsoCode = 'USD',
            Segment__c = 'SMB'
        );
        insert businessAccount;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Business_Account__c = businessAccount.Id,
            recordTypeId = paymentAccountInvoiceType
        );
        insert paymentAccount;
        Test.startTest();
        List<Payment_Account__c> queryResult = PaymentAccountsSelector.newInstance()
            .selectRelatedBusinessAccounts(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            queryResult.size(),
            'The retrieved list of Payment Accounts do not have the necessary number of records'
        );
    }

    /**
     * @description To validate the selection of Payment Accounts with the 'Invoice' record type
     * based on the passed Payment Account Ids from the csv file
     * @JIRA# LEM-10203
     */
    @isTest
    private static void testWhenPaymentAccountIdPassedThenReturnPaymentAccountWithRecordTypeInvoice() {
        Account businessAccount = new Account(Name = 'TestAccount', Segment__c = 'SMB');
        insert businessAccount;

        Set<Id> paymentAccountIds = new Set<Id>();
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Business_Account__c = businessAccount.Id,
            recordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
                .get('Invoice')
                .getRecordTypeId()
        );
        insert paymentAccount;
        paymentAccountIds.add(paymentAccount.Id);
        Test.startTest();
        List<Payment_Account__c> queriedPaymentAccount = PaymentAccountsSelector.newInstance()
            .selectInvoicePaymentAccountsByIds(paymentAccountIds);
        Test.stopTest();
        System.assertEquals(1, queriedPaymentAccount.size(), 'The Record Type is not Invoice');
    }
}