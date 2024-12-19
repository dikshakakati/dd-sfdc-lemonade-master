/**
 * @author Deloitte
 * @date 07/11/2024
 * @description This is the test class for ProcessChurnedMerchantRecordsBatch class
 */
@isTest(SeeAllData=false)
private class ProcessChurnedMerchantRecordsBatchTest {
    private static final String ASSERTION_FAILED = 'Unexpected Result: Batch did not execute successfully';
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String BATCH_NAME = 'ProcessChurnedMerchantRecordsScheduledBatch';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String AGREEMENT_STATUS_PENDING = 'Pending';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String NAME_ACCOUNT = 'Test Acc';
    private static final String NAME_OPPORTUNITY = 'Test Opportunity';
    private static final String NAME_ACCOUNT_CHILD = 'Test Acc Child';
    private static final String UNITED_STATES = 'United States';
    private static final String BILLING_STREET = '123 Test Street';
    private static final String BILLING_CITY = 'Missoula';
    private static final String BILLING_CITY2 = 'New York';
    private static final String BILLING_STATE = 'Montana';
    private static final String BILLING_CODE = '59801';
    private static final String BILLING_CODE2 = '59802';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRODUCT_CODE_10017 = '10017';
    private static final String PRIMARY_VERTICAL = 'Hot & Prepared';
    private static final String CONTRACTTYPE_CHURNEDMERCHANT = 'Churned Merchant';
    private static final String CONTRACTTYPE_CORE = 'Core';
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String PROCESS_CHURNED_MX_CONTRACTS_RECORDS_SCOPE_METADATA = 'ProcessChurnedMxContractRecordsScope';
    private static final String STAGENAME = 'Prospecting';
    private static final String DEAL_TYPE = 'Standard';
    private static final String OPPORTUNITY_SUB_TYPE = 'Former Partner';
    private static final String XREF_EXTERNAL_ID = '12345';

