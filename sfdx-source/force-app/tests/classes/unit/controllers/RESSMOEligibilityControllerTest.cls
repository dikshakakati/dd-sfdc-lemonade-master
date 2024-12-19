/**
 * @description       : Test Class for RESSMOEligibilityController
 * @author            : VenkateshDD
 * @group             : DDMx RESSMO - Aethereus
 * @last modified on  : 10-29-2024
 * @last modified by  : Pankaj
**/
@isTest
public with sharing class RESSMOEligibilityControllerTest {

    private static final String RESSMO_UI_PAYLOAD_CONTRACT = '{"genericInput": {"Contact": {},"Quote": {},"Photoshoot": {},"Account": {}}}';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_SECTION = 'Account';
    private static final String CONTACT_SECTION = 'Contact';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ONE_TIME_MX_LINK = 'www.test.com';
    private static final String SUBMARKET_NAME = 'Oakville, ON';
    private static final String BRAND = 'KFC';

    /**
     * @description This is a test method that verifies the behavior of the quoteEligibilityForRESSMO method
     * in the RESSMOEligibilityController class when the quoteId parameter is null.
     * It asserts that the method returns null.
     */
    @isTest
    static void testWhenQuoteEligibilityForRESSMOQuoteIdNullThenReturnNull(){
        Assert.areEqual(NULL, RESSMOEligibilityController.quoteEligibilityForRESSMO(null,false),'');
    }

    /**
     * @description This is a test method that tests the behavior of the RESSMOEligibilityController class
     * when checking the eligibility of a quote for RESSMO.
     * It verifies that the eligibility messages, primary quote flag, status, RESSMO link,
     * opportunity stage name, and banking info are correctly populated in the result wrapper.
     */
    @isTest
    static void testWhenQuoteEligibilityForRESSMOThenReturnWrapper(){

        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };

        Id accountId = Fake.generateId(Account.class);
        //Account acc = new Account(Id = accountId, Name = 'Test Account');

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true, SBQQ__Status__c = 'Approved', RESSMO_Store_Account_Id__c = accountId, SSMO_Validation__c = 'Success');
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>{
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Name'}
        };

        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IRessmoMappingsSelector ressmoMappingsSelectorMock = (IRessmoMappingsSelector) mocks.mock(IRessmoMappingsSelector.class);

        mocks.startStubbing();

        mocks.when(ressmoMappingsSelectorMock.SObjectType()).thenReturn(RESSMO_Mapping__mdt.SObjectType);
        mocks.when(ressmoMappingsSelectorMock.selectAllRessmoMappings()).thenReturn(ressmoMappings);

        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings)).thenReturn(sobjectToSetOfField);
        mocks.when(mockRESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quoteId)).thenReturn(quote);

        mocks.when(mockRESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems)).thenReturn(new Map<String,List<String>>());
        mocks.when(mockRESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject)).thenReturn(new Map<String,List<String>>());

        mocks.when(mockRESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Primary__c', ddmxObjectToSobject)).thenReturn(true);
        mocks.when(mockRESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Status__c', ddmxObjectToSobject)).thenReturn('Approved');
        mocks.when(mockRESSMOService.getFieldValueFromSobject('Opportunity', 'RESSMO_Link__c', ddmxObjectToSobject)).thenReturn('Test Link');
        mocks.when(mockRESSMOService.getFieldValueFromSobject('Opportunity', 'StageName', ddmxObjectToSobject)).thenReturn('Needs Analysis');

        mocks.stopStubbing();

        Application.SELECTOR.setMock(ressmoMappingsSelectorMock);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);

        RESSMOEligibilityController.RESSMOEligibilityWrapper result = RESSMOEligibilityController.quoteEligibilityForRESSMO(quoteId,false);

        Assert.areEqual(true, result.isPrimaryQuote, 'Primary Quote should be true');
        Assert.areEqual('Approved', result.status, 'Status should be Approved');
        Assert.areEqual('Test Link', result.ressmoLink, 'RESSMO Link should be Test Link');
        Assert.areEqual('Needs Analysis', result.oppStageName, 'Opportunity Stage Name should be Needs Analysis');
        Assert.areEqual(NULL, result.bankingInfo, 'Banking Info should be null');
    }


    /**
     * @description This is a test method that tests the behavior of the RESSMOEligibilityController class
     * when checking the eligibility of a quote for RESSMO.
     * It verifies that the eligibility messages, primary quote flag, status, RESSMO link,
     * opportunity stage name, and banking info are correctly populated in the result wrapper.
     */

    @isTest
    static void testWhenQuotesEligibilityForRESSMOThenReturnWrapper(){

        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> listofQuotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true, SBQQ__Status__c = 'Approved', RESSMO_Store_Account_Id__c = accountId);
        listofQuotes.add(quote);
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>{
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Name'}
        };

        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        ddmxObjectToSobject.put('SBQQ__Quote__c', quote);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IRessmoMappingsSelector ressmoMappingsSelectorMock = (IRessmoMappingsSelector) mocks.mock(IRessmoMappingsSelector.class);

        mocks.startStubbing();

        mocks.when(ressmoMappingsSelectorMock.SObjectType()).thenReturn(RESSMO_Mapping__mdt.SObjectType);
        mocks.when(ressmoMappingsSelectorMock.selectAllRessmoMappings()).thenReturn(ressmoMappings);

        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings))
            .thenReturn(sobjectToSetOfField);
        mocks.when(mockRESSMOService.getQuotesAndQuoteLinesWithFieldsFromMetaData(new set<Id>{quoteId}, sobjectToSetOfField)).thenReturn(listofQuotes);

        mocks.when(mockRESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems)).thenReturn(new Map<String,List<String>>());
        mocks.when(mockRESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(ressmoMappingsSelectorMock);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);

        Set<Id> ids = RESSMOEligibilityController.quotesEligibilityForRESSMO(listofQuotes);
        Assert.areEqual(1, ids.size(), 'No Validation Message Found');
    }

    /**
    * @description Testing contract eligibility for RESSMO, return a list of messages.
    * @author Pankaj | 07-18-2024
    **/
    @isTest
    static void testWhenContractEligibilityForRESSMOThenReturnListofMessage(){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<string,List<String>>();
        objectVsEligibilityMessages.put('Account (Business Account)', new List<String>{'My Mock Message'});
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };
         RESSMO_UI_Input__mdt accountField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'Order_Protocol__c')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Account')
            .setField(RESSMO_UI_Input__mdt.Section__c,ACCOUNT_SECTION)
            .setFakeId()
            .tosObject();

        RESSMO_UI_Input__mdt contactField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'FirstName')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Contact')
            .setField(RESSMO_UI_Input__mdt.Section__c,CONTACT_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField
        };
        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();

        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
                .setChildren('OpportunityContactRoles',new List<Fake>{new Fake(OpportunityContactRole.class)
                                                        .setField(OpportunityContactRole.Role,'Contract Signatory')
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())
                                                         .setFakeId()
                })
                .setFakeId()
                .tosObject();
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setfield(Contract.RESSMO_Eligible__C,true)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.Pricing_Variation_Type__c ,'None')
            .setField(Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Inactive')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                .setField(Account.Name, 'Testing')
                .setField(Account.RecordTypeID, businessRecordTypeId)
                .setField(Account.Primary_Vertical__c, 'Rx')
                .setField(Account.Segment__c, 'SMB')
            ).setchildren(
                'SBQQ__Subscriptions__r',
                new List<Fake>{
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.Id, subscriptionId)
                        .setParent(
                            'SBQQ__Product__r',
                            new Fake(Product2.class)
                            .setField(Product2.Id, prodid)
                            .setField(Product2.SSMO_Eligible__c, false)
                            .setField(Product2.ProductCode, '091090')
                            .setField(Product2.Name, 'Storefront')
                            .setField(Product2.Family, 'Storefront')
                        )
                        }
            ).toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);

        mocks.startStubbing();
        mocks.when(mockRESSMOService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOService.getEligibilityMessagesForContract(contract,null,null,null)).thenReturn(objectVsEligibilityMessages);
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
        mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
        mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

        mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
        mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);

        mocks.stopStubbing();
        /*   Application.SELECTOR.setMock(contractSelectorMock);*/
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        RESSMOEligibilityController.RESSMOEligibilityWrapper resultSuccess = RESSMOEligibilityController.contractEligibilityForRESSMO(contract.Id, false);
        Test.stopTest();
        Boolean expectedValue = (resultSuccess.eligibilityMessages.size() >= 1)? true : false;
        Assert.areEqual(true, expectedValue, 'No Validation Found');
        Assert.areEqual(true,resultSuccess.refreshUI,'UI Refresh should be true');

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_match.sObjectWith(
            new Map<sObjectField,Object>{
               Schema.Contract.RESSMO_Eligible__c => false
            }
        ));
    }

    /**
    * @description testing when contract ressmo eligible is false and eligibility meesage is there then do no updste contract
	* and refresh Ui should be false
    * @author Soumya | 08-13-2024
    **/
    @isTest
    static void testWhenContractRESSMOFalseAndListOfMessageThenRefreshUIFalse(){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<string,List<String>>();
        objectVsEligibilityMessages.put('Account (Business Account)', new List<String>{'Validation Found'});

        Id businessAccId = Fake.generateId(Account.class);
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
         map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };
         RESSMO_UI_Input__mdt accountField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'Order_Protocol__c')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Account')
            .setField(RESSMO_UI_Input__mdt.Section__c,ACCOUNT_SECTION)
            .setFakeId()
            .tosObject();

        RESSMO_UI_Input__mdt contactField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'FirstName')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Contact')
            .setField(RESSMO_UI_Input__mdt.Section__c,CONTACT_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField
        };
        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();

        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
                .setChildren('OpportunityContactRoles',new List<Fake>{new Fake(OpportunityContactRole.class)
                                                        .setField(OpportunityContactRole.Role,'Contract Signatory')
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())
                                                         .setFakeId()
                })
                .setFakeId()
                .tosObject();
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setfield(Contract.RESSMO_Eligible__C,false)
            .setfield(Contract.SSMO_Validation__c,'Success')
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.Pricing_Variation_Type__c ,'None')
            .setField(Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Active')
                								.setField(Mx_Onboarding_Link__c.One_Time_Mx_Link__c,ONE_TIME_MX_LINK)
                                                .setField(Mx_Onboarding_Link__c.Inactive_Reason__c,'')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                .setField(Account.Id, businessAccId)
                .setField(Account.Name, 'Testing')
                .setField(Account.RecordTypeID, businessRecordTypeId)
                .setField(Account.Primary_Vertical__c, 'Rx')
                .setField(Account.Segment__c, 'SMB')
            ).setchildren(
                'SBQQ__Subscriptions__r',
                new List<Fake>{
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.Id, subscriptionId)
                        .setParent(
                            'SBQQ__Product__r',
                            new Fake(Product2.class)
                            .setField(Product2.Id, prodid)
                            .setField(Product2.SSMO_Eligible__c, false)
                            .setField(Product2.ProductCode, '091090')
                            .setField(Product2.Name, 'Storefront')
                            .setField(Product2.Family, 'Storefront')
                        )
                        }
            ).toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);

        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);

        mocks.startStubbing();
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
        mocks.when(mockRESSMOService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOService.getEligibilityMessagesForContract(contract,null,null,null)).thenReturn(objectVsEligibilityMessages);
        mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.id)).thenReturn(contract);
        mocks.when(mockContractsSelector.selectByParentAccountId(new set<Id>{contract.AccountId})).thenReturn(new List<Contract>{contract});

        mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
        mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

        mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
        mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);
        mocks.stopStubbing();


        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        RESSMOEligibilityController.RESSMOEligibilityWrapper resultSuccess = RESSMOEligibilityController.contractEligibilityForRESSMO(contract.Id, false);
        Test.stopTest();
        Boolean expectedValue = (resultSuccess.eligibilityMessages.size() >= 1)? true : false;

        Assert.areEqual(true, expectedValue, 'No Validation Found');
        Assert.areEqual(ONE_TIME_MX_LINK,resultSuccess.ressmoLink,'Incorrect ressmo link');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,0)).registerDirty(contract);
    }


    /**
    * @description  - test when contract was not ressmo eligible and no list of eligiblity message then update contract
    * along with refresh ui true
    * @author Soumya Dash | 08-16-2024
    **/
    @isTest
    static void testWhenContractRESSMOFalseAndNoListOfMessageThenRefreshUITrueAndContractUpdate(){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<string,List<String>>();
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

         map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };
         RESSMO_UI_Input__mdt accountField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'Order_Protocol__c')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Account')
            .setField(RESSMO_UI_Input__mdt.Section__c,ACCOUNT_SECTION)
            .setFakeId()
            .tosObject();

        RESSMO_UI_Input__mdt contactField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'FirstName')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Contact')
            .setField(RESSMO_UI_Input__mdt.Section__c,CONTACT_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField
        };
        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();

        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
                .setChildren('OpportunityContactRoles',new List<Fake>{new Fake(OpportunityContactRole.class)
                                                        .setField(OpportunityContactRole.Role,'Contract Signatory')
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())
                                                         .setFakeId()
                })
                .setFakeId()
                .tosObject();
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setfield(Contract.RESSMO_Eligible__C,false)
            .setfield(Contract.SSMO_Validation__c,'Success')
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Inactive')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                .setField(Account.Name, 'Testing')
                .setField(Account.RecordTypeID, businessRecordTypeId)
                .setField(Account.Primary_Vertical__c, 'Rx')
                .setField(Account.Segment__c, 'SMB')
            ).setchildren(
                'SBQQ__Subscriptions__r',
                new List<Fake>{
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.Id, subscriptionId)
                        .setParent(
                            'SBQQ__Product__r',
                            new Fake(Product2.class)
                            .setField(Product2.Id, prodid)
                            .setField(Product2.SSMO_Eligible__c, false)
                            .setField(Product2.ProductCode, '091090')
                            .setField(Product2.Name, 'Storefront')
                            .setField(Product2.Family, 'Storefront')
                        )
                        }
            ).toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);

        IContractsSelector mockContractsSelector = (IContractsSelector)mocks.mock(IContractsSelector.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);

        mocks.startStubbing();
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
        mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.Id)).thenReturn(contract);

        mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
        mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);

        mocks.when(mockRESSMOService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOService.getEligibilityMessagesForContract(contract,null,null,null)).thenReturn(objectVsEligibilityMessages);

        mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
        mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        RESSMOEligibilityController.RESSMOEligibilityWrapper resultSuccess = RESSMOEligibilityController.contractEligibilityForRESSMO(contract.Id, false);
        Test.stopTest();

        Assert.areEqual(0,resultSuccess.eligibilityMessages.size(),'Validation messages should Not be there');
        Assert.areEqual(true,resultSuccess.refreshUI,'UI Refresh should be true');

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectFIeld,Object>{
                Schema.Contract.RESSMO_Eligible__c => true
            }
        ));
    }

    /**
    * @description testing when user changes store new store id will be populated on quote
    **/
     @isTest
    static void testWhenUpdateRecordWithNewStoreIdThenStoreDetails(){

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(mockUow);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        Account storeAccount = new Account(
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Segment__c = 'SMB',
            Name = 'Test Store Account'
        );
        insert storeAccount;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = quoteId
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(AccountsSelector.class);
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.getStoreAccounts(new Set<Id>{storeAccount.Id}))
            .thenReturn(new List<Account>{storeAccount});
        mocks.stopStubbing();

        Application.Selector.setMock(mockAccountsSelector);
        Test.startTest();
        RESSMOEligibilityController.ChangeStoreWrapper result = RESSMOEligibilityController.updateRecordWithNewStoreId(quote.id, storeAccount.id, false);
        Test.stopTest();
        Assert.areNotEqual(null,result,'Quote is not updated');
        Assert.areEqual(storeAccount.id, result.storeAccount.Id,'store detailes not found');

    }

    /**
    * @description test when businessid provided then return lated crested store
    **/
     @isTest
    static void testWhenPassesBusinessidThenGetStores(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(mockUow);
        Account businessAccount = new Account(
               Name = 'Test Business Account',
               Segment__c = 'SMB');

        insert businessAccount;
        Account storeAccount = new Account(
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Name = 'Test Store Account',
            Address_Verification_Status__c = 'Verified',
            Coverage__c = 'In Coverage',
            Segment__c = 'SMB',
            ParentId = businessAccount.id
        );
        insert storeAccount;

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(AccountsSelector.class);
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.getStoreAccountbyBusinessAccountId(businessAccount.id))
            .thenReturn(new List<Account>{storeAccount});
        mocks.stopStubbing();
        // Register the mock selector
        Application.Selector.setMock(mockAccountsSelector);

        Test.startTest();
        RESSMOEligibilityController.ChangeStoreWrapper result = RESSMOEligibilityController.getStoresToPrepopulate(businessAccount.id);
        Test.stopTest();
        Assert.areNotEqual(null,result,'Store Not Found');
        Assert.areEqual(storeAccount.id, result.storeAccount.id,'Store Not Found');

    }

    /**
    * @description testing quote SSMO Eligibility
    **/
     @isTest
    static void testWhenQuoteEligibilityForRESSMOThenReturnWrapperWithSSMOValidations(){

        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };

        Id accountId = Fake.generateId(Account.class);
        //Account acc = new Account(Id = accountId, Name = 'Test Account');

       // Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c quote = new SBQQ__Quote__c( SBQQ__Primary__c = true, SBQQ__Status__c = 'Approved', RESSMO_Store_Account_Id__c = accountId);
        insert quote;
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>{
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Name'}
        };

        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IRessmoMappingsSelector ressmoMappingsSelectorMock = (IRessmoMappingsSelector) mocks.mock(IRessmoMappingsSelector.class);

        mocks.startStubbing();

        mocks.when(ressmoMappingsSelectorMock.SObjectType()).thenReturn(RESSMO_Mapping__mdt.SObjectType);
        mocks.when(ressmoMappingsSelectorMock.selectAllRessmoMappings()).thenReturn(ressmoMappings);

        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings)).thenReturn(sobjectToSetOfField);
        mocks.when(mockRESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quote.id)).thenReturn(quote);

        mocks.when(mockRESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems)).thenReturn(new Map<String,List<String>>());
        mocks.when(mockRESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject)).thenReturn(new Map<String,List<String>>());

        mocks.when(mockRESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Primary__c', ddmxObjectToSobject)).thenReturn(true);
        mocks.when(mockRESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Status__c', ddmxObjectToSobject)).thenReturn('Approved');
        mocks.when(mockRESSMOService.getFieldValueFromSobject('Opportunity', 'RESSMO_Link__c', ddmxObjectToSobject)).thenReturn('Test Link');
        mocks.when(mockRESSMOService.getFieldValueFromSobject('Opportunity', 'StageName', ddmxObjectToSobject)).thenReturn('Needs Analysis');
        SSMOWrapper.ResultMessageWrapper resultWrap = new SSMOWrapper.ResultMessageWrapper();
        resultWrap.messages = new List<String>{'Error meassages from SSMO'};
        resultWrap.status = 'Success';
        mocks.when(mockRESSMOService.sendQuote(quote.Id, '', True)).thenReturn(resultWrap);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(ressmoMappingsSelectorMock);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);

        RESSMOEligibilityController.RESSMOEligibilityWrapper result = RESSMOEligibilityController.quoteEligibilityForRESSMO(quote.id,true);

        Assert.areEqual(true, result.isPrimaryQuote, 'Primary Quote should be true');
        Assert.areEqual('Approved', result.status, 'Status should be Approved');
        Assert.areEqual('Test Link', result.ressmoLink, 'RESSMO Link should be Test Link');
        Assert.areEqual('Needs Analysis', result.oppStageName, 'Opportunity Stage Name should be Needs Analysis');
        Assert.areEqual(NULL, result.bankingInfo, 'Banking Info should be null');


    }

 /**
    * @description  - test SSMO eligibility on contract
    **/
    @isTest
    private static void testWhenSSMOValidationsThenUpdateOnContract() {
        Map<String,List<String>> objectVsEligibilityMessages = new Map<string,List<String>>();
        objectVsEligibilityMessages.put('Account (Business Account)', new List<String>{'My Mock Message'});
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };
         RESSMO_UI_Input__mdt accountField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'Order_Protocol__c')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Account')
            .setField(RESSMO_UI_Input__mdt.Section__c,ACCOUNT_SECTION)
            .setFakeId()
            .tosObject();

        RESSMO_UI_Input__mdt contactField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'FirstName')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'Contact')
            .setField(RESSMO_UI_Input__mdt.Section__c,CONTACT_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField
        };
        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();

        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
                .setChildren('OpportunityContactRoles',new List<Fake>{new Fake(OpportunityContactRole.class)
                                                        .setField(OpportunityContactRole.Role,'Contract Signatory')
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())
                                                         .setFakeId()
                })
                .setFakeId()
                .tosObject();
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setfield(Contract.RESSMO_Eligible__C,true)
            .setfield(Contract.SSMO_Validation__C,'SSMO validation messages')
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Inactive')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                .setField(Account.Name, 'Testing')
                .setField(Account.RecordTypeID, businessRecordTypeId)
                .setField(Account.Primary_Vertical__c, 'Rx')
                .setField(Account.Segment__c, 'SMB')
            ).setchildren(
                'SBQQ__Subscriptions__r',
                new List<Fake>{
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.Id, subscriptionId)
                        .setParent(
                            'SBQQ__Product__r',
                            new Fake(Product2.class)
                            .setField(Product2.Id, prodid)
                            .setField(Product2.SSMO_Eligible__c, false)
                            .setField(Product2.ProductCode, '091090')
                            .setField(Product2.Name, 'Storefront')
                            .setField(Product2.Family, 'Storefront')
                        )
                        }
            ).toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);

        mocks.startStubbing();

        mocks.when(mockRESSMOService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOService.getEligibilityMessagesForContract(contract,null,null,null)).thenReturn(objectVsEligibilityMessages);
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
        mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.Id)).thenReturn(contract);
        mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
        mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

        mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
        mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);

        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);

        Test.startTest();
        RESSMOEligibilityController.RESSMOEligibilityWrapper result = RESSMOEligibilityController.contractEligibilityForRESSMO(contract.Id, false);
        Test.stopTest();
        Contract resultcontract = (Contract)result.contract;
        Assert.areEqual('SSMO validation messages', resultcontract.SSMO_Validation__c, 'received SSMO validtions');
    }


    /**
    * @description Log creation when store account linked
    **/
    @isTest
    private static void testWhenUpdateRecordWithNewStoreIdThenLogMessage(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        Id contractId = Fake.generateId(Contract.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Name,'Test Parent Account')
            .setField(Account.Id,businessAccountId)
            .tosObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Name, SUBMARKET_NAME)
            .setField(Account.ParentId, businessAccount.Id)
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                    .setField(Brand__c.Id, Fake.generateId(Brand__c.class))
                    .setField(Brand__c.Name, BRAND)
            )
            .toSObject();
        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .tosObject();

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(AccountsSelector.class);

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Schema.Account.sObjectType);
        mocks.when(mockAccountsSelector.getStoreAccounts(new Set<Id>{storeAccount.Id}))
            .thenReturn(new List<Account>{storeAccount});
        mocks.stopStubbing();
        Application.Selector.setMock(mockAccountsSelector);
        Application.UnitOfWork.setMock(mockUow);

        Test.startTest();
        RESSMOEligibilityController.ChangeStoreWrapper result = RESSMOEligibilityController.updateRecordWithNewStoreId(contract.id, storeAccount.id, true);
        Test.stopTest();
        Assert.areEqual(storeAccount.id, result.storeAccount.Id,'Store Account found');
    }

}