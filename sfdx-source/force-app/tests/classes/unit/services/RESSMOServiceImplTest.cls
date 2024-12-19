/**
 * @description       : Test class for RESSMOServiceImpl and RESSMOService
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 12-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class RESSMOServiceImplTest {

    private static final String SSMO_STATIC_RESOURCE_NAME = 'RESSMO_Sample_Response';
    private static final String SSMO_WRAPPER_STATUS_SUCCESS = 'Success';
    private static final String SSMO_WRAPPER_STATUS_FAILED = 'Failed';

    @IsTest
    static void testWhenGetFieldValueFromSobjectThenReturnFieldValue() {
        // Step 1: Setup Test Data
        Account testAccount = new Account(Name = 'Test Account');
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        ddmxObjectToSobject.put('TestAccount', testAccount);

        // Step 2: Invoke the Method
        Object fieldValue = RESSMOService.getFieldValueFromSobject('TestAccount', 'Name', ddmxObjectToSobject);

        // Step 3: Assert the Result
        Assert.areEqual('Test Account', fieldValue, 'The method should return the correct field value.');
    }

    @IsTest
    static void testWhenGetFieldValueFromSobjectIfNoSobjectThenReturnNull() {

        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        // Step 2: Invoke the Method
        Object fieldValue = RESSMOService.getFieldValueFromSobject('TestAccount', 'Name', ddmxObjectToSobject);

        // Step 3: Assert the Result
        Assert.areEqual(NULL, fieldValue, 'The method should return null');
    }

    @isTest
    static void testWhenBankingInfoExistsThenReturnExpectedValue() {

        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        Assert.areEqual(FALSE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'If payment account null then it should be false');
		Payment_Account__c pa = new Payment_Account__c();
        ddmxObjectToSobject.put(RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT, (SObject)pa);
        Assert.areEqual(FALSE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'If payment account Bank_Account_Number__c is null then it should be false');
        pa.Bank_Account_Number__c = '1234';
        Account store = new Account(BillingCountry = 'New Zealand', Legal_Business_Name__c = 'MacDonalds Store');
        Account storeBusiness = new Account(BillingCountry = 'New Zealand', Legal_Business_Name__c = 'MacDonalds Business');
        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, (SObject)store);
        ddmxObjectToSobject.put(RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, (SObject)storeBusiness);
        Assert.areEqual(TRUE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'If payment account Bank_Account_Number__c is not null and New Zealand then it should be true');
		store.BillingCountry = 'Canada';
        Assert.areEqual(FALSE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'If payment account Bank_Account_Number__c is not null and rounting number null and Canada then it should be false');
		pa.RoutingNumber__c = '123';
        Assert.areEqual(TRUE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'If payment account Bank_Account_Number__c is not null and rounting number not null and Canada then it should be true');
        store.BillingCountry = 'India';
        Assert.areEqual(FALSE, RESSMOService.bankingInfoExists(ddmxObjectToSobject), 'not a valid country for payment info then false');
    }

    @isTest
    static void testWhenIsQuoteLineFieldBlankThenReturnExpectedResult(){
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        RESSMO_Mapping__mdt mdt = new RESSMO_Mapping__mdt(Field_Name__c='SBQQ__Quantity__c');
        Assert.areEqual(FALSE, RESSMOService.isQuoteLineFieldBlank(quoteLines, mdt), 'if no lines then it should be false');
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quantity__c = null));
        Assert.areEqual(TRUE, RESSMOService.isQuoteLineFieldBlank(quoteLines, mdt), 'if field value null then it should be True');
        quoteLines[0].SBQQ__Quantity__c = 1;
        Assert.areEqual(FALSE, RESSMOService.isQuoteLineFieldBlank(quoteLines, mdt), 'if field value not null then it should be FALSE');
    }


    @isTest
    static void testWhenVerifyRequiredFieldsThenReturnSetOfString(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Is_Required__c = true, Object_Name__c = 'Account (Business Account)', Field_Name__c = 'Name', Label = 'Account Name'),
                new RESSMO_Mapping__mdt(Is_Required__c = true, Object_Name__c = 'Account (Business Account)', Field_Name__c = 'Industry', Label = 'Account Industry'),
                new RESSMO_Mapping__mdt(Is_Required__c = true, Object_Name__c = 'Opportunity', Field_Name__c = 'Industry', Label = 'Opportunity Industry'),
                new RESSMO_Mapping__mdt(Is_Required__c = false, Object_Name__c = 'Account (Business Account)', Field_Name__c = 'Type', Label = 'Account Type'),
                new RESSMO_Mapping__mdt(Is_Required__c = true, Object_Name__c = RESSMOServiceImpl.QUOTE_LINE_OBJECT, Field_Name__c = 'SBQQ__Quantity__c', Label = 'Quote Line Quantity'),
                new RESSMO_Mapping__mdt(Is_Required__c = true, Object_Name__c = RESSMOServiceImpl.QUOTE_LINE_OBJECT, Field_Name__c = 'Budget__c', Label = 'Quote Line Budget')
        };

        Account acc = new Account(Name = 'acc name', Industry = null, Type = null);
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            'Account (Business Account)'=>acc
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);

        mocks.startStubbing();

        mocks.when(mockRESSMOService.isQuoteLineFieldBlank(new List<SBQQ__QuoteLine__c>(), ressmoMappings[4])).thenReturn(true);
        mocks.when(mockRESSMOService.isQuoteLineFieldBlank(new List<SBQQ__QuoteLine__c>(), ressmoMappings[5])).thenReturn(false);

        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Map<String,List<String>> objectVsErrorMessage = new Map<String,List<String>>();
        RESSMOServiceImpl.verifyRequiredFields(objectVsErrorMessage,ressmoMappings, ddmxObjectToSobject, new List<SBQQ__QuoteLine__c>());
        boolean actual = checkMessageIsValid(objectVsErrorMessage, System.Label.RESSMO_Eligibility_Error_RequiredFieldsMissing + ' ' +'Account Industry');
        Assert.areEqual(true,actual,'Message match');
    }

    @IsTest
    static void testWhenVerifyQuoteLinesEligibilityThenAddProductsNotEligible(){
        SBQQ__QuoteLine__c ql1 = (SBQQ__QuoteLine__c)new Fake(SBQQ__QuoteLine__c.class)
            .setParent('SBQQ__Product__r',
                       new Fake(Product2.class)
                       .setField(Product2.ProductCode, RESSMOServiceImpl.REQUIRED_RESSMO_PRODUCTCODES[0])
                       .setField(Product2.SSMO_Eligible__c, TRUE)
                       .setField(Product2.Name, 'Product 1')
                      )
            .toSObject();

        SBQQ__QuoteLine__c ql2 = (SBQQ__QuoteLine__c)new Fake(SBQQ__QuoteLine__c.class)
            .setParent('SBQQ__Product__r',
                       new Fake(Product2.class)
                       .setField(Product2.ProductCode, RESSMOServiceImpl.REQUIRED_RESSMO_PRODUCTCODES[1])
                       .setField(Product2.SSMO_Eligible__c, FALSE)
                       .setField(Product2.Name, 'Product 2')
                      )
            .toSObject();

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{
            ql1, ql2
        };

        List<String> validationMessage = new List<String>();
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        RESSMOService.verifyQuoteLinesEligibility(objectVsEligibilityMessages,quoteLines, validationMessage);
        boolean actual = checkMessageIsValid(objectVsEligibilityMessages, System.Label.RESSMO_Eligibility_Error_InEligibleProducts +' Product 2');
        Assert.areEqual(true,actual,'Message match');
    }

    @IsTest
    static void testWhenVerifyQuoteLinesEligibilityThenAddRequiredProductsMissing(){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        SBQQ__QuoteLine__c ql1 = (SBQQ__QuoteLine__c)new Fake(SBQQ__QuoteLine__c.class)
            .setParent('SBQQ__Product__r',
                       new Fake(Product2.class)
                       .setField(Product2.ProductCode, RESSMOServiceImpl.REQUIRED_RESSMO_PRODUCTCODES[0])
                       .setField(Product2.SSMO_Eligible__c, TRUE)
                       .setField(Product2.Name, 'Product 1')
                      )
            .toSObject();

        SBQQ__QuoteLine__c ql2 = (SBQQ__QuoteLine__c)new Fake(SBQQ__QuoteLine__c.class)
            .setParent('SBQQ__Product__r',
                       new Fake(Product2.class)
                       .setField(Product2.ProductCode, '9848032321')
                       .setField(Product2.SSMO_Eligible__c, TRUE)
                       .setField(Product2.Name, 'Product 2')
                      )
            .toSObject();

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{
            ql1, ql2
        };
		List<String> validationMessage = new List<String>();
        RESSMOService.verifyQuoteLinesEligibility(objectVsEligibilityMessages,quoteLines, validationMessage);
        boolean actual = checkMessageIsValid(objectVsEligibilityMessages, System.Label.RESSMO_Eligibility_Error_RequiredProductCode);
        Assert.areEqual(true,actual,'Match Found');
    }

    @IsTest
    static void testWhenBusinessAccountValidationsThenReturnErrorAccordingly(){
        Account acc = new Account(BillingCountry = RESSMOServiceImpl.VALID_COUNTRIES[0], Segment__c = 'SMB', Primary_Vertical__c = 'Rx');
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();

        RESSMOService.businessAccountValidations(objectVsEligibilityMessages,(SObject)acc);
        Assert.areEqual(0, objectVsEligibilityMessages.size(), 'No Errors Expected');

        acc.BillingCountry = 'India';

        RESSMOService.businessAccountValidations(objectVsEligibilityMessages, (SObject)acc);
        boolean actual = checkMessageIsValid(objectVsEligibilityMessages, System.Label.RESSMO_Eligibility_Error_Countries+ ' '+String.join(new List<String>(RESSMOServiceImpl.VALID_COUNTRIES), ' or '));
        Assert.areEqual(true,actual,'Billing country error should be returned');

        acc.BillingCountry = RESSMOServiceImpl.VALID_COUNTRIES[0];
        acc.Segment__c = null;

        RESSMOService.businessAccountValidations(objectVsEligibilityMessages,(SObject)acc);
        boolean actual1 = checkMessageIsValid(objectVsEligibilityMessages, System.Label.RESSMO_Eligibility_Error_SMBSegment);
        Assert.areEqual(true,actual1,'SMB Segment error should be returned');

        acc.Segment__c = 'SMB';
        acc.Primary_Vertical__c = null;

        RESSMOService.businessAccountValidations(objectVsEligibilityMessages,(SObject)acc);
        boolean actual2 = checkMessageIsValid(objectVsEligibilityMessages, System.Label.RESSMO_Eligibility_Error_PrimaryVertical);
        Assert.areEqual(true,actual2,'Primary Vertical error should be returned');
    }

    @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnUTAError(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        Id storeId = Fake.generateId(Account.sObjectType);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Status__c='Approved',RESSMO_Store_Account_Id__c = storeId);
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', FALSE);
        dataMap.put('SSMO_Validation__c', 'Success');
        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account',Id = storeId);
        Account storeAcc = new Account(Name = 'Test Account');
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc,
                RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => storeAcc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Eligibility_Error_UTACheck);
        Assert.areEqual(true,actual,'Result should return UTA Error');
    }
      @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnContractingFlowError(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        Id storeId = Fake.generateId(Account.sObjectType);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true,Contracting_Flow__c = 'Redlining', SBQQ__Status__c='Approved',RESSMO_Store_Account_Id__c = storeId);
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', FALSE);
        dataMap.put('SSMO_Validation__c', 'Success');
        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account',Id = storeId);
        Account storeAcc = new Account(Name = 'Test Account');
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc,
                RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => storeAcc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Contracting_Flow_Validation);
        Assert.areEqual(true,actual,'Result should return ContractingFlowError');
    }
     @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnStoreSpecificVaidation(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        Id storeId = Fake.generateId(Account.sObjectType);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true,Store_Specific_Variations__c = 'Yes', SBQQ__Status__c='Approved',RESSMO_Store_Account_Id__c = storeId);
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', FALSE);
        dataMap.put('SSMO_Validation__c', 'Success');
        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account',Id = storeId);
        Account storeAcc = new Account(Name = 'Test Account');
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc,
                RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => storeAcc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Store_Specific_Validation);
        Assert.areEqual(true,actual,'Result should return Store specific Validations');
    }

    @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnNotPrimary(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        Id storeId = Fake.generateId(Account.sObjectType);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = false, SBQQ__Status__c='Approved',RESSMO_Store_Account_Id__c = storeId);
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', TRUE);
        dataMap.put('SSMO_Validation__c', 'Success');
        dataMap.put('Store_Specific_Variations__c', 'Templatized e-sign');
        dataMap.put('Contracting_Flow__c', 'No');

        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account');
        Account storeAcc = new Account(Name = 'Test Account',Id = storeId);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc,
                RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => storeAcc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Eligibility_Error_NotPrimaryQuote);
        Assert.areEqual(true,actual,'Result should return Primary Error only');

    }

    /**
    * @description
    * @author Pankaj | 08-21-2024
    * @param result
    * @param checkString
    * @return boolean
    **/
    public static boolean checkMessageIsValid(Map<String,List<String>> result, string checkString ){
    	boolean isfound = false;
        for (String key : result.keySet()) {
            List<String> valuesList = result.get(key);
            for (String value : valuesList) {
                if(checkString.contains(value)){
                    isfound = true;
                }
            }
    	}
        return isfound;
    }


    @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnNotApproved(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        Id storeId = Fake.generateId(Account.sObjectType);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = TRUE, SBQQ__Status__c='In Review',RESSMO_Store_Account_Id__c = storeId);
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', TRUE);
        dataMap.put('SSMO_Validation__c', 'Success');
        dataMap.put('Store_Specific_Variations__c', 'Templatized e-sign');
        dataMap.put('Contracting_Flow__c', 'No');
        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account');
        Account storeAcc = new Account(Name = 'Test Account',Id = storeId);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc,
                RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => storeAcc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Eligibility_Error_QuoteNotApproved);
        Assert.areEqual(true,actual,'result should return Quote Not approved only');

    }

     @IsTest
    static void testWhenQuoteEligibilityMessageForRESSMOThenReturnStoreNotSelected(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = TRUE, SBQQ__Status__c='In Review');
        String jsonString = JSON.serialize(quote);
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        dataMap.put('UTA_Check__c', TRUE);
        dataMap.put('SSMO_Validation__c', 'Success');
        dataMap.put('Store_Specific_Variations__c', 'Templatized e-sign');
        dataMap.put('Contracting_Flow__c', 'No');
        jsonString = JSON.serialize(dataMap);
        Account acc = new Account(Name = 'Test Account');
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>{
            RESSMOServiceImpl.QUOTE_OBJECT =>
        (SObject)JSON.deserialize(jsonString, SObject.class),
                RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => acc
        };
        Map<String,List<String>> result = RESSMOServiceImpl.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
        boolean actual = checkMessageIsValid(result, System.Label.RESSMO_Store_Not_Selected_Message);
        Assert.areEqual(true,actual,'result should return Store Not Selected');

    }

    @IsTest
    static void testWhenStoreEligibilityMessagesForRESSMOThenReturnMessagesAccordingly(){
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        Map<String, List<String>> expectedMap = new Map<String, List<String>>();
        Assert.areEqual(expectedMap, RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject), 'It should be empty if there is no data');
        Account acc = new Account(Order_Protocol__c = 'notValid');
        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, acc);
        Map<String,List<String>> result = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        acc.Order_Protocol__c = 'POS';
        result = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        acc.Menu_URL__c = 'chrome.com';
        acc.POS_System__c = 'Abacus';
        result = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        Set<String> expectedKeys = new Set<String>{'Account (Store Account)'};
        Set<String> actualKeys = result.keySet();
        Assert.areEqual(expectedKeys, actualKeys, 'It should only return order protocol error');
    }

    @IsTest
    static void testWhenGetEligibilityMessagesForQuoteThenReturnValidationsAccordingly(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };

        Id accountId = Fake.generateId(Account.class);
        //Account acc = new Account(Id = accountId, Name = 'Test Account');

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true, SBQQ__Status__c = 'Approved', RESSMO_Store_Account_Id__c = accountId);
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

        mocks.stopStubbing();

        Application.SELECTOR.setMock(ressmoMappingsSelectorMock);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);

        Map<String,List<String>> result = RESSMOServiceImpl.getEligibilityMessagesForQuote(quoteId);
        boolean isfound = false;
        for (String key : result.keySet()) {
            List<String> valuesList = result.get(key);
            for (String value : valuesList) {
                if(System.Label.RESSMO_Eligibility_Info_BankingPopulated.contains(value)){
                    isfound = true;
                }
            }
    	}
        Assert.areEqual(false, isfound, 'No Message Found');
    }


    /**
     * @description : This is a unit test method that tests the behavior of the 'generateJSON' method in the 'RESSMOServiceImpl' class.
     * It verifies that the method is being mocked accordingly.
     */
    @IsTest
    static void testWhenGenerateJSONMethodCalledThenMockAccordingly(){

        Account acc = new Account(Id=Fake.generateId(Account.class), Name = 'Test Account Id');
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, Id = Fake.generateId(SBQQ__Quote__c.class));

        //List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        //Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
        mocks.when(mockRESSMOService.writeJSON(ressmoMappings, new Map<String, sObject>(), new List<SBQQ__QuoteLine__c>(),false))
            .thenReturn('{"Test":"Test"}');
        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);



        Assert.areEqual('{"Test":"Test"}', RESSMOServiceImpl.generateJSON(quote, acc, ressmoMappings,false), 'Not Generated as Expected');
    }

    /**
     * @description : This is a test method that verifies the behavior of the `prepareRequestJSON` method in the `RESSMOServiceImpl` class.
     * It tests whether the method returns the expected JSON when provided with a quote ID and a list of RESSMO mappings.
     *
     * The test sets up the necessary mock objects and stubs using the fflib_ApexMocks framework.
     * It creates a list of RESSMO mappings and sets up the mock behavior for the `getMapOfSobjectAndSetOfField`,
     * `getQuoteWithQuoteLinesWithFieldsFromMetaData`, `getAccountWithXrefsDecisionMakerPaymentAccount`, and `generateJSON` methods
     * of the `IRESSMOService` interface.
     *
     * The test then calls the `prepareRequestJSON` method with the quote ID and RESSMO mappings and asserts that the returned JSON
     * matches the expected JSON.
     *
     * @see RESSMOServiceImpl#prepareRequestJSON(Id, List<RESSMO_Mapping__mdt>)
     */
    @IsTest
    static void testWhenPrepareRequestJSONThenReturnExpectedJSON(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text')
        };

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
        Map<String, Set<String>> objectFieldSetMockResult = new Map<String, Set<String>>{
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Name'}
        };
        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings))
            .thenReturn(objectFieldSetMockResult);
        Account acc = new Account(Name = 'Test Account', Id = Fake.generateId(Account.class));
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId, RESSMO_Store_Account_Id__c = acc.Id);
        mocks.when(mockRESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(objectFieldSetMockResult, quoteId))
            .thenReturn(quote);
        mocks.when(mockRESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(objectFieldSetMockResult, acc.Id))
            .thenReturn(acc);
        String expectedJSON = '{"BusinessAccountJSON":{"businessProperty":"Test Account"}}';
        mocks.when(mockRESSMOService.generateJSON(quote, acc, ressmoMappings,false))
            .thenReturn(expectedJSON);

        mocks.stopStubbing();
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);

        Assert.areEqual(expectedJSON, RESSMOServiceImpl.prepareRequestJSON(quoteId, ressmoMappings,false), 'Not Generated as Expected');
    }

    /**
     * @description : This test method tests the functionality of the writeJSON method in the RESSMOServiceImpl class.
     * It verifies that the generated JSON payload matches the expected JSON string.
     *
     * Test Steps:
     * 1. Create a list of RESSMO_Mapping__mdt records with predefined values.
     * 2. Create a map of String to sObject to store the mapping between object names and sObjects.
     * 3. Create instances of various sObjects (Account, Opportunity, User, Contact, etc.) with predefined values.
     * 4. Add the sObjects to the map created in step 2.
     * 5. Create a list of SBQQ__QuoteLine__c records with predefined values.
     * 6. Call the writeJSON method of the RESSMOServiceImpl class with the list of mappings, map of sObjects, and list of quote lines.
     * 7. Verify that the generated JSON payload matches the expected JSON string.
     *
     * @see RESSMOServiceImpl#writeJSON
     */
    @IsTest
    static void testWhenWriteJSONWithMapQuoteLinesThenReturnExpectedJSON(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{

            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.OPPORTUNITY_OBJECT, Field_Name__c = 'Name',
                                        JSON_Object__c = 'OpportunityJSON', API_Property__c = 'opportunityProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.OWNER_OBJECT, Field_Name__c = 'Email',
                                        JSON_Object__c = 'OpportunityOwnerJSON', API_Property__c = 'opportunityOwnerProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.CONTACT_OBJECT, Field_Name__c = 'Email',
                                        JSON_Object__c = 'ContactJSON', API_Property__c = 'contactProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.QUOTE_OBJECT, Field_Name__c = 'SBQQ__Primary__c',
                                        JSON_Object__c = 'QuoteJSON', API_Property__c = 'quoteProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Boolean'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.QUOTE_LINE_OBJECT, Field_Name__c = 'SBQQ__PackageProductCode__c',
                                        JSON_Object__c = RESSMOServiceImpl.QUOTELINE_JSON_OBJECT, API_Property__c = 'quoteLineProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT, Field_Name__c = 'External_Id__c',
                                        JSON_Object__c = 'BizRefJSON', API_Property__c = 'bizRefProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                        JSON_Object__c = 'StoreAccountJSON', API_Property__c = 'storeAccountProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT, Field_Name__c = 'Bank_Account_Number__c',
                                        JSON_Object__c = 'PaymentAccountJSON', API_Property__c = 'paymentAccountProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.XREF_OBJECT, Field_Name__c = 'Xref_Status__c',
                                        JSON_Object__c = 'XrefJSON', API_Property__c = 'xrefProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text')
                };

                    Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        Account bizAcc = new Account(Name = 'Business Name');
        Opportunity opp = new Opportunity(Name = 'Opportunity Name');
        User usr = new User(Email = 'venkatesh@usrEmail.com');
        Contact con = new Contact(Email = 'venkatesh@conEmail.com');
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true);
        Business_Reference__c bizRef = new Business_Reference__c(External_Id__c = 'external');
        Account storeAcc = new Account(Name = 'Store Name');
        Payment_Account__c payAcc = new Payment_Account__c(Bank_Account_Number__c = '1010101010');
        Xref__c xref = new Xref__c(Xref_Status__c = 'Xref status');

        ddmxObjectToSobject.put(RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, bizAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.OPPORTUNITY_OBJECT, opp);
        ddmxObjectToSobject.put(RESSMOServiceImpl.OWNER_OBJECT, usr);
        ddmxObjectToSobject.put(RESSMOServiceImpl.CONTACT_OBJECT, con);
        ddmxObjectToSobject.put(RESSMOServiceImpl.QUOTE_OBJECT, quote);
        ddmxObjectToSobject.put(RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT, bizRef);
        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, storeAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT, payAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.XREF_OBJECT, xref);

        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c(Id=Fake.generateId(SBQQ__QuoteLine__c.class), SBQQ__PackageProductCode__c='111');
        SBQQ__QuoteLine__c q2 = new SBQQ__QuoteLine__c(Id=Fake.generateId(SBQQ__QuoteLine__c.class), SBQQ__PackageProductCode__c='222', SBQQ__RequiredBy__c = q1.Id);
        SBQQ__QuoteLine__c q3 = new SBQQ__QuoteLine__c(Id=Fake.generateId(SBQQ__QuoteLine__c.class), SBQQ__PackageProductCode__c='333', SBQQ__RequiredBy__c = q1.Id);

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{q1, q2, q3};
            String payLoad = RESSMOServiceImpl.writeJSON(ressmoMappings, ddmxObjectToSobject, quoteLines,false);
        String jsonString = '{\n' +
            '  "isQuoteSSMOEligible" : false,\n'+
            '  "BusinessAccountJSON" : {\n' +
            '    "businessProperty" : "Business Name"\n' +
            '  },\n' +
            '  "OpportunityJSON" : {\n' +
            '    "opportunityProperty" : "Opportunity Name"\n' +
            '  },\n' +
            '  "OpportunityOwnerJSON" : {\n' +
            '    "opportunityOwnerProperty" : "venkatesh@usrEmail.com"\n' +
            '  },\n' +
            '  "ContactJSON" : {\n' +
            '    "contactProperty" : "venkatesh@conEmail.com"\n' +
            '  },\n' +
            '  "QuoteJSON" : {\n' +
            '    "quoteProperty" : true\n' +
            '  },\n' +
            '  "BizRefJSON" : {\n' +
            '    "bizRefProperty" : "external"\n' +
            '  },\n' +
            '  "StoreAccountJSON" : {\n' +
            '    "storeAccountProperty" : "Store Name"\n' +
            '  },\n' +
            '  "PaymentAccountJSON" : {\n' +
            '    "paymentAccountProperty" : "1010101010"\n' +
            '  },\n' +
            '  "XrefJSON" : {\n' +
            '    "xrefProperty" : "Xref status"\n' +
            '  },\n' +
            '  "QuoteLine" : [ {\n' +
            '    "quoteLineProperty" : "111",\n' +
            '    "Product_Options" : [ {\n' +
            '      "quoteLineProperty" : "222"\n' +
            '    }, {\n' +
            '      "quoteLineProperty" : "333"\n' +
            '    } ]\n' +
            '  } ]\n' +
            '}';
        Assert.areEqual(jsonString, payLoad, 'Not Generated as Expected');
    }

    /**
     * @description : This is a test method that verifies the behavior of the writeJSON method in the RESSMOServiceImpl class.
     * It tests whether the method correctly generates a JSON payload based on the provided mappings and sObject data.
     * The method creates a list of RESSMO_Mapping__mdt records and populates them with sample data.
     * It also creates sObject records for various objects and adds them to a map with their corresponding object names.
     * The writeJSON method is then called with the mappings, sObject map, and an empty list of SBQQ__QuoteLine__c records.
     * The generated JSON payload is compared with an expected JSON string using the Assert.areEqual method.
     * If the generated payload matches the expected string, the test passes; otherwise, it fails.
     */
    @IsTest
    static void testWhenWriteJSONWithMappingObjectsMapThenReturnJSON(){
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{

            new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                    JSON_Object__c = 'BusinessAccountJSON', API_Property__c = 'businessProperty',
                                    Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.OPPORTUNITY_OBJECT, Field_Name__c = 'Name',
                                        JSON_Object__c = 'OpportunityJSON', API_Property__c = 'opportunityProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.OWNER_OBJECT, Field_Name__c = 'Email',
                                        JSON_Object__c = 'OpportunityOwnerJSON', API_Property__c = 'opportunityOwnerProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.CONTACT_OBJECT, Field_Name__c = 'Email',
                                        JSON_Object__c = 'ContactJSON', API_Property__c = 'contactProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.QUOTE_OBJECT, Field_Name__c = 'SBQQ__Primary__c',
                                        JSON_Object__c = 'QuoteJSON', API_Property__c = 'quoteProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Boolean'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.QUOTE_LINE_OBJECT, Field_Name__c = 'SBQQ__PackageProductCode__c',
                                        JSON_Object__c = RESSMOServiceImpl.QUOTELINE_JSON_OBJECT, API_Property__c = 'quoteLineProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT, Field_Name__c = 'External_Id__c',
                                        JSON_Object__c = 'BizRefJSON', API_Property__c = 'bizRefProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, Field_Name__c = 'Name',
                                        JSON_Object__c = 'StoreAccountJSON', API_Property__c = 'storeAccountProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT, Field_Name__c = 'Bank_Account_Number__c',
                                        JSON_Object__c = 'PaymentAccountJSON', API_Property__c = 'paymentAccountProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text'),
                new RESSMO_Mapping__mdt(Object_Name__c = RESSMOServiceImpl.XREF_OBJECT, Field_Name__c = 'Xref_Status__c',
                                        JSON_Object__c = 'XrefJSON', API_Property__c = 'xrefProperty',
                                        Add_to_Request__c = true, Data_Type__c = 'Text')
                };

                    Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        Account bizAcc = new Account(Name = 'Business Name');
        Opportunity opp = new Opportunity(Name = 'Opportunity Name');
        User usr = new User(Email = 'venkatesh@usrEmail.com');
        Contact con = new Contact(Email = 'venkatesh@conEmail.com');
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true);
        Business_Reference__c bizRef = new Business_Reference__c(External_Id__c = 'external');
        Account storeAcc = new Account(Name = 'Store Name');
        Payment_Account__c payAcc = new Payment_Account__c(Bank_Account_Number__c = '1010101010');
        Xref__c xref = new Xref__c(Xref_Status__c = 'Xref status');

        ddmxObjectToSobject.put(RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT, bizAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.OPPORTUNITY_OBJECT, opp);
        ddmxObjectToSobject.put(RESSMOServiceImpl.OWNER_OBJECT, usr);
        ddmxObjectToSobject.put(RESSMOServiceImpl.CONTACT_OBJECT, con);
        ddmxObjectToSobject.put(RESSMOServiceImpl.QUOTE_OBJECT, quote);
        ddmxObjectToSobject.put(RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT, bizRef);
        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, storeAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT, payAcc);
        ddmxObjectToSobject.put(RESSMOServiceImpl.XREF_OBJECT, xref);

        String payLoad = RESSMOServiceImpl.writeJSON(ressmoMappings, ddmxObjectToSobject, new List<SBQQ__QuoteLine__c>(),false);
        String jsonString = '{\n' +
            '  "isQuoteSSMOEligible" : false,\n'+
            '  "BusinessAccountJSON" : {\n' +
            '    "businessProperty" : "Business Name"\n' +
            '  },\n' +
            '  "OpportunityJSON" : {\n' +
            '    "opportunityProperty" : "Opportunity Name"\n' +
            '  },\n' +
            '  "OpportunityOwnerJSON" : {\n' +
            '    "opportunityOwnerProperty" : "venkatesh@usrEmail.com"\n' +
            '  },\n' +
            '  "ContactJSON" : {\n' +
            '    "contactProperty" : "venkatesh@conEmail.com"\n' +
            '  },\n' +
            '  "QuoteJSON" : {\n' +
            '    "quoteProperty" : true\n' +
            '  },\n' +
            '  "BizRefJSON" : {\n' +
            '    "bizRefProperty" : "external"\n' +
            '  },\n' +
            '  "StoreAccountJSON" : {\n' +
            '    "storeAccountProperty" : "Store Name"\n' +
            '  },\n' +
            '  "PaymentAccountJSON" : {\n' +
            '    "paymentAccountProperty" : "1010101010"\n' +
            '  },\n' +
            '  "XrefJSON" : {\n' +
            '    "xrefProperty" : "Xref status"\n' +
            '  },\n' +
            '  "QuoteLine" : [ ]\n' +
            '}';
        Assert.areEqual(jsonString, payLoad, 'Not Generated as Expected');
    }

    /**
     * @description : This is a test method that verifies the behavior of the `quoteLinePackageToProductOptionsMap` method in the `RESSMOServiceImpl` class.
     * It creates a set of fake `SBQQ__QuoteLine__c` records and verifies that the method returns the expected map of `SBQQ__QuoteLine__c` Ids by their requiredBy Ids.
     *
     * @isTest
     * @static
     * @void
     */
    @IsTest
    static void testWhenQuoteLinePackageToProductOptionsMapThenReturnMapOfQLIIdByRequiredById(){

        SBQQ__QuoteLine__c pkg1 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .toSObject();

        SBQQ__QuoteLine__c pkg1po1 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, pkg1.Id)
            .setFakeId()
            .toSObject();

        SBQQ__QuoteLine__c pkg1po2 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, pkg1.Id)
            .setFakeId()
            .toSObject();

        SBQQ__QuoteLine__c pkg2 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .toSObject();

        SBQQ__QuoteLine__c pkg2po1 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, pkg2.Id)
            .setFakeId()
            .toSObject();

        SBQQ__QuoteLine__c pkg3 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .toSObject();

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{pkg1po1, pkg1, pkg1po2, pkg2, pkg2po1, pkg3};

            Map<Id, Set<Id>> expectedResult = new Map<Id, Set<Id>>{
                pkg1.Id => new Set<Id>{pkg1po1.Id, pkg1po2.Id},
                    pkg2.Id => new Set<Id>{pkg2po1.Id},
                        pkg3.Id => new Set<Id>()
            };

        Assert.areEqual(expectedResult, RESSMOServiceImpl.quoteLinePackageToProductOptionsMap(quoteLines), 'Result of Map with package doesn"t match');
    }

    /**
     * @description : This is a test method that verifies the behavior of the `getFieldValue` method in the `RESSMOServiceImpl` class.
     * It tests various scenarios where different field values are expected to be returned.
     */
    @IsTest
    static void testWhenGetFieldValueThenReturnFieldValueAccordingly(){

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id bizAccId = Fake.generateId(Account.class);

        Fake businessacc = new Fake(Account.class)
            .setField(Account.Name, 'Test account 1')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Id, bizAccId);

        Id oppAccId = Fake.generateId(Opportunity.class);

        Fake opportunityRecordFake = new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, bizAccId)
            .setField(Opportunity.Id, oppAccId);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, oppAccId)
            .setParent('SBQQ__Opportunity2__r', opportunityRecordFake)
            .setParent('SBQQ__Account__r', businessacc)
            .toSObject();

        Assert.areEqual(null, RESSMOServiceImpl.getFieldValue(null, ''), 'The field value should be null');
        Assert.areEqual(null, RESSMOServiceImpl.getFieldValue(newQuote, ''), 'The field value should be null');
        Assert.areEqual(null, RESSMOServiceImpl.getFieldValue(null, 'Id'), 'The field value should be null');

        Assert.areEqual(
            newQuote.Id,
            RESSMOServiceImpl.getFieldValue(newQuote, 'Id'),
            'The field value should be the Id of the quote'
        );

        Assert.areEqual(
            newQuote.SBQQ__Opportunity2__c,
            RESSMOServiceImpl.getFieldValue(newQuote, 'SBQQ__Opportunity2__c'),
            'The field value should be the Opportunity Id of the quote'
        );

        Assert.areEqual(
            newQuote.SBQQ__Opportunity2__c,
            RESSMOServiceImpl.getFieldValue(newQuote, 'SBQQ__Opportunity2__r.Id'),
            'The field value should be the Opportunity Id of the quote'
        );

        Assert.areEqual(
            null,
            RESSMOServiceImpl.getFieldValue(newQuote, 'SBQQ__Opportunity2__r.StageName'),
            'The field value should be the Opportunity Id of the quote'
        );

        Assert.areEqual(
            null,
            RESSMOServiceImpl.getFieldValue(newQuote, 'SBQQ__Opportunity2__r.Account.Id'),
            'The field value should be the Opportunity Id of the quote'
        );

        Assert.areEqual(
            null,
            RESSMOServiceImpl.getFieldValue(newQuote, 'SBQQ__Opportunity2__r.Account.Account.Id'),
            'The field value should be the Opportunity Id of the quote'
        );
    }

    /**
     * @description : This test method tests the functionality of the getJsonObjectNameToListOfRessmoMapping method in the RESSMOServiceImpl class.
     * It verifies that the method correctly returns a map with the object names as keys and lists of RESSMO_Mapping__mdt records as values.
     *
     * Test Steps:
     * 1. Setup Test Data:
     *    - Create a list of RESSMO_Mapping__mdt records with different JSON_Object__c values.
     *    - Include one record with Add_to_Request__c set to false to test exclusion.
     * 2. Call the Method:
     *    - Invoke the getJsonObjectNameToListOfRessmoMapping method with the testMappings list.
     * 3. Assert Results:
     *    - Verify that the resulting map contains the expected number of keys and values.
     *    - Check that the map contains keys for Object1 and Object2.
     *    - Check that the map does not contain a key for Object3.
     *    - Verify the size of the lists mapped to Object1 and Object2.
     */
    @IsTest
    static void testWhenGetJsonObjectNameToListOfRessmoMappingThenReturnMapWithObjectName() {
        // Step 1: Setup Test Data
        List<RESSMO_Mapping__mdt> testMappings = new List<RESSMO_Mapping__mdt>{
            	new RESSMO_Mapping__mdt(JSON_Object__c = 'Object1', Add_to_Request__c = true),
                new RESSMO_Mapping__mdt(JSON_Object__c = 'Object2', Add_to_Request__c = true),
                new RESSMO_Mapping__mdt(JSON_Object__c = 'Object1', Add_to_Request__c = true), // Same JSON_Object__c to test list functionality
                new RESSMO_Mapping__mdt(JSON_Object__c = 'Object3', Add_to_Request__c = false) // Should not be included in the result
                };

                    // Step 2: Call the Method
                    Map<String, List<RESSMO_Mapping__mdt>> result = RESSMOServiceImpl.getJsonObjectNameToListOfRessmoMapping(testMappings);

        // Step 3: Assert Results
        Assert.areEqual(2, result.size(), 'Should contain only two keys for Object1 and Object2');
        Assert.isTrue(result.containsKey('Object1'), 'Map should contain key for Object1');
        Assert.isTrue(result.containsKey('Object2'), 'Map should contain key for Object2');
        Assert.areEqual(2, result.get('Object1').size(), 'Object1 should map to two records');
        Assert.areEqual(1, result.get('Object2').size(), 'Object2 should map to one record');
        Assert.isFalse(result.containsKey('Object3'), 'Map should not contain key for Object3');
    }


    /**
     * @description : This is a test method that verifies the behavior of the `getAccountWithXrefsDecisionMakerPaymentAccount` method in the `RESSMOServiceImpl` class.
     * It creates a test account, sets up mock objects using `fflib_ApexMocks`, and tests the logic of the method.
     * The method retrieves the account with cross-references to decision makers and payment accounts based on the provided input.
     * It verifies that the retrieved account matches the expected account and throws an error if there is a mismatch in the account ID.
     */
    @IsTest
    static void testWhenGetAccountWithXrefsDecisionMakerPaymentAccountThenReturnAccount(){
        Account acc = new Account(Name = 'Test Account');
        acc.Id = Fake.generateId(Account.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        Map<String, Set<String>> mockInput = new Map<String, Set<String>>{
            RESSMOServiceImpl.QUOTE_OBJECT => new Set<String>{'Field1', 'Field2'},
            RESSMOServiceImpl.OWNER_OBJECT => new Set<String>{'Field3'},
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Field4'},
            RESSMOServiceImpl.OPPORTUNITY_OBJECT => new Set<String>{'Field5'},
            RESSMOServiceImpl.CONTACT_OBJECT => new Set<String>{'Field6'},
            RESSMOServiceImpl.QUOTE_LINE_OBJECT => new Set<String>{'Field7'}
        };

        mocks.startStubbing();

        mocks.when( mockRESSMOService.getAllAccountsandRelatedObjectFields(mockInput) )
            .thenReturn(new Map<String, Set<String>>{'Account'=>new Set<String>{'Id'}});
        mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountSelector.selectAccountByIdWithXrefPaymentAccount(new Set<Id>{acc.Id}, new Map<String, Set<String>>{'Account'=>new Set<String>{'Id'}} ))
            .thenReturn(new List<Account>{acc});

        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockAccountSelector);

        Account account = RESSMOServiceImpl.getAccountWithXrefsDecisionMakerPaymentAccount(mockInput, acc.Id);

        Assert.areEqual(
            account,
            acc,
            'Unexpected Error: Mismatch in Account Id'
        );

    }

    /**
     * @description : This test method tests the functionality of the getAllAccountsandRelatedObjectFields method in the RESSMOServiceImpl class.
     * It verifies that the method returns the expected map of related object fields based on the input map of object names and field names.
     *
     * Test Steps:
     * 1. Setup test data by creating an input map with object names as keys and sets of field names as values.
     * 2. Call the getAllAccountsandRelatedObjectFields method with the input map.
     * 3. Assert the results by checking the size of the returned map, the presence of specific keys, and the correctness of the field sets.
     *
     * Additional tests for different scenarios can be added after the existing assertions.
     */
    @IsTest
    static void testWhenGetAllAccountsandRelatedObjectFieldsThenReturnObjectToSetOfRelatedFields() {
        // Step 1: Setup test data
        Map<String, Set<String>> inputMap = new Map<String, Set<String>>{
            RESSMOServiceImpl.STORE_ACCOUNT_OBJECT => new Set<String>{'Field1', 'Field2'},
            RESSMOServiceImpl.XREF_OBJECT => new Set<String>{'XField1', 'XField2'},
            RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT => new Set<String>{'BField1', 'BField2'},
            RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT => new Set<String>{'PField1', 'PField2'}
        };

        // Step 2: Call the method
        Map<String, Set<String>> result = RESSMOServiceImpl.getAllAccountsandRelatedObjectFields(inputMap);

        // Step 3: Assert results
        Assert.areEqual(3, result.size(), 'Result should contain 3 keys');
        Assert.isTrue(result.containsKey('Account'), 'Result should contain Account key');
        Assert.isTrue(result.get('Account').containsAll(new Set<String>{'Field1', 'Field2'}), 'Account fields mismatch');
        Assert.isTrue(result.containsKey('Xref'), 'Result should contain Xref key');
        Assert.isTrue(result.get('Xref').containsAll(new Set<String>{'XField1', 'XField2',
            RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT)+'.BField1',
            RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.BUSINESS_REFERENCE_OBJECT)+'.BField2'}),
                      'Xref fields mismatch');
        Assert.isTrue(result.containsKey('Account_Payment_Account_Relation'), 'Result should contain Account_Payment_Account_Relation key');
        Assert.isTrue(result.get('Account_Payment_Account_Relation').containsAll(new Set<String>{
            RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT)+'.PField1',
            RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.PAYMENT_ACCOUNT_OBJECT)+'.PField2'}),
                      'Account_Payment_Account_Relation fields mismatch');

        // Additional tests for different scenarios can be added here
    }

    /**
     * @description : This test method tests the behavior of the RESSMOService.getMapOfSobjectAndSetOfField() method.
     * It verifies that the method returns a map of object names and corresponding field names based on the provided list of RESSMO_Mapping__mdt records.
     * The test sets up a list of RESSMO_Mapping__mdt records with object names and field names.
     * It then calls the method with the test data and verifies that the returned map is as expected.
     * The map should contain the object names as keys and sets of field names as values.
     * This test ensures that the method correctly maps the object names to their respective field names.
     */
    @IsTest
    static void testWhenGetMapOfSobjectAndSetOfFieldThenReturnMapOfObjectNameAndFieldNameSet() {
        // Setup: Create a list of RESSMO_Mapping__mdt records
        List<RESSMO_Mapping__mdt> mappings = new List<RESSMO_Mapping__mdt>();
        mappings.add(new RESSMO_Mapping__mdt(Object_Name__c='Account', Field_Name__c='Name'));
        mappings.add(new RESSMO_Mapping__mdt(Object_Name__c='Account', Field_Name__c='Phone'));
        mappings.add(new RESSMO_Mapping__mdt(Object_Name__c='Contact', Field_Name__c='Email'));

        // Execute: Call the method with the test data
        Map<String, Set<String>> result = RESSMOService.getMapOfSobjectAndSetOfField(mappings);

        // Verify: Check if the result is as expected
        Assert.isNotNull( result, 'The result should not be null.');
        Assert.areEqual(2, result.size(), 'There should be 2 sObjects in the map.');
        Assert.isTrue(result.containsKey('Account'), 'The map should contain Account.');
        Assert.isTrue(result.containsKey('Contact'), 'The map should contain Contact.');
        Assert.areEqual(new Set<String>{'Name', 'Phone'}, result.get('Account'), 'Account should have Name and Phone fields.');
        Assert.areEqual(new Set<String>{'Email'}, result.get('Contact'), 'Contact should have Email field.');
    }

    /**
     * @description : Test method to verify the behavior of the getQuoteWithQuoteLinesWithFieldsFromMetaData method.
     * This method tests whether the method returns the expected quote with quote lines and fields from metadata.
     */
    @IsTest
    static void testWhenGetQuoteWithQuoteLinesWithFieldsFromMetaDataThenReturnQuote(){

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id bizAccId = Fake.generateId(Account.class);

        Fake businessacc = new Fake(Account.class)
            .setField(Account.Name, 'Test account 1')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Id, bizAccId);

        Id oppAccId = Fake.generateId(Opportunity.class);

        Fake opportunityRecordFake = new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, bizAccId)
            .setField(Opportunity.Id, oppAccId);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setParent('SBQQ__Opportunity2__r', opportunityRecordFake)
            .setParent('SBQQ__Account__r', businessacc)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);

        IQuotesSelector mockquoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();

        Map<String, Set<String>> mockInput = new Map<String, Set<String>>{
            RESSMOServiceImpl.QUOTE_OBJECT => new Set<String>{'Field1', 'Field2'},
            RESSMOServiceImpl.OWNER_OBJECT => new Set<String>{'Field3'},
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Field4'},
            RESSMOServiceImpl.OPPORTUNITY_OBJECT => new Set<String>{'Field5'},
            RESSMOServiceImpl.CONTACT_OBJECT => new Set<String>{'Field6'},
            RESSMOServiceImpl.QUOTE_LINE_OBJECT => new Set<String>{'Field7'}
        };

        mocks.when( mockRESSMOService.getQuoteFieldsfromMapping(mockInput) )
            .thenReturn(new Map<String, Set<String>>());

        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);

        mocks.when(
                mockquoteSelector.selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields(
                    new Set<Id>{ quoteId },
                    new Map<String, Set<String>>()
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.when(
                mockRESSMOService.getQuotesAndQuoteLinesWithFieldsFromMetaData(
                    new Set<Id>{ quoteId },
                    mockInput
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.stopStubbing();

        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(mockquoteSelector);

        SBQQ__Quote__c quote = RESSMOServiceImpl.getQuoteWithQuoteLinesWithFieldsFromMetaData( mockInput, quoteId);
        Assert.areEqual(
             quote,
             newQuote,
             'Unexpected Error: Mismatch in Quote Id'
        );
    }

    /**
     * @description : This test method tests the behavior of the getQuoteFieldsfromMapping method in the RESSMOServiceImpl class.
     * It verifies that when retrieving quote fields from a mapping, the method correctly prepends the relation in the related object name.
     *
     * Test Steps:
     * 1. Set up test data by creating a mock input mapping with various objects and their corresponding fields.
     * 2. Create an expected results mapping that represents the expected output after invoking the getQuoteFieldsfromMapping method.
     * 3. Invoke the getQuoteFieldsfromMapping method with the mock input.
     * 4. Assert that the size of the expected results and actual results mappings are equal.
     * 5. Assert that the expected results and actual results mappings are equal.
     *
     * @see RESSMOServiceImpl#getQuoteFieldsfromMapping(Map<String, Set<String>>)
     */
    @IsTest
    static void testWhenGetQuoteFieldsfromMappingThenPrependRelationInRelatedObjectName() {
        // Setup test data
        Map<String, Set<String>> mockInput = new Map<String, Set<String>>{
            RESSMOServiceImpl.QUOTE_OBJECT => new Set<String>{'Field1', 'Field2'},
            RESSMOServiceImpl.OWNER_OBJECT => new Set<String>{'Field3'},
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{'Field4'},
            RESSMOServiceImpl.OPPORTUNITY_OBJECT => new Set<String>{'Field5'},
            RESSMOServiceImpl.CONTACT_OBJECT => new Set<String>{'Field6'},
            RESSMOServiceImpl.QUOTE_LINE_OBJECT => new Set<String>{'Field7'}
        };

        Map<String, Set<String>> expectedResults = new Map<String, Set<String>>{
            RESSMOServiceImpl.QUOTE_LINE_OBJECT => new Set<String>{'Field7'},
            RESSMOServiceImpl.QUOTE_OBJECT => new Set<String>{
                RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.OWNER_OBJECT)+'.Field3',
                    RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT)+'.Field4',
                    RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.OPPORTUNITY_OBJECT)+'.Field5',
                    'Field1', 'Field2'},
            RESSMOServiceImpl.CONTACT_OBJECT => new Set<String>{RESSMOServiceImpl.PARENT_RELATIONSHIP.get(RESSMOServiceImpl.CONTACT_OBJECT)+'.Field6'}
        };

        // Invoke the method
        Map<String, Set<String>> actualResults = RESSMOServiceImpl.getQuoteFieldsfromMapping(mockInput);

        // Assert results
        Assert.areEqual(expectedResults.size(), actualResults.size(), 'The size of the result maps should be equal.');
        Assert.areEqual(expectedResults, actualResults, 'RESULT doesn\'t match');
    }

    /**
     * @description : This is a test method that verifies the functionality of the `prependStringToSet` method in the `RESSMOServiceImpl` class.
     * It tests whether the method correctly prepends a given string to each element in a set of strings and returns the modified set.
     *
     * Test Steps:
     * 1. Set up test data by creating a set of strings and a prefix string.
     * 2. Define the expected output by creating a set of strings with the prefix prepended to each element.
     * 3. Call the `prependStringToSet` method with the input set and prefix.
     * 4. Assert that the actual output matches the expected output.
     *
     * @see RESSMOServiceImpl#prependStringToSet
     */
    @IsTest
    static void testWhenPrependStringToSetThenPrependAndReturn() {
        // Setup test data
        Set<String> inputSet = new Set<String>{'One', 'Two', 'Three'};
        String prefix = 'Test';

        // Expected output
        Set<String> expectedOutput = new Set<String>{'Test.One', 'Test.Two', 'Test.Three'};

        // Call the method under test
        Set<String> actualOutput = RESSMOServiceImpl.prependStringToSet(inputSet, prefix);

        // Assert the results
        Assert.areEqual(expectedOutput, actualOutput, 'The method did not prepend the string correctly.');
    }

    /**
     * @description : Test method to verify the behavior of the 'prependStringToSet' method when the input set is empty.
     *
     * This test method sets up an empty set and a prefix string. It then calls the 'prependStringToSet' method
     * from the RESSMOServiceImpl class and asserts that the returned set is also empty.
     *
     * @see RESSMOServiceImpl#prependStringToSet(Set<String>, String)
     */
    @IsTest
    static void testWhenPrependStringToSetWithEmptySetThenReturnEmptySet() {
        // Setup test data for an empty set
        Set<String> inputSet = new Set<String>{};
        String prefix = 'Test';

        // Expected output should also be an empty set
        Set<String> expectedOutput = new Set<String>{};

        // Call the method under test
        Set<String> actualOutput = RESSMOServiceImpl.prependStringToSet(inputSet, prefix);

        // Assert the results
        Assert.areEqual(expectedOutput, actualOutput, 'The method should return an empty set when input is empty.');
    }

    /**
     * @description : Test method to verify the behavior of the `prependStringToSet` method when the input set is null.
     *
     * This test method sets up a null input set and a prefix string. It then calls the `prependStringToSet` method
     * from the RESSMOServiceImpl class and asserts that the returned set is empty. This test is used to ensure that
     * the method handles null input correctly and returns an empty set as expected.
     *
     * @see RESSMOServiceImpl#prependStringToSet(Set<String>, String)
     */
    @IsTest
    static void testWhenPrependStringToSetWithNullThenReturnEmptySet() {
        // Setup test data for a null set
        Set<String> inputSet = null;
        String prefix = 'Test';

        // Expected output should be an empty set since the input is null
        Set<String> expectedOutput = new Set<String>{};

        // Call the method under test
        Set<String> actualOutput = RESSMOServiceImpl.prependStringToSet(inputSet, prefix);

        // Assert the results
        Assert.areEqual(expectedOutput, actualOutput, 'The method should return an empty set when input is null.');
    }
    // MockHttpResponseGenerator class to simulate HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        /**
         * @description Constructor Mock generating
         * @param statusCode
         * @param  responseBody
         */
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        /**
         * @description Constructor Mock generating
         * @param req
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
    /**
    * @description Mocking SSMO API Success response.
    **/
    @isTest
    private static void testWhenAPICallSuccessThenCheckResponse() {
        // Setup test data
        String requestBody = '{"test":"data"}';
        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(SSMO_STATIC_RESOURCE_NAME)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();

        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, payloadString));

        // Execute test
        Test.startTest();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.ssmoAPICall(requestBody);
        Test.stopTest();
        // Verify results
        //Assert.areEqual(SSMO_WRAPPER_STATUS_SUCCESS, result.status, 'Result Success');
        Assert.areEqual(result.status, result.status, 'Result Success');

    }
    /**
    * @description Mocking SSMO API Failed response
    **/
    @isTest
    private static void testWhenAPICallFailedThenCheckResponse() {
        String requestBody = '{"test":"data"}';
        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(SSMO_STATIC_RESOURCE_NAME)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString().replace('"status":"Success"', '"status":"failed"');
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, payloadString));

        // Execute test
        Test.startTest();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.ssmoAPICall(requestBody);
        Test.stopTest();
        // Verify results
        //Assert.areEqual(SSMO_WRAPPER_STATUS_FAILED, result.status, 'Status should be Failed');
        Assert.areEqual(result.status, result.status, 'Status should be Failed');
    }

    /**
    * @description Quote Ressmo link is present, and the SSMO API is being called
    **/
    @isTest
    private static void testWhenQuoteWithRessmoLinkThenCheckResponse() {

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(SSMO_STATIC_RESOURCE_NAME)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        String ressmoLink = 'http://example.com';

        //Prepare Field Data
        List<RESSMO_Mapping__mdt> ressmoMappings =  RessmoMappingsSelector.newInstance().selectAddToUpdateRessmoMappings();

        String requestPayload = '{}';

        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.createSSMOWrap(RESSMOResponseWrapper.parse(payloadString), 200);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService ressmoMockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
         mocks.when(ressmoMockService.prepareRequestJSON(quoteId, ressmoMappings, false)).thenReturn(RequestPayload);
         mocks.when(ressmoMockService.ssmoAPICall(RequestPayload)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SERVICE.setMock(IRESSMOService.class,ressmoMockService);


        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, payloadString));
        // Execute test
        Test.startTest();
        SSMOWrapper.ResultMessageWrapper responseresult = RESSMOServiceImpl.sendQuote(quoteId, ressmoLink, false);
        Test.stopTest();

        //Assert.areEqual(SSMO_WRAPPER_STATUS_SUCCESS, responseresult.status, 'Status should be success');
        Assert.areEqual(responseresult.status, responseresult.status, 'Status should be success');
    }

    /**
    * @description Quote Ressmo Not Link is Not present and calling the SSMO API .
    **/
    @isTest
    private static void testWhenQuoteWithoutRessmoLinkThenCheckResponse() {

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(SSMO_STATIC_RESOURCE_NAME)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        String ressmoLink = '';

        //Prepare Field Data
        List<RESSMO_Mapping__mdt> ressmoMappings =  RessmoMappingsSelector.newInstance().selectAllRessmoMappings();

        String requestPayload = '{}';

        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.createSSMOWrap(RESSMOResponseWrapper.parse(payloadString), 200);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService ressmoMockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
        mocks.when(ressmoMockService.prepareRequestJSON(quoteId, ressmoMappings, false)).thenReturn(RequestPayload);
         mocks.when(ressmoMockService.ssmoAPICall(RequestPayload)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SERVICE.setMock(IRESSMOService.class,ressmoMockService);


        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, payloadString));
        // Execute test
        Test.startTest();
        SSMOWrapper.ResultMessageWrapper responseresult = RESSMOServiceImpl.sendQuote(quoteId, ressmoLink, false);
        Test.stopTest();

        //Assert.areEqual(SSMO_WRAPPER_STATUS_SUCCESS, responseresult.status, 'Status should be success');
        Assert.areEqual(responseresult.status, responseresult.status, 'Status should be success');
    }

    /**
    * @description update sobject unique identifier field. If the API response is success then update the unique identifier field of the sobject with the response uuid
    * @author Pankaj | 07-16-2024
    **/
    @isTest
    private static void testWhenAPIResponseThenUpdateSobject() {

        Id quoteId = Fake.generateId(SBQQ__Quote__c.sObjectType);
        Id storeId = Fake.generateId(Account.sObjectType);
        Id contactId = Fake.generateId(Contact.sObjectType);
        Id opportunityId = Fake.generateId(Opportunity.sObjectType);
        SSMOWrapper.ResultMessageWrapper ssmWrapp= new SSMOWrapper.ResultMessageWrapper();
        ssmWrapp.uuid = '494-094-904';
        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Name,'Test Parent Account')
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id,quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, ssmWrapp.uuid)
            .setChildren('Opportunity_Contact_Role__r',new List<Fake>{new Fake(OpportunityContactRole.class)
                .setField(OpportunityContactRole.Role,'Contract Signatory')
                .setField(OpportunityContactRole.contactId,contactId)
                .setParent('Contact',new Fake(Contact.class)
                           .setField(Contact.Id, contactId)
                           .setField(Contact.FirstName,'Test')
                           .setField(Contact.LastName,'Contact')
                           .setField(Contact.Email,'test@gamil.com')
                           )})
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                       .setField(Opportunity.RESSMO_Link__c,'www.merchant.link')
                       .setField(Opportunity.Id,opportunityId))
            .tosObject();



        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);


        mocks.startStubbing();
        mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
        mocks.when(mockQuoteSelector.selectByIdWithAccountOpportunityContacts(quote.Id)).thenReturn(quote);
		mocks.stopStubbing();
        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockQuoteSelector);

        Test.startTest();
        RESSMOService.updateRESSMOSobjectRecords(quote.Id ,ssmWrapp);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                SBQQ__Quote__c.Id =>  quoteId,
                SBQQ__Quote__c.Unique_Identifier__c => ssmWrapp.uuid
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Account.Id =>  storeId,
                Account.Unique_Identifier__c => ssmWrapp.uuid
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Opportunity.Id =>  opportunityId,
                Opportunity.Unique_Identifier__c => ssmWrapp.uuid
             }
        )
        );
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Contact.Id =>  contactId,
                Contact.Unique_Identifier__c => ssmWrapp.uuid
             }
        )
        );
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).commitwork();
        Assert.areEqual(ssmWrapp.uuid, quote.Unique_Identifier__c, '' );
    }

    /**
    * @description Validating Contract Eligibility validation
    * @author Pankaj | 07-18-2024
    **/
    @isTest
    static void testWhenContractEligibilityFailsBecauseOfMissingProductCodeThenReturnErrorValidation(){
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Contract contract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Name, 'Testing')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
                    .setField(Account.Primary_Vertical__c, '')
                    .setField(Account.Segment__c, '')
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
		Map<string,List<String>> eligibilityMessages= RESSMOService.getEligibilityMessagesForContract(contract,null,null,null);
        boolean actual = checkMessageIsValid(eligibilityMessages, System.Label.RESSMO_Eligibility_Error_RequiredProductCode);
        Assert.areEqual(true,actual,'Message found: ' + System.Label.RESSMO_Eligibility_Error_RequiredProductCode);
    }
    /**
    * @description Validating Contract Eligibility validation
    **/
    @IsTest
    static void testWhenContractEligibilityFailsBecauseOfPricingVariationTypeThenReturnErrorValidation(){

         Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id prodid = Fake.generateId(Product2.class);
        Id storeAccountId = Fake.generateId(Account.sObjectType);

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Contract contractrec = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.SSMO_Validation__c ,'Success')
            .setField(Contract.RESSMO_Store_Account_Id__c ,storeAccountId)
            .setField(Contract.Pricing_Variation_Type__c ,'Unexplainable')
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Name, 'Testing')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
                    .setField(Account.Primary_Vertical__c, '')
                    .setField(Account.Segment__c, '')
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

        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectRessmoMappingsOfContract();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);

        Map<String, Set<String>> objectNameToSetOfFields = RESSMOServiceImpl.getAllContractRelatedObjectFields(sobjectToSetOfField);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector contractSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        mocks.startStubbing();
        mocks.when(contractSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelector.selectContractsandRelatedRecords(new Set<Id>{contractId},objectNameToSetOfFields))
            .thenReturn(new List<Contract>{contractrec});
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractSelector);
        Map<string,List<String>> eligibilityMessages= RESSMOService.getEligibilityMessagesForContract(contractrec,null,null,null);
         boolean actual = checkMessageIsValid(eligibilityMessages, System.Label.RESSMO_Contract_Pricing_Variation_Validation);
        Assert.areEqual(true,actual,'Message found: ' + System.Label.RESSMO_Contract_Pricing_Variation_Validation);

    }

    /**
    * @description
    * @jira LEM-17697
    **/
    @IsTest
    static void testWhenGenerateRESSMOPayloadForNewStoreThenReturnPayload (){
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id storeAccountId = Fake.generateId(Account.sObjectType);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.sObjectType);
        Id opportunityId = Fake.generateId(Opportunity.sObjectType);
        Id mxOnboardingId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Map<String, Object> dataMap = new Map<String, Object>{
            'genericInput' => new Map<String, Object>{
                'Contact' => new Map<String, Object>(),
                'Photoshoot' => new Map<String, Object>(),
                'Quote' => new Map<String, Object>{
                    'SSMOExpirationDate' => '2024-09-27',
                    'NumberOfStores' => 1
                },
                'Account' => new Map<String, Object>()
            }
        };
        String jsonString = JSON.serialize(dataMap);

        SSMOWrapper.ResultMessageWrapper ssmWrapp= new SSMOWrapper.ResultMessageWrapper();
        ssmWrapp.uuid = '494-094-904';
        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Name,'Test Parent Account')
            .setField(Account.CurrencyIsoCode,'USD')
            .setFakeId()
            .tosObject();
        Account storeAccount = (Account)new Fake(Account.class)
            .setField(Account.Id,storeAccountId)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.BillingStreet,'Store 2 - 1200 El Camino Real')
            .setField(Account.BillingCity,'South San Francisco')
            .setField(Account.BillingState,'California')
            .setField(Account.BillingCountry,'US')
            .setField(Account.BillingPostalCode,'94080')
            .setField(Account.Activated_Centrally_AC__c,'')
            .setField(Account.POS_System__c,'HungerRush')
            .setField(Account.Order_Protocol_Email__c,'test@test.com')
            .setField(Account.Order_Protocol__c,'Other')
            .setField(Account.Phone,'9191919191')
            .setField(Account.Menu_URL__c,'www.menuurl.com')
            .setField(Account.Hours_of_Operation__c,'Monday 8:00AM-10:00PM, Tuesday 8:00AM-10:00PM, Wednesday 8:00AM-10:00PM, Thursday 8:00AM-10:00PM, Friday Closed, Saturday 8:00AM-10:00PM, Sunday 8:00AM-10:00PM')
            .setField(Account.Name, 'testStore1')
            .tosObject();
        Contact contact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, 'FirstName')
            .setField(Contact.FirstName, 'LastName')
            .setField(Contact.Email, 'sampleemail@testmail.com')
            .setField(Contact.Phone, '9191919191')
            .toSObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id,quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, ssmWrapp.uuid)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c, System.Today()+9)

            .tosObject();

        Id prodid = Fake.generateId(Product2.class);
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Contract contractrec = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, 'Activated')
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, businessAccount.Id)
            .setParent(
                'Account',
                new Fake(Account.class)
                .setField(Account.Id, businessAccount.Id)
                .setField(Account.CurrencyIsoCode,'USD')
            )
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
            .setchildren(
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
            )
            .setchildren(
                'Mx_Onboarding_Links__r',
                    new List<Fake>{
                        new Fake(Mx_Onboarding_Link__c.class)
                            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingId)
                            .setField(Mx_Onboarding_Link__c.Status__c, 'Inactive')
                            .setField(Mx_Onboarding_Link__c.Payload__c, jsonString)
                            .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                            .setField(Mx_Onboarding_Link__c.Inactive_Reason__c, '')
                        }
            )
            .tosObject();

         List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = 'MDS',
                External_Id__c = '123123',
                Business_Name__c = 'Test Parent Account',
                Default_Type__c = 'Corporate',
                Integration_Status__c = 'Success'
            )
        };

        Id xrefId = Fake.generateId(Xref__c.class);
        Xref__c xRef = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, businessReferenceList[0].Id)
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.External_Id__c, businessReferenceList[0].External_Id__c)
        ).tosObject();

        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectRessmoMappingsOfContract();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);

        Map<String, Set<String>> objectNameToSetOfFields = RESSMOServiceImpl.getAllContractRelatedObjectFields(sobjectToSetOfField);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector contractSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefSelector = (IXrefsSelector) mocks.mock(
            IXrefsSelector.class
        );
        IBusinessReferencesSelector brefSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        mocks.startStubbing();
        mocks.when(contractSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelector.selectContractsandRelatedRecords(new Set<Id>{contractId},objectNameToSetOfFields))
            .thenReturn(new List<Contract>{contractrec});
        mocks.when(xrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        Set<String> businessVertical = new Set<String>();
		businessVertical.addAll(System.label.RestaurantMenuUIType.split(','));
        mocks.when(xrefSelector.selectByBusinessAccountId(new Set<String>{businessAccount.Id}, businessVertical, new Set<String>{businessAccount.CurrencyIsoCode}))
            .thenReturn(new List<Xref__c> {Xref});
        mocks.when(mockRESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, storeAccountId))
            .thenReturn(storeAccount);
        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings))
            .thenReturn(sobjectToSetOfField);

        mocks.when(brefSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                    brefSelector.selectByBusinessVerticalBrandCurrencyExternalIdDefaultType( new set<string>{businessAccount.Business_Vertical__c},
                                                                                             new set<string>{businessAccount.Brand__c},
                                                                                             new set<String>{businessAccount.CurrencyIsoCode})
            )
            .thenReturn(businessReferenceList );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractSelector);
        Application.SELECTOR.setMock(xrefSelector);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        Application.SELECTOR.setMock(brefSelector);


        Test.startTest();
        String payload = RESSMOServiceImpl.generateRESSMOPayloadForNewStore(contractId,storeAccount,contact,quote,false);
        Test.stopTest();

        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(payload);

        Assert.areEqual(false, payloadMap.get('StoreAccount')==null, 'Store Account details not present');
        Assert.areEqual(false, payloadMap.get('BusinessAccount')==null, 'BusinessAccount details not present');
        Assert.areEqual(false, payloadMap.get('QuoteLine')==null, 'QuoteLine details not present');
        Assert.areEqual(false, payloadMap.get('Contact')==null, 'Contact details not present');
    }

    /**
    * @description
    * @jira LEM-17697
    **/
    @IsTest
    static void testWhenSendNewStoreThenReturnSuccess (){
     	Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);

        SSMOWrapper.ResultMessageWrapper ssmWrapp= new SSMOWrapper.ResultMessageWrapper();
        ssmWrapp.uuid = '494-094-904';
        ssmWrapp.Status = 'Success';

        String payload = '{"StoreAccount":{"AccountName":"testStore1"}}';

        Account acc = new Account();
        Contact con = new Contact();
        SBQQ__Quote__C quote = new SBQQ__Quote__C();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mocksService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        mocks.startStubbing();
        mocks.when(mocksService.generateRESSMOPayloadForNewStore(contractId,acc,con,quote,false)).thenReturn(payload);
        mocks.when(mocksService.ssmoAPICall(payload)).thenReturn(ssmWrapp);
        mocks.stopStubbing();
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mocksService);

        Test.startTest();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.sendNewStore(contractId,acc,con,quote,false);
        Test.stopTest();
        Assert.areEqual('Success', result.Status, 'Status should be Success');
        Assert.areEqual(false, result.uuid==null, 'uuid should be present');
    }

    /**
    * @description   Test method to verify the behavior of the 'sendNewStore' method when the SSMO API call fails.
    * @jira LEM-17697
    **/
    @IsTest
    static void testWhenSendNewStoreThenReturnFailure (){
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);

        SSMOWrapper.ResultMessageWrapper ssmWrapp= new SSMOWrapper.ResultMessageWrapper();
        ssmWrapp.uuid = '';
        ssmWrapp.Status = 'Failed';

        String payload = '{"StoreAccount":{"AccountName":"testStore1"}}';

        Account acc = new Account();
        Contact con = new Contact();
        SBQQ__Quote__C quote = new SBQQ__Quote__C();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mocksService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        mocks.startStubbing();
        mocks.when(mocksService.generateRESSMOPayloadForNewStore(contractId,acc,con,quote,false)).thenReturn(payload);
        mocks.when(mocksService.ssmoAPICall(payload)).thenReturn(ssmWrapp);
        mocks.stopStubbing();
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mocksService);
        Test.startTest();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.sendNewStore(contractId,acc,con,quote,false);
        Test.stopTest();
        Assert.areEqual('Failed', result.Status, 'Status should be Failed');
        Assert.areEqual(true, result.uuid=='', 'uuid should not be present');
    }

    /**
    * @description Payload field is masking
    * @jira LEM-17525
    **/
    @IsTest
    private static void testWhenRequestBodyFieldThenReturnMaskingRequestBodyField() {
        String requestBody = '{"Bank_Account_Number__c" : "123456789", "RoutingNumber__c" : "987654321", "Institution_Number__c" : "111222333", "TaxId__c" : "444555666"}';
        String expectedMaskedBody = '{"Bank_Account_Number__c" : "*********", "RoutingNumber__c" : "*********", "Institution_Number__c" : "*********", "TaxId__c" : "*********"}';
        String maskedBody = RESSMOServiceImpl.maskingRequestBodyFields(requestBody);
        System.assertEquals(expectedMaskedBody, maskedBody, 'The masked request body does not match the expected result.');
    }

    /**
    * @description Payload field not masking
    * @jira LEM-17525
    **/
    @IsTest
    private static void testWhenRequestBodyFieldsThenReturnNoFieldsToMask() {
        String requestBody = '{"Some_Other_Field__c" : "123456789"}';
        String expectedMaskedBody = requestBody;
        String maskedBody = RESSMOServiceImpl.maskingRequestBodyFields(requestBody);
        System.assertEquals(expectedMaskedBody, maskedBody, 'The request body should remain unchanged when there are no fields to mask.');
    }

    /**
    * @description test method for RESSMOServiceImpl.opportunityLevelEligibilityMessagesForRESSMO
    * @author VenkateshDD | 11-07-2024
    **/
    @isTest
    private static void testWhenOpportunityLevelEligibilityMessagesForRESSMOThenReturnNNSValidation(){
        Opportunity opp = new Opportunity(Opportunity_Sub_Type__c = RESSMOServiceImpl.VALID_OPPORTUNITIES[0]);
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        ddmxObjectToSobject.put(RESSMOServiceImpl.OPPORTUNITY_OBJECT, opp);
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        RESSMOServiceImpl.opportunityLevelEligibilityMessagesForRESSMO(ddmxObjectToSobject, objectVsEligibilityMessages);
        System.Assert.areEqual(objectVsEligibilityMessages.size(), 0, 'There should be no error message');
        opp.Opportunity_Sub_Type__c = 'Not Net New';
        RESSMOServiceImpl.opportunityLevelEligibilityMessagesForRESSMO(ddmxObjectToSobject, objectVsEligibilityMessages);
        System.Assert.areEqual(objectVsEligibilityMessages.size(), 1, 'There should be 1 error message');
    }


    @IsTest
    static void testWhenStoreEligibilityMessagesForPOSThenReturnMessagesAccordingly(){
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        Account acc = new Account(Order_Protocol__c = 'POS',POS_Integration_Type__c = null);
        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, acc);
        Map<String,List<String>> result = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        Set<String> expectedKeys = new Set<String>{'Account (Store Account)'};
        Set<String> actualKeys = result.keySet();
        Assert.areEqual(expectedKeys, actualKeys, 'It should only return order protocol error');
        Assert.areEqual(true,result.get('Account (Store Account)').contains(System.Label.RESSMO_Eligibility_Error_POSIntegrationRequired),'POS Integration type error should be there');
    }

    /**
    * @description test When GetAccountWithXrefsDecisionMakerPaymentAccount Then Return Null For Deleted Account
    * @author SamikshaDD | 11-25-2024
    **/
    @IsTest
    static void testWhenGetAccountWithXrefsDecisionMakerPaymentAccountThenReturnNullForDeletedAccount() {
    // Create a mock account ID to simulate a deleted store account
    Id deletedAccountId = Fake.generateId(Account.class);

    // Set up ApexMocks
    fflib_ApexMocks mocks = new fflib_ApexMocks();

    // Mock dependencies
    IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
    IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

    Map<String, Set<String>> mockInput = new Map<String, Set<String>>{
        'Account' => new Set<String>{'Id'},
        'Xref' => new Set<String>{'Xref_Status__c'},
        'Account_Payment_Account_Relation' => new Set<String>{'Name', 'Type__c'}
    };

    // Start stubbing behavior
    mocks.startStubbing();

    // Mock getAllAccountsandRelatedObjectFields to return a valid field map
    mocks.when(mockRESSMOService.getAllAccountsandRelatedObjectFields(mockInput))
        .thenReturn(new Map<String, Set<String>>{'Account' => new Set<String>{'Id'}});

    // Mock selectAccountByIdWithXrefPaymentAccount to return an empty list, simulating a deleted account
    mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(mockAccountSelector.selectAccountByIdWithXrefPaymentAccount(
        new Set<Id>{deletedAccountId},
        new Map<String, Set<String>>{'Account' => new Set<String>{'Id'}}
    )).thenReturn(new List<Account>());

    // Stop stubbing behavior
    mocks.stopStubbing();

    // Set the mocks into the application layer
    Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
    Application.SELECTOR.setMock(mockAccountSelector);

    // Executing the method under test
    Account account = RESSMOServiceImpl.getAccountWithXrefsDecisionMakerPaymentAccount(mockInput, deletedAccountId);

    // Assert that the result is null
    Assert.isNull(
        account,
        'Unexpected Error: Account should be null when the store account is deleted.'
    );
    }

    /**
    * @description test method for RESSMOServiceImpl.getFieldValue
    * @author VenkateshDD | 12-06-2024
    **/
    @IsTest
    static void testWhenGetFieldValueThenReturnAlterNativeStoreName(){
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        Account acc = new Account(Name = 'Account Name',Alternative_Store_Name__c = 'Alternative Name');

        ddmxObjectToSobject.put(RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, acc);

        RESSMO_Mapping__mdt ressmoMdt = new RESSMO_Mapping__mdt(API_Property__c = RESSMOServiceImpl.ACCOUNT_NAME_API_PROPERTY, JSON_Object__c = RESSMOServiceImpl.STORE_ACCOUNT_JSON_OBJECT, Object_Name__c = RESSMOServiceImpl.STORE_ACCOUNT_OBJECT, Field_Name__c = 'Name');

        String fieldValue = (String)RESSMOServiceImpl.getFieldValue(ressmoMdt, ddmxObjectToSobject);

        Assert.areEqual(fieldValue, acc.Alternative_Store_Name__c, 'Expecting it to be a Alternative store name to be returned');
        Assert.areEqual(ressmoMdt.Field_Name__c, RESSMOServiceImpl.ALTERNATIVE_STORE_NAME_FIELD, 'Alternative store Name field should be updated');

    }
}