    /**
     * @description It is used to test whether the batch is invoked for the Contract with type as
     * "Churned Merchant". It also checks whether the associated child records are deleted or updated.
     */
    @isTest
    private static void testWhenChurnedMxContractsExecutedByBatchThenChildRecordsDeletedOrUpdated() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();
        SBQQ.TriggerControl.disable();
        Account businessAccount = new Account(
            Name = NAME_ACCOUNT,
            RecordTypeId = businessRecordTypeId,
            BillingCountry = UNITED_STATES,
            Segment__c = ACCOUNT_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );

        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY2,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE2,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );
        insert businessAccount;
        insert childAccount;
        Opportunity testOpp = new Opportunity(
            AccountId = businessAccount.Id,
            Name = NAME_OPPORTUNITY,
            CloseDate = System.today() + 30,
            StageName = STAGENAME,
            Deal_Type__c = DEAL_TYPE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Estimated_Number_of_Stores__c = 1
        );
        insert testOpp;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, businessAccount, null, true);
        Order order = CPQTestDataFactory.createOrder(businessAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;

        Order churnedMxOrder = [SELECT Id, SBQQ__Quote__c, AccountId FROM Order];
        churnedMxOrder.Type = CONTRACTTYPE_CHURNEDMERCHANT;
        update churnedMxOrder;

        Contract contractInstance = new Contract(
            AccountId = businessAccount.Id,
            SBQQ__Order__c = churnedMxOrder.Id,
            Is_Churned_Mx_Contract_Processed__c = false
        );
        insert contractInstance;
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        insert marketplaceProduct;
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = contractInstance.Id,
            SBQQ__Account__c = businessAccount.Id,
            SBQQ__Quantity__c = 200
        );
        insert subscription;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        insert marketplaceMerchantService;
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = childAccount.Id,
            Contract__c = contractInstance.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;
        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Salesforce_Account_Name__c = childAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = XREF_EXTERNAL_ID
            )
        };
        insert xrefs;
        WorkOrder parentStorefrontWorkOrderInstance = new WorkOrder(
            AccountId = businessAccount.Id,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Contract__c = contractInstance.Id,
            Opportunity__c = testOpp.Id
        );
        insert parentStorefrontWorkOrderInstance;
        SBQQ.TriggerControl.enable();
        Test.startTest();
        Database.executeBatch(new ProcessChurnedMerchantRecordsBatch());
        Test.stopTest();
        List<Xref__c> inactiveXrefs = [
            SELECT Id, Salesforce_Account_Name__c, Xref_Status__c
            FROM Xref__c
            WHERE Salesforce_Account_Name__c = :childAccount.Id
        ];
        List<Agreement__c> agreements = [
            SELECT Id
            FROM Agreement__c
            WHERE Contract__c = :contractInstance.Id
        ];
        List<Contract> updatedContracts = [
            SELECT Id, Is_Churned_Mx_Contract_Processed__c
            FROM Contract
            WHERE Id = :contractInstance.Id
        ];
        System.assertEquals(
            inactiveXrefs[0].Xref_Status__c,
            XREF_STATUS_INACTIVE,
            ASSERTION_FAILED
        );
        System.assertEquals(agreements.size(), 0, ASSERTION_FAILED);
        System.assertEquals(
            updatedContracts[0].Is_Churned_Mx_Contract_Processed__c,
            true,
            ASSERTION_FAILED
        );
    }

    /**
     * @description It is used to test the batch is not invoked or executed for the Contract with type as
     * "Core". It also ensures associated child records are not deleted or updated.
     */
    @isTest
    private static void testWhenNonChurnedMxContractsExecutedByBatchThenChildRecordsAreNotDeletedOrUpdated() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();
        SBQQ.TriggerControl.disable();
        Account businessAccount = new Account(
            Name = NAME_ACCOUNT,
            RecordTypeId = businessRecordTypeId,
            BillingCountry = UNITED_STATES,
            Segment__c = ACCOUNT_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );

        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY2,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE2,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );
        insert businessAccount;
        insert childAccount;
        Opportunity testOpp = new Opportunity(
            AccountId = businessAccount.Id,
            Name = NAME_OPPORTUNITY,
            CloseDate = System.today() + 30,
            StageName = STAGENAME,
            Deal_Type__c = DEAL_TYPE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Estimated_Number_of_Stores__c = 1
        );
        insert testOpp;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, businessAccount, null, true);
        Order order = CPQTestDataFactory.createOrder(businessAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;
        Order churnedMxOrder = [SELECT Id, SBQQ__Quote__c, AccountId FROM Order];
        churnedMxOrder.Type = CONTRACTTYPE_CORE;
        update churnedMxOrder;
        Contract contractInstance = new Contract(
            AccountId = businessAccount.Id,
            SBQQ__Order__c = churnedMxOrder.Id,
            Is_Churned_Mx_Contract_Processed__c = false
        );
        insert contractInstance;
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        insert marketplaceProduct;
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = contractInstance.Id,
            SBQQ__Account__c = businessAccount.Id,
            SBQQ__Quantity__c = 200
        );
        insert subscription;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        insert marketplaceMerchantService;
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = childAccount.Id,
            Contract__c = contractInstance.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;
        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Salesforce_Account_Name__c = childAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = XREF_EXTERNAL_ID
            )
        };
        insert xrefs;
        WorkOrder parentStorefrontWorkOrderInstance = new WorkOrder(
            AccountId = businessAccount.Id,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Contract__c = contractInstance.Id,
            Opportunity__c = testOpp.Id
        );
        insert parentStorefrontWorkOrderInstance;
        SBQQ.TriggerControl.enable();
        Test.startTest();
        Database.executeBatch(new ProcessChurnedMerchantRecordsBatch());
        Test.stopTest();
        List<Xref__c> associatedXrefs = [
            SELECT Id, Salesforce_Account_Name__c, Xref_Status__c
            FROM Xref__c
            WHERE Salesforce_Account_Name__c = :childAccount.Id
        ];
        List<Agreement__c> agreements = [
            SELECT Id
            FROM Agreement__c
            WHERE Contract__c = :contractInstance.Id
        ];
        System.assertEquals(
            associatedXrefs[0].Xref_Status__c,
            XREF_STATUS_ACTIVE,
            ASSERTION_FAILED
        );
        System.assertEquals(agreements.size(), 1, ASSERTION_FAILED);
        System.assertEquals(
            contractInstance.Is_Churned_Mx_Contract_Processed__c,
            false,
            ASSERTION_FAILED
        );
    }

    /**
     * @description It is used to test whether the batch is scheduled or not for the given cron
     * expression.
     */
    @isTest
    private static void testWhenBatchIsScheduledThenAsyncJobCreated() {
        Test.startTest();
        String jobId = System.schedule(
            BATCH_NAME,
            CRON_EXPRESSION,
            new ProcessChurnedMerchantRecordsBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            ASSERTION_FAILED
        );
    }
}