/**
 * @author Deloitte
 * @date 23/03/2022
 * @description This is test class for QuoteSelector class.
 */
@isTest
private class QuotesSelectorTest {
    private static final String ASSERTION_FAILED = 'Unexpected Result: Batch did not execute successfully';
    private static final String ACCOUNT_NAME_DOMINOES = 'Dominoes';
    private static final String ACCOUNT_NAME_KFC = 'KFC';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ASSERT_MESSAGE_QUOTE_QUOTE_BRIEF_RELATIONSHIP = 'Unexpected result: SMB Quote with Quote Brief Relationship retrieved';
    private static final String BUSINESS_ACCOUNT = 'Business';
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
    private static final String PRIMARY_VERTICAL = 'Rx';
    private static final String OPPORTUNITY_DEALTYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_NAME_DOMINOES = 'Dominoes Opportunity';
    private static final String OPPORTUNITY_NAME_KFC = 'KFC Opportunity';
    private static final String OPPORTUNITY_STAGENAME_NEEDS_ANALYSIS = 'Needs Analysis';
    private static final String OPPORTUNITY_SUBTYPE_FORMER_PARTNER = 'Former Partner';
    private static final String OPPORTUNITY_SUBTYPE_NET_NEW_PARTNER = 'Net New Partner';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_PROMOS = 'Ads & Promos';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String INITIAL_TERM_TERMINATION = '2';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String DRAFT = 'Draft';
    private static final String OPPORTUNITY_ROLE_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String QUOTE_UNIQUE_IDENTIFIER = 'Mx Portal A&P 123';
    private static final String QUOTE_SOURCE = 'Mx Portal';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STAGENAME_NEGOTIATING = 'Negotiating';
    private static final String USERNAME_PROCESS_AUTOMATION = 'Process Automation User';

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
        QuotesSelector quotesInstance = new QuotesSelector();
        List<SBQQ__Quote__c> quotes = quotesInstance.selectById(
            new Set<Id>{ quote1.Id, quote2.Id }
        );
        Schema.SObjectType typeOfObj = quotesInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = quotesInstance.getSObjectFieldList();
        QuotesSelector.newInstance();
        System.assertEquals(
            Schema.SBQQ__Quote__c.SObjectType,
            typeOfObj,
            'The object type must be Account.'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                SBQQ__Quote__c.Id,
                SBQQ__Quote__c.SBQQ__Opportunity2__c,
                SBQQ__Quote__c.Name,
                SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c,
                SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c,
                SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c,
                SBQQ__Quote__c.Opt_Out_Save_Period_days__c,
                SBQQ__Quote__c.Migrated_Record__c,
                SBQQ__Quote__c.Quote_Migration_External_ID__c,
                SBQQ__Quote__c.SBQQ__Status__c,
                SBQQ__Quote__c.Contract_Signatory_Exists__c,
                SBQQ__Quote__c.SBQQ__StartDate__c,
                SBQQ__Quote__c.CurrencyIsoCode,
                SBQQ__Quote__c.SBQQ__Notes__c,
                SBQQ__Quote__c.SBQQ__Account__c,
                SBQQ__Quote__c.Signed_Contract_link__c,
                SBQQ__Quote__c.SBQQ__SalesRep__c,
                SBQQ__Quote__c.Franchise_Supplemental_Agreement_Link__c,
                SBQQ__Quote__c.Signed_Contract_link__c,
                SBQQ__Quote__c.Use_Corporate_Cherry_Picking__c,
                SBQQ__Quote__c.SBQQ__Type__c,
                SBQQ__Quote__c.Jira_Request_Ticket_link__c,
                SBQQ__Quote__c.Jira_Request_Ticket_status__c,
                SBQQ__Quote__c.Contract_Generation_Path__c,
                SBQQ__Quote__c.Approval_Requested_Reason__c,
                SBQQ__Quote__c.Number_of_Stores__c,
                SBQQ__Quote__c.Check_Start_Date_For_A_P_Product__c,
                SBQQ__Quote__c.Check_Delay_After_Activation_For_A_P__c,
                SBQQ__Quote__c.Unique_Identifier__c,
                SBQQ__Quote__c.Contracting_Flow__c,
                SBQQ__Quote__c.Nintex_Use_Case__c,
                SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assert(quotes.size() != null, 'The list does not contain any Quotes');
    }

