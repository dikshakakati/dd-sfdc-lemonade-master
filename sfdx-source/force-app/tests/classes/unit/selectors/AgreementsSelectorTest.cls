/**
 * @author atg
 * @date 05/23/2022
 * @description Test class for AgreementSelector class
 */
@isTest(seeAllData=false)
private class AgreementsSelectorTest {
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS = 'agreementsCount';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Agreement';
    private static final String ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE = 'Unexpected result: The Agreement list should have size = 2';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_STATUS_PENDING = 'Pending';
    private static final String AGREEMENT_STATUS_CANCELLED = 'Cancelled';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String AGREEMENT_TYPE_STORE_AGREEMENT = 'Store Agreement';
    private static final String AGREEMENT_TYPE_BUSINESS_AGREEMENT = 'Business Agreement';
    private static final String CONTACT_EMAIL = 'test@AgreementsSelectorTest.com';
    private static final String CONTACT_NAME = 'Test Contact';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE = 'Unexpected result: The query does not return any Agreement';
    private static final String CORE_ORDER = 'Core';
    private static final String ADS_PROMOS = 'A&P';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_VERTICAL = 'Rx';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        AgreementsSelector agreementInstance = new AgreementsSelector();
        Schema.SObjectType typeOfObject = agreementInstance.getSObjectType();
        System.assertEquals(
            Schema.Agreement__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );

        List<Schema.SObjectField> sObjectFields = agreementInstance.getSObjectFieldList();
        AgreementsSelector.newInstance();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Agreement__c.Id,
                Agreement__c.Account__c,
                Agreement__c.Contract__c,
                Agreement__c.Activation_Order_Created__c,
                Agreement__c.Name,
                Agreement__c.Status__c,
                Agreement__c.Type__c,
                Agreement__c.Deactivation_Date__c,
                Agreement__c.Start_Date__c,
                Agreement__c.Agreed_To_Services__c,
                Agreement__c.Group__c,
                Agreement__c.Serialized_Entitlements_Data__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test selectById
     */
    @isTest
    private static void testWhenSelectByIdThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, false);
        testOpp.Deselected_Marketplace_Offerings__c = 'Pickup;DashPass';
        insert testOpp;

        //Insert 3, make sure only 2 are returned
        Agreement__c agree1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Opportunity__c = testOpp.Id
        );
        insert agree1;
        Agreement__c agree2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Opportunity__c = testOpp.Id
        );
        insert agree2;
        Agreement__c agree3 = new Agreement__c(
            Name = 'Agreement3',
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Opportunity__c = testOpp.Id
        );
        insert agree3;

        AgreementsSelector agreementInstance = new AgreementsSelector();
        List<Agreement__c> agreementList = agreementInstance.selectById(
            new Set<Id>{ agree1.Id, agree2.Id }
        );

        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
        List<Agreement__c> agreementListOppInfo = agreementInstance.selectOpportunityInfoByIds(
            new Set<Id>{ agree1.Id, agree2.Id }
        );

        System.assertEquals(
            agreementListOppInfo.size(),
            2,
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
        System.assertEquals(
            agreementListOppInfo[0].Opportunity__r.Deselected_Marketplace_Offerings__c,
            'Pickup;DashPass',
            'Incorrect data returned'
        );
    }

    @isTest
    private static void testWhenParentAccountsIdsAreProvidedThenActiveAgreementsAreFetched() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);

        //Insert 3, make sure only 2 are returned
        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(
                Name = 'Agreement1',
                Account__c = testAccount.Id,
                Contract__c = testContract.Id,
                Type__c = 'Franchise Agreement',
                Status__c = 'Active'
            ),
            new Agreement__c(
                Name = 'Agreement2',
                Account__c = testAccount.Id,
                Contract__c = testContract.Id,
                Type__c = 'Franchise Agreement',
                Status__c = 'Active'
            )
        };
        insert agreements;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        List<Agreement__c> agreementList = agreementInstance.selectAgreementsByParentAccounts(
            new Set<Id>{ testAccount.Id }
        );
        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }

    /**
     * @description To test selectStoreAgreementsByAccountIds
     */
    @isTest
    private static void testWhenSelectStoreAgreementsByAccountIdsThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        //Insert 3, make sure only 1 is returned
        Agreement__c agree1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT
        );
        insert agree1;
        //Bad status
        Agreement__c agree2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = null,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT
        );
        insert agree2;
        //Does not match. Franchise Agreemnt, not store agreement.
        Agreement__c agree3 = new Agreement__c(
            Name = 'Agreement3',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT
        );
        insert agree3;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        List<Agreement__c> agreementList = agreementInstance.selectStoreAgreementsByAccountIds(
            new Set<Id>{ testAccount.Id }
        );

        System.assertEquals(agreementList.size(), 1, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }

    /**
     * @description To test selectActiveAgreementsByContractIds
     */
    @isTest
    private static void testWhenActiveAgreementsByContractIdsThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);
        Contract testContract2 = CPQTestDataFactory.createContract(testAccount.Id, true);

        //Insert 3, make sure only 2 are returned
        Agreement__c agree1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_BUSINESS_AGREEMENT,
            Deactivation_Date__c = null
        );
        insert agree1;
        Agreement__c agree2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = System.today().addDays(1)
        );
        insert agree2;
        //Does not match Contract Id
        Agreement__c agree3 = new Agreement__c(
            Name = 'Agreement3',
            Account__c = testAccount.Id,
            Contract__c = testContract2.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT
        );
        insert agree3;
        //Deactivation_Date__c in the past
        Agreement__c agree4 = new Agreement__c(
            Name = 'Agreement4',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = System.today().addDays(-1)
        );
        insert agree4;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        List<Agreement__c> agreementList = agreementInstance.selectActiveAgreementsByContractIds(
            new Set<Id>{ testContract1.Id }
        );

        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }
    @isTest
    private static void testWhenMarketplaceIdProvidedThenAgreementsAreFetched() {
        String marketPlaceNintexId1 = 'NintextId1';
        String marketPlaceNintexId2 = 'NintextId2';
        Account testAccount1 = TestDataFactory.createAccount(false);
        testAccount1.Marketplace_Nintex_Id__c = marketPlaceNintexId1;
        insert testAccount1;
        Account testAccount2 = TestDataFactory.createAccount(false);
        testAccount2.Marketplace_Nintex_Id__c = marketPlaceNintexId2;
        insert testAccount2;
        Account testAccount3 = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount3.Id, true);
        //Insert 3, make sure only 2 are returned
        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(
                Name = 'Agreement1',
                Account__c = testAccount1.Id,
                Contract__c = testContract.Id,
                Type__c = 'Franchise Agreement',
                Status__c = 'Active'
            ),
            new Agreement__c(
                Name = 'Agreement2',
                Account__c = testAccount2.Id,
                Contract__c = testContract.Id,
                Type__c = 'Franchise Agreement',
                Status__c = 'Active'
            ),
            new Agreement__c(
                Name = 'Agreement3',
                Account__c = testAccount3.Id,
                Contract__c = testContract.Id,
                Type__c = 'Franchise Agreement',
                Status__c = 'Active'
            )
        };
        insert agreements;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        List<Agreement__c> agreementList = agreementInstance.selectAgreementsByMarketplaceNintexIds(
            new Set<String>{ marketPlaceNintexId1 }
        );
        System.assertEquals(agreementList.size(), 1, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }

    @isTest
    private static void testWhenContractAndAccountsProvidedThenAgreementsAreFetched() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        Agreement__c agreement = new Agreement__c(
            Name = 'Agreement',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Status__c = 'Active'
        );
        insert agreement;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        Test.startTest();
        List<Agreement__c> agreementList = agreementInstance.selectAgreementsByContractAndAccount(
            new Set<Id>{ testContract1.Id },
            new Set<Id>{ testAccount.Id }
        );
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Expected agreements are not returned');
    }

    /**
     * @description To fetch active franchise agreement with Franchise Accounts not
     * having Payment Method as 'Withholding' when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenActiveFranchiseAgreementsWithFranchiseAccountNotHavingWithholdingPaymentMethodReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectNonWithholdingFranchiseAccountsByActiveAgreements(
                new Set<Id>{ testAccount.Id },
                10
            );
        System.assertEquals(
            agreementQueryResult.size(),
            1,
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }

    /**
     * @description To test no active franchise agreement with Franchise Accounts not having
     * Payment Method as 'Withholding' are fetched when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenNoActiveFranchiseAgreementsWithFranchiseAccountNotHavingWithholdingPaymentMethodReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_BUSINESS_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectNonWithholdingFranchiseAccountsByActiveAgreements(
                new Set<Id>{ testAccount.Id },
                10
            );
        System.assertEquals(
            agreementQueryResult.size(),
            0,
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }

    /**
     * @description To fetch count of Franchise Accounts not having Payment Method as
     * 'Withholding' associated with 'Active' Agreement when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenActiveFranchiseAgreementsCountReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        for (
            Aggregate eachAggregate : AgreementsSelector.newInstance()
                .selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ testAccount.Id }
                )
        ) {
            System.assertEquals(
                1,
                (Integer) eachAggregate.get(AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS),
                QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description To fetch no count of Franchise Accounts not having Payment Method as
     * 'Withholding' associated with 'Active' Agreement returned when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenNoActiveFranchiseAgreementsCountReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_BUSINESS_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        List<Aggregate> aggregateQueryResult = AgreementsSelector.newInstance()
            .selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
                new Set<Id>{ testAccount.Id }
            );
        System.assertEquals(
            aggregateQueryResult.size(),
            0,
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }

    /**
     * @description To fetch active franchise agreement with Franchise Accounts
     * having Payment Method as 'Withholding' when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenActiveFranchiseAgreementsWithFranchiseAccountHavingWithholdingPaymentMethodReturned() {
        Account testAccount = TestDataFactory.createAccount(false);
        testAccount.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectWithholdingCorporateAccountsByActiveAgreements(
                new Set<Id>{ testAccount.Id },
                10
            );
        System.assertEquals(
            1,
            agreementQueryResult.size(),
            QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test no active franchise agreement with Franchise Accounts having
     * Payment Method as 'Withholding' are fetched when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenCorporateAccountsIdsPassedThenNoActiveFranchiseAgreementsWithFranchiseAccountHavingWithholdingPaymentMethodReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
        Agreement__c franchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_BUSINESS_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert franchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectWithholdingCorporateAccountsByActiveAgreements(
                new Set<Id>{ testAccount.Id },
                10
            );
        System.assertEquals(
            0,
            agreementQueryResult.size(),
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }

    /**
     * @description To validate query to fetch active franchise agreements associated with
     * franchise accounts when Contract Ids are passed.
     */
    @isTest
    private static void testWhenContractIdPassedThenActiveFranchiseAgreementsReturned() {
        Account mockAccount = TestDataFactory.createAccount(true);
        Contract mockContract = CPQTestDataFactory.createContract(mockAccount.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mockAccount.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_ACTIVE
        );
        insert mockFranchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectActiveFranchiseAgreementsByContractIds(new Set<Id>{ mockContract.Id }, 1);
        System.assertEquals(
            1,
            agreementQueryResult.size(),
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }

    /**
     * @description To validate query does not return inactive franchise agreements associated with
     * franchise accounts when Contract Ids are passed.
     */
    @isTest
    private static void testWhenContractIdPassedThenNonActiveFranchiseAgreementsNotReturned() {
        Account mockAccount = TestDataFactory.createAccount(true);
        Contract mockContract = CPQTestDataFactory.createContract(mockAccount.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mockAccount.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectActiveFranchiseAgreementsByContractIds(new Set<Id>{ mockContract.Id }, 1);
        System.assertEquals(
            0,
            agreementQueryResult.size(),
            QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
        );
    }

    @isTest
    private static void testWhenSelectStoreAgreementsByRcrIdsIsCalledThenAgreementsAreFetched() {
        Id soCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('SO_Support_Request')
            .getRecordTypeId();

        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        Case soSupportCase = new Case();
        soSupportCase.AccountId = testAccount.Id;
        soSupportCase.RecordTypeId = soCaseRecordTypeId;
        insert soSupportCase;

        Rate_Change_Request__c rateChange1 = new Rate_Change_Request__c();
        rateChange1.Effective_Date__c = System.today();
        rateChange1.Contract__c = testContract1.Id;
        rateChange1.S_O_Support_Request_Link__c = soSupportCase.Id;
        rateChange1.Activation_Status__c = 'New';
        rateChange1.Status__c = 'Approved';
        rateChange1.Order_Products_Updated__c = false;
        rateChange1.Associated_stores_updated__c = true;
        insert rateChange1;

        testAccount.Rate_Change_Request__c = rateChange1.Id;
        update testAccount;

        Agreement__c agreement = new Agreement__c(
            Name = 'Agreement',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Status__c = 'Active'
        );
        insert agreement;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        Test.startTest();
        List<Agreement__c> agreementList = agreementInstance.selectStoreAgreementsByRcrIds(
            new Set<Id>{ rateChange1.Id }
        );
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Expected agreements are not returned');
    }

    /**
     * @description To test selectActiveAgreementsByAccountIds
     */
    @isTest
    private static void testWhenSelectActiveAgreementsByAccountIdsThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        //Insert 3, make sure only 1 is returned
        Agreement__c agree1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = null
        );
        insert agree1;
        Agreement__c agree2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = null,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = null
        );
        insert agree2;
        //Does not match. Franchise Agreemnt, not store agreement.
        Agreement__c agree3 = new Agreement__c(
            Name = 'Agreement3',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT
        );
        insert agree3;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        List<Agreement__c> agreementList = agreementInstance.selectActiveAgreementsByAccountIds(
            new Set<Id>{ testAccount.Id }
        );

        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }

    /**
     * @description To test selectStoreAgreementsByIds
     */
    @isTest
    private static void testWhenSelectStoreAgreementsByIdsThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        Agreement__c agreement1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = null
        );
        insert agreement1;
        Agreement__c agreement2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Deactivation_Date__c = null
        );
        insert agreement2;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        Set<Id> agreemenIds = new Set<Id>{ agreement1.id, agreement2.id };
        List<Agreement__c> agreementList = agreementInstance.selectStoreAgreementsByIds(
            agreemenIds
        );

        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }

    /**
     * @description To test selectActiveAndCancelledAgreementsByAccountIds
     */
    @isTest
    private static void testWhenSelectActiveAndCancelledAgreementsByAccountIdsThenReturnRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        Agreement__c agreement1 = new Agreement__c(
            Name = 'Agreement1',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_ACTIVE,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT
        );
        insert agreement1;
        Agreement__c agreement2 = new Agreement__c(
            Name = 'Agreement2',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Status__c = AGREEMENT_STATUS_CANCELLED,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT
        );
        insert agreement2;
        AgreementsSelector agreementInstance = new AgreementsSelector();

        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
        List<Agreement__c> agreementList = agreementInstance.selectActiveAndCancelledAgreementsByAccountIds(
            accountIds
        );

        System.assertEquals(agreementList.size(), 2, ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE);
    }
   /**

     * @description To fetch count of count of stores for the contract
     * LEM-15403
     */
     @isTest
     private static void testWhenAccountIdPassedThenStoreCountReturned() {
         Account testAccount = TestDataFactory.createAccount(false);
         testAccount.BillingCountry = ACCOUNT_BILLING_COUNTRY;
         testAccount.BillingStreet = ACCOUNT_BILLING_STREET;
         testAccount.BillingCity = ACCOUNT_BILLING_CITY;
         testAccount.BillingState = ACCOUNT_BILLING_STATE;
         testAccount.BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE;
         testAccount.Legal_Business_Name__c = STORE_ACCOUNT_NAME;
         testAccount.Primary_Vertical__c = ACCOUNT_VERTICAL;
         insert testAccount;
         Contract testContract = CPQTestDataFactory.createContract(testAccount.Id, true);
         Agreement__c franchiseAgreement = new Agreement__c(
             Name = AGREEMENT_NAME,
             Account__c = testAccount.Id,
             Contract__c = testContract.Id,
             Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
             Status__c = AGREEMENT_STATUS_ACTIVE
         );
         insert franchiseAgreement;
         for (
             Aggregate eachAggregate : AgreementsSelector.newInstance()
                 .selectCountOfStoresAccountsByStoreAgreements(testAccount.Id)
         ) {
             System.assertEquals(
                 1,
                 (Integer) eachAggregate.get(AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS),
              QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
          );
         }
     }

    /**
     * @description To validate query does not return store count when type is not store agreement
     * LEM-15403
     */
    @isTest
    private static void testWhenAccountIdPassedThenStoreCountNotReturned() {
        Account mockAccount = TestDataFactory.createAccount(false);
        mockAccount.BillingCountry = ACCOUNT_BILLING_COUNTRY;
        mockAccount.BillingStreet = ACCOUNT_BILLING_STREET;
        mockAccount.BillingCity = ACCOUNT_BILLING_CITY;
        mockAccount.BillingState = ACCOUNT_BILLING_STATE;
        mockAccount.BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE;
        mockAccount.Legal_Business_Name__c = STORE_ACCOUNT_NAME;
        mockAccount.Primary_Vertical__c = ACCOUNT_VERTICAL;
        insert mockAccount;
        Contract mockContract = CPQTestDataFactory.createContract(mockAccount.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mockAccount.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT
        );
        insert mockFranchiseAgreement;

        for (
            Aggregate eachAggregate : AgreementsSelector.newInstance()
                .selectCountOfStoresAccountsByStoreAgreements(mockAccount.Id)
        ) {
            System.assertEquals(
                0,
                (Integer) eachAggregate.get(AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS),
                QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description To validate query should return only active agreements on a contract
     */
    @isTest
    private static void testWhenContractAndAccountIdsProvidedThenActiveAgreementsAreFetched() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);

        Agreement__c agreement = new Agreement__c(
            Name = 'Agreement',
            Account__c = testAccount.Id,
            Contract__c = testContract1.Id,
            Type__c = AGREEMENT_TYPE_STORE_AGREEMENT,
            Status__c = 'Active'
        );
        insert agreement;

        AgreementsSelector agreementInstance = new AgreementsSelector();

        Test.startTest();
        List<Agreement__c> agreementList = agreementInstance.selectActiveAgreementsByAccountContractIds(
            new Set<Id>{ testAccount.Id },
            testContract1.Id
        );
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Expected agreements are not returned');
    }
    /**
     * @description To validate query return agreements based upon passed contract ids for Core Contracts.
     */
    @isTest
    private static void testWhenContractIdsPassedThenAgreementsReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        Test.startTest();
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        sbqqOrder.Type = CORE_ORDER;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;

        Agreement__c mockAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT
        );
        insert mockAgreement;
        List<Agreement__c> agreements = AgreementsSelector.newInstance()
            .selectActiveAgreementsByCoreContractIds(new Set<Id>{ testContract.Id });
        Test.stopTest();
        System.assertEquals(1, agreements.size(), QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE);
    }
    /**
     * @description To validate query return no agreements based upon passed contract ids for Ads Contracts.
     */
    @isTest
    private static void testWhenAdsAndPromosContractIdsPassedThenAgreementsReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        Test.startTest();
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        sbqqOrder.Type = ADS_PROMOS;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;

        Agreement__c mockAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = testAccount.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT
        );
        insert mockAgreement;
        List<Agreement__c> agreements = AgreementsSelector.newInstance()
            .selectActiveAgreementsByCoreContractIds(new Set<Id>{ testContract.Id });
        Test.stopTest();
        System.assertEquals(0, agreements.size(), QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE);
    }
    /**
     * @description To test if the account Ids passed then return expected Agreements.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnAgreements() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessRecordTypeId,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldCorporate;
        Account mcDonaldStore = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = mcDonaldCorporate.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldStore;

        Contract mockContract = CPQTestDataFactory.createContract(mcDonaldCorporate.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mcDonaldStore.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;

        Test.startTest();
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectAgreementsByAccountsIds(new Set<Id>{ mcDonaldStore.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            agreementQueryResult.size(),
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
        System.assertEquals(
            mockContract.Id,
            agreementQueryResult[0].Contract__c,
            QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test if the account Ids passed then dont return Agreements.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDontReturnAgreements() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessRecordTypeId,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldCorporate;
        Account mcDonaldStore = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = mcDonaldCorporate.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        Account mcDonaldStore1 = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = mcDonaldCorporate.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        List<Account> storeAccounts = new List<Account>{ mcDonaldStore, mcDonaldStore1 };
        insert storeAccounts;

        Contract mockContract = CPQTestDataFactory.createContract(mcDonaldCorporate.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mcDonaldStore1.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;

        Test.startTest();
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectAgreementsByAccountsIds(new Set<Id>{ mcDonaldStore.Id });
        Test.stopTest();
        System.assertEquals(
            0,
            agreementQueryResult.size(),
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
    }
    /**
     * @description To test if the Contract Ids passed then return expected Churned Mx Agreements.
     */
    @isTest
    private static void testWhenContractIdsPassedThenReturnChurnedMxAgreements() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessRecordTypeId,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldCorporate;
        Account mcDonaldStore = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = mcDonaldCorporate.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldStore;

        Contract mockContract = CPQTestDataFactory.createContract(mcDonaldCorporate.Id, true);
        Agreement__c mockFranchiseAgreement = new Agreement__c(
            Name = AGREEMENT_NAME,
            Account__c = mcDonaldStore.Id,
            Contract__c = mockContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = AGREEMENT_STATUS_PENDING
        );
        insert mockFranchiseAgreement;

        Test.startTest();
        List<Agreement__c> agreementQueryResult = AgreementsSelector.newInstance()
            .selectChurnedMxAgreementsByContractIds(new Set<Id>{ mockContract.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            agreementQueryResult.size(),
            ASSERT_MESSAGE_RETURN_LIST_INCORRECT_SIZE
        );
        System.assertEquals(
            mcDonaldStore.Id,
            agreementQueryResult[0].Account__c,
            QUERY_RETURN_NO_AGREEMENT_ASSERT_MESSAGE
        );
    }
}