    @isTest
    private static void testWhenIdIsSentThenReturnRecords() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunityList[0].Id),
            new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunityList[0].Id)
        };

        insert quotesList;
        quotesList[0].SBQQ__Status__c = 'In Review';
        quotesList[0].SBQQ__Primary__c = true;
        update quotesList;
        List<SBQQ__Quote__c> quotes = new QuotesSelector()
            .selectById(new Set<Id>{ quotesList[0].Id, quotesList[1].Id });
        List<SBQQ__Quote__c> quotesWithLineItems = new QuotesSelector()
            .selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                new Set<Id>{ quotesList[0].Id, quotesList[1].Id }
            );
        System.assertEquals(
            opportunityList[0].Id,
            quotes[0].SBQQ__Opportunity2__c,
            'The parent Opportunity is mismatching'
        );
        System.assertEquals(
            1,
            quotesWithLineItems.size(),
            'The retrieved List should contain two records'
        );
        System.assertEquals(2, quotes.size(), 'The retrieved List should contain two records');
    }

    /**
     * @description To validate that SMB quote Ids does not return a result through selectQuotesWithQuoteLineAndQuoteBriefRelationships method.
     */
    @isTest
    private static void testWhenSMBQuoteIdPassedThenDoNoReturnQuoteWithQuoteBriefRelationships() {
        List<Account> accounts = new List<Account>{
            new Account(Name = ACCOUNT_NAME_DOMINOES, Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(Name = ACCOUNT_NAME_KFC, Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accounts;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME_DOMINOES,
                StageName = OPPORTUNITY_STAGENAME_NEEDS_ANALYSIS,
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accounts[0].Id,
                Deal_Type__c = OPPORTUNITY_DEALTYPE_STANDARD,
                Opportunity_Sub_Type__c = OPPORTUNITY_SUBTYPE_FORMER_PARTNER,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = OPPORTUNITY_NAME_KFC,
                StageName = OPPORTUNITY_STAGENAME_NEEDS_ANALYSIS,
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accounts[1].Id,
                Deal_Type__c = OPPORTUNITY_DEALTYPE_STANDARD,
                Opportunity_Sub_Type__c = OPPORTUNITY_SUBTYPE_NET_NEW_PARTNER,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;
        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_APPROVED)
            .toSObject();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(newQuote);
        insert quotes;
        Test.startTest();
        List<SBQQ__Quote__c> quotesWithLineItems = new QuotesSelector()
            .selectQuotesWithQuoteLineAndQuoteBriefRelationships(new Set<Id>{ quotes[0].Id });
        Test.stopTest();
        System.assertEquals(
            true,
            quotesWithLineItems.isEmpty(),
            ASSERT_MESSAGE_QUOTE_QUOTE_BRIEF_RELATIONSHIP
        );
    }

    @isTest
    private static void testWhenOpportunityIsSentThenReturnCorresponsingQuoteRecords() {
        //Arrange
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunityList[0].Id),
            new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunityList[1].Id)
        };

        insert quotesList;

        List<SBQQ__Quote__c> quoteList = new QuotesSelector()
            .selectByOpportunity(new Map<Id, Opportunity>(opportunityList).keySet());

        System.assertEquals(2, quoteList.size(), 'Quote List must have two quotes');
        System.assertEquals(
            opportunityList[0].Id,
            quoteList[0].SBQQ__Opportunity2__c,
            'The parent Opportunity is mismatching'
        );
    }
    /**
     * @description To test query on Quotes to fetch contract signed quotes associated with accounts.
     */
    @isTest
    private static void testWhenAccountIdsArePassedThenRetrievingContractSignedQuotes() {
        Account testAccount1 = TestDataFactory.createAccount(true);
        Product2 product1 = CPQTestDataFactory.createProduct(true);
        CPQTestDataFactory.createPriceBookEntry(product1, 'USD', true);
        Opportunity testOpportunity1 = CPQTestDataFactory.createOpportunity(testAccount1.Id, true);
        SBQQ__Quote__c quote1 = CPQTestDataFactory.createQuote(
            testOpportunity1,
            testAccount1,
            null,
            true
        );
        CPQTestDataFactory.createQuoteLine(product1, quote1, true);
        quote1.SBQQ__Status__c = 'Approved';
        quote1.Signed_Contract_Link__c = 'Link';
        quote1.Contract_Signed_Date__c = System.today() - 5;
        test.startTest();
        update quote1;
        Account testAccount2 = TestDataFactory.createAccount(true);
        Opportunity testOpportunity2 = CPQTestDataFactory.createOpportunity(testAccount2.Id, true);
        SBQQ__Quote__c quote2 = CPQTestDataFactory.createQuote(
            testOpportunity2,
            testAccount2,
            null,
            true
        );
        quote2.SBQQ__Status__c = 'Draft';
        quote2.Signed_Contract_Link__c = 'Link';
        quote2.Contract_Signed_Date__c = System.today() - 5;
        update quote2;
        QuotesSelector quotesInstance = new QuotesSelector();

        List<SBQQ__Quote__c> quotes = quotesInstance.selectByAccounts(
            new Set<Id>{ testAccount1.Id, testAccount2.Id }
        );
        System.assertEquals(0, quotes.size(), 'The retrieved List should contain only one record');
    }
    /**
     * @description To test query on Amended Quotes to fetch fields from original quotes
     */
    @isTest
    private static void testWhenQuoteIdsArePassedThenRetrieveFieldsFromOriginalQuote() {
        SBQQ.TriggerControl.disable();
        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, true);

        CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);
        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);
        contract.SBQQ__Quote__c = quote.Id;
        contract.SBQQ__Order__c = order.Id;
        update contract;

        Opportunity testOppAmend = CPQTestDataFactory.createOpportunity(testAccount.Id, false);
        testOppAmend.Type = 'Existing';
        testOppAmend.Source__c = SOURCE_NINTEX;
        testOppAmend.Opportunity_Sub_Type__c = 'Upgrade';
        insert testOppAmend;
        SBQQ__Quote__c amendmentQuote = CPQTestDataFactory.createQuote(
            testOppAmend,
            testAccount,
            null,
            true
        );
        amendmentQuote.SBQQ__Type__c = 'Amendment';
        amendmentQuote.SBQQ__MasterEvergreenContract__c = contract.Id;
        update amendmentQuote;

        SBQQ.TriggerControl.enable();

        QuotesSelector quotesInstance = new QuotesSelector();
        List<SBQQ__Quote__c> quotes = quotesInstance.selectQuoteFieldsFromOriginalQuote(
            new Set<Id>{ amendmentQuote.Id }
        );
        System.assertEquals(1, quotes.size(), 'The retrieved List should contain only one record');
    }

    /**
     * @description This method tests the behavior of the selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields method.
     * It verifies that the method returns the quotes with their associated quote lines and opportunity contact roles
     * based on the given fields.
     *
     * The method performs the following steps:
     * 1. Disables the SBQQ trigger control.
     * 2. Creates a product and price book entry.
     * 3. Creates an account and opportunity.
     * 4. Creates a quote associated with the opportunity and account.
     * 5. Creates a contact associated with the account.
     * 6. Inserts the contact and opportunity contact role.
     * 7. Creates a quote line associated with the product and quote.
     * 8. Enables the SBQQ trigger control.
     * 9. Calls the selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields method with the given parameters.
     * 10. Verifies the expected results using assertions.
     */
    @isTest
    private static void testWhenSelectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFieldsThenReturnQuotesAccordingly() {
        SBQQ.TriggerControl.disable();

        Product2 product = CPQTestDataFactory.createProduct(true);
        CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        Contact contact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@testemail.com'
        );
        insert contact;

        OpportunityContactRole ocr = new OpportunityContactRole(
            Quote__c = quote.Id,
            Role = 'Contract Signatory',
            contactId = contact.Id,
            OpportunityId = testOpp.Id
        );
        insert ocr;

        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);

        SBQQ.TriggerControl.enable();

        List<SBQQ__Quote__c> quotes = QuotesSelector.newInstance()
            .selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields(
                new Set<Id>{ quote.Id },
                new Map<String, Set<String>>{
                    'SBQQ__Quote__c' => new Set<String>{ 'Id' },
                    'SBQQ__QuoteLine__c' => new Set<String>{ 'Id' },
                    'Contact' => new Set<String>{ 'ContactId' }
                }
            );

        Assert.areEqual(1, quotes.size(), 'Quotes size should be 1');
        Assert.areEqual(quote.Id, quotes[0].Id, 'Quote Id is not matched');
        Assert.areEqual(1, quotes[0].SBQQ__LineItems__r.size(), 'QLI size should be 1');
        Assert.areEqual(
            quoteLine.Id,
            quotes[0].SBQQ__LineItems__r[0].Id,
            'QLI Id should match with the one created'
        );
        Assert.areEqual(1, quotes[0].Opportunity_Contact_Role__r.size(), 'OCR size should match');
        Assert.areEqual(
            contact.Id,
            quotes[0].Opportunity_Contact_Role__r[0].ContactId,
            'Contact Relationship from OCR is not matching'
        );
    }

    /**
     * @description - when business Id is provied return Account Name total no of stores And Quote SSMO expiration Date.
     * @author Soumya Dash | 06-28-2024
     **/
    @isTest
    private static void testWhenBusinessIdThenReturnAccountDetailsAndExpirationDate() {
        Map<String, Set<String>> sObjectToFields = new Map<String, Set<String>>{
            'SBQQ__Quote__c' => new Set<String>{ 'SSMO_Expiration_Date__c' },
            'Contact' => new Set<String>{
                'Contact.FirstName',
                'Contact.LastName',
                'Contact.Email',
                'Contact.Unique_Identifier__c'
            }
        };

        Account businessAccount = new Account(Name = 'Test Business', Segment__c = 'SMB');
        insert businessAccount;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = businessAccount.Id,
            SSMO_Expiration_Date__c = Date.valueOf('2024-12-01')
        );
        insert quote;

        Opportunity opp = new Opportunity(
            Name = 'Test Oppy',
            Type = 'New',
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Net New Partner',
            CloseDate = Date.today().addMonths(2)
        );
        insert opp;

        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com',
            Unique_Identifier__c = '1234'
        );
        insert contact;

        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = contact.Id,
            Quote__c = quote.Id,
            OpportunityId = opp.Id,
            Role = OPPORTUNITY_ROLE_CONTRACT_SIGNATORY
        );
        insert ocr;

        Test.startTest();
        IQuotesSelector quoteSelector = QuotesSelector.newInstance();
        SBQQ__Quote__c quoteResult = quoteSelector.selectByIdWithBusinessAccount(
            quote.Id,
            sObjectToFields
        );
        Test.stopTest();

        Assert.areEqual(
            businessAccount.Id,
            quoteResult.SBQQ__Account__c,
            'Businesss Id Did not match'
        );
        Assert.areEqual(
            quoteResult.Opportunity_Contact_Role__r[0].Contact.FirstName,
            contact.FirstName,
            'First Name did not match'
        );
    }

    /**
     * @description To test when account ids passed then primary quotes with status contract signed
     * and Initial Term and Termination not null are returned.
     */
    @isTest
    private static void testWhenAccountIdsArePassedThenPrimaryContractSignedQuoteReturned() {
        SBQQ.TriggerControl.disable();
        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Account testAccount = TestDataFactory.createAccount(false);
        insert testAccount;
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, true);
        CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);
        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);
        contract.SBQQ__Quote__c = quote.Id;
        contract.SBQQ__Order__c = order.Id;
        update contract;
        quote.SBQQ__Primary__c = true;
        quote.Initial_Term_and_Termination_Years__c = INITIAL_TERM_TERMINATION;
        quote.SBQQ__Status__c = CONTRACT_SIGNED;
        quote.SBQQ__StartDate__c = Date.today();
        quote.Signed_Contract_link__c = 'test';
        quote.Contract_Signed_Date__c = Date.today();
        update quote;
        SBQQ.TriggerControl.enable();
        QuotesSelector quotesInstance = new QuotesSelector();
        List<SBQQ__Quote__c> quotes = quotesInstance.selectPrimaryQuotesBySalesforceAccountIds(
            new Set<Id>{ testAccount.Id }
        );
        System.assertEquals(quote.Id, quotes[0].id, 'Incorrect quote is retrieved');
    }

    /**
     * @description To test when account ids passed then primary quotes with status contract signed
     * and Initial Term and Termination not null are returned.
     */
    @isTest
    private static void testWhenAccountIdsArePassedThenPrimaryNonContractSignedQuoteNotReturned() {
        SBQQ.TriggerControl.disable();
        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, true);
        CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);
        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);
        contract.SBQQ__Quote__c = quote.Id;
        contract.SBQQ__Order__c = order.Id;
        update contract;
        quote.SBQQ__Primary__c = true;
        quote.Initial_Term_and_Termination_Years__c = INITIAL_TERM_TERMINATION;
        quote.SBQQ__Status__c = DRAFT;
        quote.SBQQ__StartDate__c = Date.today();
        update quote;
        SBQQ.TriggerControl.enable();
        QuotesSelector quotesInstance = new QuotesSelector();
        List<SBQQ__Quote__c> quotes = quotesInstance.selectPrimaryQuotesBySalesforceAccountIds(
            new Set<Id>{ testAccount.Id }
        );
        System.assertEquals(0, quotes.size(), 'Incorrect quote is retrieved');
    }

    /**
     * @description test When Select Quote By Id Then Return Given Fields
     * @author SamikshaDD | 07-12-2024
     **/
    @isTest
    private static void testWhenSelectQuoteByIdThenReturnGivenFields() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            RESSMO_Store_Account_Id__c = Fake.generateId(Account.sObjectType),
            SSMO_Expiration_Date__c = Date.today().addDays(-1)
        );
        insert quote;
        Set<String> quoteFieldSet = new Set<String>{
            'RESSMO_Store_Account_Id__c',
            'SSMO_Expiration_Date__c'
        };

        Test.startTest();
        IQuotesSelector quoteSelector = QuotesSelector.newInstance();
        List<SBQQ__Quote__c> quoteResult = quoteSelector.selectQuoteByIdWithGivenFields(
            new Set<Id>{ quote.Id },
            quoteFieldSet
        );
        Test.stopTest();

        Assert.areEqual(quote.Id, quoteResult[0].Id, 'Quote Id Did not match');
    }

    /**
     * @description - On basis of quote return account opportunity contact
     * @author Pankaj Naik | 06-28-2024
     **/
    @isTest
    private static void testWhenQuoteIdThenReturnAccountOpportunityContacts() {
        Account businessAccount = new Account(
            Name = 'Test Business',
            Segment__c = 'SMB',
            Total_Number_Of_Stores__c = 1
        );
        insert businessAccount;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = businessAccount.Id,
            SSMO_Expiration_Date__c = Date.valueOf('2024-12-01')
        );
        insert quote;

        Opportunity opp = new Opportunity(
            Name = 'Test Oppy',
            Type = 'New',
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Net New Partner',
            CloseDate = Date.today().addMonths(2)
        );
        insert opp;

        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com',
            Unique_Identifier__c = '1234'
        );
        insert contact;

        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = contact.Id,
            Quote__c = quote.Id,
            OpportunityId = opp.Id,
            Role = OPPORTUNITY_ROLE_CONTRACT_SIGNATORY
        );
        insert ocr;

        Test.startTest();
        IQuotesSelector quoteSelector = QuotesSelector.newInstance();
        SBQQ__Quote__c quoteResult = quoteSelector.selectByIdWithAccountOpportunityContacts(
            quote.Id
        );
        Test.stopTest();

        Assert.areEqual(
            businessAccount.Id,
            quoteResult.SBQQ__Account__c,
            'Businesss Id Did not match'
        );
        Assert.areEqual(
            quoteResult.Opportunity_Contact_Role__r[0].Contact.FirstName,
            contact.FirstName,
            'First Name did not match'
        );
    }

    /**
     * @description It is used to test whether the self-serve halted quotes are fetched or not.
     **/
    @isTest
    private static void testWhenSelectorInvokedThenSelfServeHaltedQuotesReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        User processAutomationUser = [
            SELECT Id
            FROM User
            WHERE Name = :USERNAME_PROCESS_AUTOMATION
            LIMIT 1
        ];
        System.runAs(processAutomationUser) {
            Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
                Status__c = STATUS_SUCCESS
            );
            insert inboundIngestionLog;
            Account businessAccount = new Account(
                Name = NAME_ACCOUNT,
                RecordTypeId = businessRecordTypeId,
                BillingCountry = UNITED_STATES,
                Segment__c = ACCOUNT_SEGMENT,
                Legal_Business_Name__c = BUSINESS_ACCOUNT,
                Primary_Vertical__c = PRIMARY_VERTICAL
            );
            insert businessAccount;
            Opportunity negotiatingOpportunity = new Opportunity(
                AccountId = businessAccount.Id,
                Name = NAME_OPPORTUNITY,
                CloseDate = System.today() + 30,
                StageName = STAGENAME_NEGOTIATING,
                Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_ADS_PROMOS,
                Estimated_Number_of_Stores__c = 1,
                Source__c = QUOTE_SOURCE,
                Ingestion_log_Id__c = inboundIngestionLog.Id
            );
            insert negotiatingOpportunity;
            SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
                negotiatingOpportunity,
                businessAccount,
                null,
                false
            );
            quote.ApprovalStatus__c = QUOTE_STATUS_APPROVED;
            quote.SBQQ__Status__c = QUOTE_STATUS_APPROVED;
            quote.SBQQ__Primary__c = false;
            quote.Unique_Identifier__c = QUOTE_UNIQUE_IDENTIFIER;
            insert quote;
            Test.setCreatedDate(quote.Id, Date.today().addDays(-2));
            Test.startTest();
            Database.QueryLocator quotesQuery = QuotesSelector.newInstance()
                .selectSelfServeHaltedQuotes();
            Test.stopTest();
            List<SBQQ__Quote__c> quoteRecordsFetched = Database.query(quotesQuery.getQuery());
            System.assertEquals(1, quoteRecordsFetched.size(), ASSERTION_FAILED);
        }
    }

    /**
     * @description It is used to test that non self-serve halted quotes are not fetched.
     **/
    @isTest
    private static void testWhenSelectorInvokedThenNonSelfServeHaltedQuotesNotReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        User processAutomationUser = [
            SELECT Id
            FROM User
            WHERE Name = :USERNAME_PROCESS_AUTOMATION
            LIMIT 1
        ];
        System.runAs(processAutomationUser) {
            Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
                Status__c = STATUS_SUCCESS
            );
            insert inboundIngestionLog;
            Account businessAccount = new Account(
                Name = NAME_ACCOUNT,
                RecordTypeId = businessRecordTypeId,
                BillingCountry = UNITED_STATES,
                Segment__c = ACCOUNT_SEGMENT,
                Legal_Business_Name__c = BUSINESS_ACCOUNT,
                Primary_Vertical__c = PRIMARY_VERTICAL
            );
            insert businessAccount;
            Opportunity negotiatingOpportunity = new Opportunity(
                AccountId = businessAccount.Id,
                Name = NAME_OPPORTUNITY,
                CloseDate = System.today() + 30,
                StageName = STAGENAME_NEGOTIATING,
                Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_ADS_PROMOS,
                Estimated_Number_of_Stores__c = 1,
                Source__c = QUOTE_SOURCE,
                Ingestion_log_Id__c = inboundIngestionLog.Id
            );
            insert negotiatingOpportunity;
            SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
                negotiatingOpportunity,
                businessAccount,
                null,
                false
            );
            quote.ApprovalStatus__c = QUOTE_STATUS_APPROVED;
            quote.SBQQ__Status__c = QUOTE_STATUS_APPROVED;
            quote.SBQQ__Primary__c = true;
            quote.Unique_Identifier__c = null;
            insert quote;
            Test.setCreatedDate(quote.Id, Date.today().addDays(-2));
            Test.startTest();
            Database.QueryLocator quotesQuery = QuotesSelector.newInstance()
                .selectSelfServeHaltedQuotes();
            Test.stopTest();
            List<SBQQ__Quote__c> quoteRecordsFetched = Database.query(quotesQuery.getQuery());
            System.assertEquals(0, quoteRecordsFetched.size(), ASSERTION_FAILED);
        }
    }
}