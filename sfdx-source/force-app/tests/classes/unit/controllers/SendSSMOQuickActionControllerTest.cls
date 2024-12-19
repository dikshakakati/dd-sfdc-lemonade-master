/**
 * @description       :
 * @author            : Soumya Dash
 * @group             :
 * @last modified on  : 12-09-2024
 * @last modified by  : Soumya Dash
**/
@isTest
private class SendSSMOQuickActionControllerTest {

    private static final String CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String OPENED_FROM_CONTRACT = 'Contract';
    private static final String QUOTE_SECTION = 'Quote';
    private static final String ACCOUNT_SECTION = 'Account';
    private static final String CONTACT_SECTION = 'Contact';
    private static final String MX_ONBOARDING_NEW_STORE_EXPANSION = 'NSE';
    private static final String REP_COLLECTING_ON_MX_BEHALF_YES = 'Yes';
    private static final String RESSMO_UI_PAYLOAD_QUOTE = '{"Photoshoot" : {},"Account" : {}}';
    private static final String RESSMO_UI_PAYLOAD_CONTRACT = '{"genericInput": {"Contact": {},"Quote": {},"Photoshoot": {},"Account": {}}}';
    private static final String MX_ONBOARDING_SOURCE_ONA = 'OnA';
    private static final String QUOTE_OBJECT = 'SBQQ__Quote__c';
    private static final String CONTRACT_OBJECT = 'Contract';

    /**
    * @description - when store id is not present on quote then select last created store
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenAccountIdIsNotPresentThenSelectLastCreatedStore(){

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

        RESSMO_UI_Input__mdt quoteField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'SSMO_Expiration_Date__c	 ')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'SBQQ__Quote__c')
            .setField(RESSMO_UI_Input__mdt.Section__c,QUOTE_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField,
            quoteField
        };

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'},
            'SBQQ__Quote__c' => new Set<String>{'SSMO_Expiration_Date__c	 '}
        };

        Id storeId = Fake.generateId(Account.sObjectType);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.sObjectType);

        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setField(Account.Legal_Business_Name__c,'Test Legal')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Account__r', new Fake(Account.class)
                        .setField(Account.Id,businessAccount.Id)
                        .setField(Account.Legal_Business_Name__c,businessAccount.Legal_Business_Name__c))
            .setChildren('Opportunity_Contact_Role__r',new List<Fake>{new Fake(OpportunityContactRole.class)
                										.setField(OpportunityContactRole.Role,CONTRACT_SIGNATORY)
                										.setParent('Contact',new Fake(Contact.class)
                                               			 	.setField(Contact.FirstName,'Test')
                           									.setField(Contact.LastName,'Contact')
	                           								.setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setField(SBQQ__Quote__c.RESSMO_Payload__c,RESSMO_UI_PAYLOAD_QUOTE)
            .setFakeId()
            .tosObject();



        Account storeAccount = (Account) new Fake(Account.class)
        .setField(Account.Name,'Test Store Account')
        .setField(Account.ParentId,businessAccount.id)
        .setField(Account.Address_Verification_Status__c,'Verified')
        .setField(Account.Coverage__c,'In Coverage')
        .setChildren('Account_Payment_Account_Relations__r',new List<Fake>{
                new Fake(Account_Payment_Account_Relation__c.class)
                    .setField(Account_Payment_Account_Relation__c.Account__c,storeId)
                    .setParent('Payment_Account__r',new Fake(Payment_Account__c.class)
                            .setField(Payment_Account__c.Id,paymentAccountId)
                            )
                    .setFakeId()
            })
        .setField(Account.Id,storeId)
        .tosObject();

        map<String,sObject> ddmxObjectToSobject = new map<String,sObject>{
            'Account (Store Account)' => storeAccount,
            'Payment_Account__c' => storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r,
            'Account (Business Account)' => new Account(Id = businessAccount.Id,Legal_Business_Name__c = businessAccount.Legal_Business_Name__c)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);

        mocks.startStubbing();
            mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
            mocks.when(mockQuoteSelector.selectByIdWithBusinessAccount(quote.Id,objectToSobjectFields)).thenReturn(quote);

            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByBusinessAccountIdAndgetStoreDetails(businessAccount.Id,objectToSobjectFields)).thenReturn(new List<Account>{storeAccount});

            mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
            mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfQuote()).thenReturn(uiInputs);
            mocks.when(mockService.bankingInfoExists(ddmxObjectToSobject)).thenReturn(true);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockQuoteSelector);
        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);


        Test.startTest();
            SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.initializeSendToSSMO(quote.Id,'Quote');
        Test.stopTest();

        System.assert(result.objectWrapper != null,'result not fetched');
        System.assert(result.objectWrapper.quote != null,'quote not fetched');
        System.assert(result.objectWrapper.paymentAccount != null,'Payment Account not fetched');
        System.assert(result.objectWrapper.storeAccount.Name == 'Test Store Account','Store Name not equal');
        Assert.areEqual(JSON.deserializeUntyped(RESSMO_UI_PAYLOAD_QUOTE),result.objectWrapper.genericInput,'generic input is not same');
        Assert.areEqual(true,result.objectWrapper.isBankingInfoPopulated,'Banking info should be true');
    }

    /* *
    * @description -test initialize method exception
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenInitializeMethodHasExceptionThenCatchException(){

        Id quoteId = Fake.generateId(SBQQ__Quote__c.sObjectType);
        String message;
        sendSSMOQuickActionController.SendToRESSMODataWrapper result = new sendSSMOQuickActionController.SendToRESSMODataWrapper();

        Test.startTest();
        try{
            result = SendSSMOQuickActionController.initializeSendToSSMO(quoteId,'Quote');
        }
        catch(Exception ex){
            message = ex.getMessage();
        }
        Test.stopTest();

        Assert.areNotEqual(null,message,'Exception Not Thrown');

    }


    /**
    * @description - test when store is present on quote thene select its details
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenAccountIdIsPresentThenSelectTheStore(){

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

        RESSMO_UI_Input__mdt quoteField = (RESSMO_UI_Input__mdt)new Fake(RESSMO_UI_Input__mdt.class)
            .setField(RESSMO_UI_Input__mdt.Field_API_Name__c,'SSMO_Expiration_Date__c	 ')
            .setField(RESSMO_UI_Input__mdt.Object_API_Name__c,'SBQQ__Quote__c')
            .setField(RESSMO_UI_Input__mdt.Section__c,QUOTE_SECTION)
            .setFakeId()
            .tosObject();

        List<RESSMO_UI_Input__mdt> uiInputs = new List<RESSMO_UI_Input__mdt>{
            accountField,
            contactField,
            quoteField
        };

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'},
            'SBQQ__Quote__c' => new Set<String>{'SSMO_Expiration_Date__c	 '}
        };

        Id storeId = Fake.generateId(Account.sObjectType);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.sObjectType);

        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setField(Account.Legal_Business_Name__c,'Test Legal')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeId)
            .setParent('SBQQ__Account__r', new Fake(Account.class)
                        .setField(Account.Id,businessAccount.Id)
                        .setField(Account.Legal_Business_Name__c,businessAccount.Legal_Business_Name__c))
            .setChildren('Opportunity_Contact_Role__r',new List<Fake>{new Fake(OpportunityContactRole.class)
														.setField(OpportunityContactRole.Role,CONTRACT_SIGNATORY)
                										.setParent('Contact',new Fake(Contact.class)
                                               			 	.setField(Contact.FirstName,'Test')
                           									.setField(Contact.LastName,'Contact')
	                           								.setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();


        Account storeAccount = (Account) new Fake(Account.class)
        .setField(Account.Name,'Test Store Account')
        .setField(Account.ParentId,businessAccount.id)
        .setField(Account.Address_Verification_Status__c,'Verified')
        .setField(Account.Coverage__c,'In Coverage')
        .setChildren('Account_Payment_Account_Relations__r',new List<Fake>{
                new Fake(Account_Payment_Account_Relation__c.class)
                    .setField(Account_Payment_Account_Relation__c.Account__c,storeId)
                    .setParent('Payment_Account__r',new Fake(Payment_Account__c.class)
                            .setField(Payment_Account__c.Id,paymentAccountId)
                            )
                    .setFakeId()
            })
        .setField(Account.Id,storeId)
        .tosObject();

        map<String,sObject> ddmxObjectToSobject = new map<String,sObject>{
            'Account (Store Account)' => storeAccount,
            'Payment_Account__c' => storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r,
            'Account (Business Account)' => new Account(Id = businessAccount.Id,Legal_Business_Name__c = businessAccount.Legal_Business_Name__c)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);
 		IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
            mocks.when(mockQuoteSelector.selectByIdWithBusinessAccount(quote.Id,objectToSobjectFields)).thenReturn(quote);

            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByBusinessAccountIdAndgetStoreDetails(businessAccount.Id,objectToSobjectFields)).thenReturn(new List<Account>{storeAccount});

            mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
            mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfQuote()).thenReturn(uiInputs);

			mocks.when(mockService.bankingInfoExists(ddmxObjectToSobject)).thenReturn(false);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockQuoteSelector);
        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
		APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.initializeSendToSSMO(quote.Id,'Quote');
        Test.stopTest();

        System.assert(result.objectWrapper != null,'result not fetched');
        System.assert(result.objectWrapper.quote != null,'quote not fetched');
        System.assert(result.objectWrapper.paymentAccount != null,'Payment Account not fetched');
        System.assert(result.objectWrapper.storeAccount.Name == 'Test Store Account','Store Name not equal');
        Assert.areEqual(false,result.objectWrapper.isBankingInfoPopulated,'banking info should be false');
    }

    /**
    * @description test update with quote ineligible
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenAccountContactQuoteisRecievedThenItIsUpdatedAndQuoteNotEligibile(){

        Account businessAccount = (Account)new Fake(Account.class)
        .setField(Account.Total_Number_Of_Stores__c,1)
        .setFakeId()
        .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
          .setField(Account.Name,'Test Store Account')
          .setField(Account.Menu_URL__c,'www.menu.com')
          .setField(Account.POS_System__c,'AccuPOS')
          .setFakeId()
          .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

         Contact photoshootContact = (Contact)new Fake(Contact.class)
             .setField(Schema.Contact.FirstName,'photoshoot')
             .setField(Schema.Contact.LastName,'Contact')
             .setField(Schema.Contact.Email,'test@gamil.com')
             .setFakeId()
             .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .tosObject();

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.openedFrom = 'Quote';
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.photoshootContact = photoshootContact;



        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        Map<String,List<String>> objectVsEligibility=  new Map<String,List<String>>();
        objectVsEligibility.put('SBQQ__Quote__c',new List<String>{'Quote is not eligible'});
        mocks.startStubbing();
        	mocks.when(mockService.getEligibilityMessagesForQuote(quote.Id)).thenReturn(objectVsEligibility);
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Account.Name =>  'Test Store Account',
                Account.Menu_URL__c => 'www.menu.com'
             }
        )
        );

       	((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
             new map<sObjectField,Object>{
                 Schema.Contact.FirstName =>  'Test',
                 Schema.Contact.LastName => 'Contact'
              }
         )
        );

         ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
             new map<sObjectField,Object>{
                 Schema.Contact.FirstName =>  'photoshoot',
                 Schema.Contact.LastName => 'Contact'
              }
         )
         );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                SBQQ__Quote__c.SSMO_Expiration_Date__c =>  Date.valueOf('2024-12-01')
             }
        )
        );

        Assert.areEqual('Failed',result.ressmoResponse.status,'Wrong Status');

    }

    /**
    * @description - test update record exception
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenUpdateRecordsHasExceptionThenCatchException(){
        String exceptionMessage;
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = new SendSSMOQuickActionController.SendToRESSMODataWrapper();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
        .setField(Account.Total_Number_Of_Stores__c,1)
        .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
          .setField(Account.ParentId,businessAccount.Id)
          .setField(Account.Name,'Test Store Account')
          .setField(Account.Menu_URL__c,'www.menu.com')
          .setField(Account.POS_System__c,'AccuPOS')
          .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .tosObject();

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.openedFrom = 'Quote';


        Test.startTest();
        try{
            result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        }
        catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.areNotEqual(null,exceptionMessage,'Exception should be thrown');

    }


    /**
    * @description - test update record and quote eligible
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenAccountContactQuoteisRecievedThenItIsUpdatedAndQuoteEligible(){


        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();


        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.openedFrom = 'Quote';


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
        	mocks.when(mockService.getEligibilityMessagesForQuote(quote.Id)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Account.Name =>  'Test Store Account',
                Account.Menu_URL__c => 'www.menu.com'
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Schema.Contact.FirstName =>  'Test',
                Schema.Contact.LastName => 'Contact'
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                SBQQ__Quote__c.SSMO_Expiration_Date__c =>  Date.valueOf('2024-12-01')
             }
        )
        );

        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }


    /**
    * @description test update with quote ineligible
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenPhotoshootContactInsertedAndDuplicateContactPresentThenCreateACR(){

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gmail.com')
            .setFakeId()
            .tosObject();

        Contact photoshootContact = (Contact)new Fake(Contact.class)
            .setField(Schema.Contact.FirstName,'photoshoot')
            .setField(Schema.Contact.LastName,'Contact')
            .setField(Schema.Contact.Email,'test@gmail.com')
            .tosObject();

        Contact duplicateContact = (Contact)new Fake(Contact.class)
            .setField(Schema.Contact.FirstName,'photoshoot')
            .setField(Schema.Contact.LastName,'Contact')
            .setField(Schema.Contact.Email,'duplicateContact@gmail.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .tosObject();

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.openedFrom = 'Quote';
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.photoshootContact = photoshootContact;



        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IContactsSelector mockSelector = (IContactsSelector)mocks.mock(IContactsSelector.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Schema.Contact.sObjectType);
            mocks.when(mockSelector.selectContactByEmailFirstNameLastNameAccountIds(
                new Set<String>{photoshootContact.FirstName},
                new Set<String>{photoshootContact.LastName},
                new Set<String>{photoshootContact.Email},
                storeAccount.Id,
                businessAccount.Id
            )).thenReturn(new List<Contact>{duplicateContact});

        	mocks.when(mockService.getEligibilityMessagesForQuote(quote.Id)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();


        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerNew(fflib_Match.sObjectWith(
             new map<sObjectField,Object>{
                 AccountContactRelation.AccountId =>  storeAccount.Id,
                 AccountContactRelation.ContactId => duplicateContact.Id,
                 AccountContactRelation.Roles => 'Photoshoot Contact'
              }
         )
         );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerNew(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                AccountContactRelation.AccountId =>  storeAccount.Id,
                AccountContactRelation.ContactId => contact.Id,
                AccountContactRelation.Roles => 'Contract Signatory;Decision Maker'
             }
        )
        );

        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }



    /**
    * @description test update with quote ineligible
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenPhotoshootContactInsertedAndDuplicateACRPresentThenUpdateACR(){

        Id duplicateContactId = Fake.generateId(Schema.Contact.sObjectType);
        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gmail.com')
            .setFakeId()
            .tosObject();

        Contact photoshootContact = (Contact)new Fake(Contact.class)
            .setField(Schema.Contact.FirstName,'photoshoot')
            .setField(Schema.Contact.LastName,'Contact')
            .setField(Schema.Contact.Email,'test@gmail.com')
            .tosObject();

        Contact duplicateContact = (Contact)new Fake(Contact.class)
            .setField(Schema.Contact.Id,duplicateContactId)
            .setField(Schema.Contact.FirstName,'photoshoot')
            .setField(Schema.Contact.LastName,'Contact')
            .setField(Schema.Contact.Email,'duplicateContact@gmail.com')
            .setChildren('AccountContactRelations',new List<Fake>{new Fake(AccountContactRelation.class)
                                                .setfield(AccountContactRelation.AccountId,storeAccount.Id)
                                                .setField(AccountContactRelation.ContactId,duplicateContactId)
                                            })
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .tosObject();

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.openedFrom = 'Quote';
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.photoshootContact = photoshootContact;



        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IContactsSelector mockSelector = (IContactsSelector)mocks.mock(IContactsSelector.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Schema.Contact.sObjectType);
            mocks.when(mockSelector.selectContactByEmailFirstNameLastNameAccountIds(
                new Set<String>{photoshootContact.FirstName},
                new Set<String>{photoshootContact.LastName},
                new Set<String>{photoshootContact.Email},
                storeAccount.Id,
                businessAccount.Id
            )).thenReturn(new List<Contact>{duplicateContact});

        	mocks.when(mockService.getEligibilityMessagesForQuote(quote.Id)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();


        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
             new map<sObjectField,Object>{
                 AccountContactRelation.AccountId =>  storeAccount.Id,
                 AccountContactRelation.ContactId => duplicateContact.Id,
                 AccountContactRelation.Roles => 'Photoshoot Contact'
              }
         )
         );


        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }

    /**
    * @description - test when rest ssmo login then register dirty opportunity ressmo link and unique identifier as blank also Xref
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenContactUUIDisblankThenUpdateOpportunityUUIDAndRESSMOLInkBlankFromQuote(){

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c,Fake.generateId(Opportunity.sObjectType))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                    .setField(Xref__c.External_ID__c,'1234')})
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setField(Contact.Unique_Identifier__c,'')
            .setFakeId()
            .tosObject();


        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUi.resetSSMOLogin = true;
        dataFromUI.openedFrom = QUOTE_OBJECT;


        Map<String,Set<String>> objectToField = new map<String,Set<String>>{'Account' => new Set<String>(),'Xref' => new Set<String>(),'Account_Payment_Account_Relation' => new Set<String>()};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountsSelector mockSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockSelector.selectAccountByIdWithXrefPaymentAccount(new Set<Id>{storeAccount.Id},objectToField)).thenReturn(new List<Account>{storeAccount});

        	mocks.when(mockService.getEligibilityMessagesForQuote(quote.Id)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();


        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOw,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Opportunity.Id => quote.SBQQ__Opportunity2__c,
                Opportunity.RESSMO_Link__c => '',
                Opportunity.Unique_Identifier__c => ''
            }
        ));

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOw,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Xref__c.Id => storeAccount.Xrefs__r[0].Id,
                Xref__c.External_ID__c => ''
            }
        ));

        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }



    /**
    * @description - test reset ssmo login register dirty opportunity ressmo link and unique identifier as blank also Xref from contract
    * also quote uuid
    * @author Soumya Dash | 09-04-2024
    **/
    @isTest
    static void testWhenContactUUIDisblankThenUpdateOpportunityUUIDAndRESSMOLInkBlankFromContract(){

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c,Fake.generateId(Opportunity.sObjectType))
            .setField(SBQQ__Quote__c.Unique_Identifier__c,'')
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                    .setField(Xref__c.External_ID__c,'1234')})
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setField(Contact.Unique_Identifier__c,'')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.SBQQ__Opportunity__c,Fake.generateId(Opportunity.sObjectType))
            .setField(Contract.AccountId,businessAccount.Id)
            .setFakeId()
            .tosObject();

        map<Object,Object> mapGenricInput = new Map<Object,Object>{
                'Quote' => new map<String,Object>{
                               'SSMOExpirationDate' => '2024-02-10'
                           }
        };



        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.genericInput = mapGenricInput;
        dataFromUi.resetSSMOLogin = true;
        dataFromUI.openedFrom = CONTRACT_OBJECT;


        Map<String,Set<String>> objectToField = new map<String,Set<String>>{'Account' => new Set<String>(),'Xref' => new Set<String>(),'Account_Payment_Account_Relation' => new Set<String>()};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountsSelector mockSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockSelector.selectAccountByIdWithXrefPaymentAccount(new Set<Id>{storeAccount.Id},objectToField)).thenReturn(new List<Account>{storeAccount});

        	mocks.when(mockService.getEligibilityMessagesForContract(contract,storeAccount,contact,quote)).thenReturn(new Map<String,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOw,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Xref__c.Id => storeAccount.Xrefs__r[0].Id,
                Xref__c.External_ID__c => ''
            }
        ));

        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }

    /**
    * @description - test send sssmo success
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenSendToSSMOThenReturnSuccessResult(){

        Map<String,Set<String>> objectstosObjectFields = new Map<String,Set<String>>{
            'SBQQ__Quote__c' => new Set<String>(),
            'Contact' => new Set<String>()
        };

        Id storeId = Fake.generateId(Account.sObjectType);

        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeId)
            .setChildren('Opportunity_Contact_Role__r',new List<Fake>{new Fake(OpportunityContactRole.class)
														.setField(OpportunityContactRole.Role,CONTRACT_SIGNATORY)
                										.setParent('Contact',new Fake(Contact.class)
                                               			 	.setField(Contact.FirstName,'Test')
                           									.setField(Contact.LastName,'Contact')
	                           								.setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();


        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(System.label.SSMO_Static_Resource_Name)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.createSSMOWrap(RESSMOResponseWrapper.parse(payloadString), 200);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
         mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
         mocks.when(mockQuoteSelector.selectByIdWithBusinessAccount(quote.Id,objectstosObjectFields)).thenReturn(quote);

         mocks.when(mockService.sendQuote(quote.Id, quote.SBQQ__Opportunity2__r.RESSMO_Link__c,false)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockQuoteSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.RESSMOResponseWrapper ressmoResponse = SendSSMOQuickActionController.sendToSSMOQuoteUI(quote.Id);
        Test.stopTest();

        Assert.areEqual('Success',ressmoResponse.status,'Send to SSMO should be successfull');
    }


    /**
    * @description  test send ssmo failed-
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenSendToSSMOThenReturnFailedResult(){

        Map<String,Set<String>> objectstosObjectFields = new Map<String,Set<String>>{
            'SBQQ__Quote__c' => new Set<String>(),
            'Contact' => new Set<String>()
        };

        Id storeId = Fake.generateId(Account.sObjectType);

        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeId)
            .setChildren('Opportunity_Contact_Role__r',new List<Fake>{new Fake(OpportunityContactRole.class)
														.setField(OpportunityContactRole.Role,CONTRACT_SIGNATORY)
                										.setParent('Contact',new Fake(Contact.class)
                                               			 	.setField(Contact.FirstName,'Test')
                           									.setField(Contact.LastName,'Contact')
	                           								.setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();


        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(System.label.SSMO_Static_Resource_Name)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOWrapper.ResultMessageWrapper result = RESSMOServiceImpl.createSSMOWrap(RESSMOResponseWrapper.parse(payloadString), 400);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
         mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
         mocks.when(mockQuoteSelector.selectByIdWithBusinessAccount(quote.Id,objectstosObjectFields)).thenReturn(quote);

         mocks.when(mockService.sendQuote(quote.Id, quote.SBQQ__Opportunity2__r.RESSMO_Link__c,false)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockQuoteSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.RESSMOResponseWrapper ressmoResponse =  SendSSMOQuickActionController.sendToSSMOQuoteUI(quote.Id);
        Test.stopTest();

        Assert.areEqual('Failed',ressmoResponse.status,'Send to SSMO should be failed');
    }

    /**
    * @description - test send ssmo exception
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    static void testWhenSendSSMOHasExceptionThenCatchException(){
        String exceptionMessage;
        Id quoteId = Fake.generateId(SBQQ__Quote__c.sObjectType);

        Test.startTest();
        try{
            SendSSMOQuickActionController.sendToSSMOQuoteUI(quoteId);
        }
        catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.areNotEqual(null,exceptionMessage,'Exception should be thrown');
    }

    /**
    * @description - test when store change has exception then catch exception
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    private static void testWhenStoreChangedHasExceptionThenCatchException(){

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
        List<RESSMO_UI_Input__mdt> allInputMetadata = new List<RESSMO_UI_Input__mdt>{accountField,contactField};

        SendSSMOQuickActionController.RESSMOUIObjectWrapper result = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        Id businessAccountId  =  Fake.generateId(Account.sObjectType);
        Id storeId = Fake.generateId(Account.sObjectType);
        String exceptionMessage;

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByStoreAccountIdAndgetStoreDetails(storeId,businessAccountId,objectToSobjectFields)).thenReturn(new List<Account>());
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockAccountSelector);

        Test.startTest();
            try{
                result = SendSSMOQuickActionController.getStoreDetailsByStoreId(storeId, businessAccountId,allInputMetadata);
            }
            Catch(Exception ex){
                exceptionMessage = ex.getMessage();
            }
        Test.stopTest();

        Assert.areNotEqual(null , exceptionMessage, 'Exception should be thrown' );
    }


    /**
    * @description - test when store is changeg on ui then return store details
    * @author Soumya Dash | 07-15-2024
    **/
    @isTest
    private static void testWhenSToreChangedThenReturnStoreDetails(){

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
        List<RESSMO_UI_Input__mdt> allInputMetadata = new List<RESSMO_UI_Input__mdt>{accountField,contactField};

        SendSSMOQuickActionController.RESSMOUIObjectWrapper result = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        Id businessAccountId  =  Fake.generateId(Account.sObjectType);
        Id storeId = Fake.generateId(Account.sObjectType);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.sObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
        .setField(Account.Name,'Test Store Account')
        .setField(Account.Order_Protocol__c,'Email')
        .setField(Account.ParentId,businessAccountId)
        .setField(Account.Address_Verification_Status__c,'Verified')
        .setField(Account.Coverage__c,'In Coverage')
        .setChildren('Account_Payment_Account_Relations__r',new List<Fake>{
                new Fake(Account_Payment_Account_Relation__c.class)
                    .setField(Account_Payment_Account_Relation__c.Account__c,storeId)
                    .setParent('Payment_Account__r',new Fake(Payment_Account__c.class)
                            .setField(Payment_Account__c.Id,paymentAccountId)
                            )
                    .setFakeId()
            })
        .setChildren('AccountContactRelations', new List<Fake>{new Fake(AccountContactRelation.class)
                                                .setParent('Contact',new Fake(Contact.class)
                                                        .setField(Contact.FirstName,'Test')
                                                        .setField(Contact.LastName,'Contact')
                                                    )})
        .setField(Account.Id,storeId)
        .tosObject();

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByStoreAccountIdAndgetStoreDetails(storeId,businessAccountId,objectToSobjectFields)).thenReturn(new List<Account>{storeAccount});
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockAccountSelector);

        Test.startTest();
            result = SendSSMOQuickActionController.getStoreDetailsByStoreId(storeAccount.Id, businessAccountId,allInputMetadata);
        Test.stopTest();

        Assert.areNotEqual(null,result.storeAccount,'Account Not Fetched');
        Assert.areNotEqual(null,result.paymentAccount,'Account Not Fetched');
        Assert.areEqual('Email',result.storeAccount.Order_Protocol__c,'Incoorect field value');
        Assert.areEqual('Test',result.photoshootContact.FirstName,'PhotoShoot contact doesnt match');
    }

    //CONTRACTS SCENARIO

    @isTest
    static void testWhenContractHasActiveMxLinkThenReturn(){

        Contract contract = (Contract)new Fake(Contract.class)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Active')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .tosObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector mockContractsSelector = (IContractsSelector)mocks.mock(IContractsSelector.class);

        mocks.startStubbing();
            mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
            mocks.when(mockContractsSelector.selectByIdWithMxActiveOnboarding(contract.Id)).thenReturn(contract);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockContractsSelector);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.initializeSendToSSMO(contract.Id,'Contract');
        Test.stopTest();

        Assert.areEqual(contract.Mx_Onboarding_Links__r[0],result.hasMxOnboardingLink,'Active Mx Record Was not returned');
    }

    @isTest
    static void testWhenAccountIdIsNotPresentThenSelectLastCreatedStoreInCaseofContract(){

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

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };

        Id storeId = Fake.generateId(Account.sObjectType);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.sObjectType);

        Account businessAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Parent Account')
          .setField(Account.Legal_Business_Name__c,'Test Legal')
          .setFakeId()
          .tosObject();

		SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setParent('SBQQ__Account__r', new Fake(Account.class)
                        .setField(Account.Id,businessAccount.Id)
                        .setField(Account.Legal_Business_Name__c,businessAccount.Legal_Business_Name__c))
            .setParent('SBQQ__Opportunity2__r',new Fake(Opportunity.class)
                                                .setField(Opportunity.RESSMO_Link__c,'www.merchant.link'))
            .setFakeId()
            .tosObject();

        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
                .setChildren('OpportunityContactRoles',new List<Fake>{new Fake(OpportunityContactRole.class)
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
                .setFakeId()
                .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                                .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
                                                .setField(Mx_Onboarding_Link__c.Status__c,'Inactive')
                                                .setField(Mx_Onboarding_Link__c.Payload__c,RESSMO_UI_PAYLOAD_CONTRACT)
                                                .setFakeId()})
            .setFakeId()
            .tosObject();

        Contract contractWithoutActiveMx = (Contract)new Fake(Contract.class)
            .setField(Schema.Contract.SBQQ__Quote__c,quote.Id)
            .setField(Schema.Contract.SBQQ__Opportunity__c,opp.Id)
            .setField(Schema.Contract.AccountId,businessAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>())
            .setFakeId()
            .tosObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.ParentId,businessAccount.id)
            .setField(Account.Address_Verification_Status__c,'Verified')
            .setField(Account.Coverage__c,'In Coverage')
            .setChildren('Account_Payment_Account_Relations__r',new List<Fake>{
                    new Fake(Account_Payment_Account_Relation__c.class)
                        .setField(Account_Payment_Account_Relation__c.Account__c,storeId)
                        .setParent('Payment_Account__r',new Fake(Payment_Account__c.class)
                                .setField(Payment_Account__c.Id,paymentAccountId)
                                )
                        .setFakeId()
                })
            .setField(Account.Id,storeId)
            .tosObject();

        map<String,sObject> ddmxObjectToSobject = new map<String,sObject>{
            'Account (Store Account)' => storeAccount,
            'Payment_Account__c' => storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector mockContractsSelector = (IContractsSelector)mocks.mock(IContractsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
            mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.Id)).thenReturn(contract);
            mocks.when(mockContractsSelector.selectByIdWithMxActiveOnboarding(contract.Id)).thenReturn(contractWithoutActiveMx);

            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByBusinessAccountIdAndgetStoreDetails(businessAccount.Id,objectToSobjectFields)).thenReturn(new List<Account>{storeAccount});

            mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
            mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);

            mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
            mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

            mocks.when(mockService.bankingInfoExists(ddmxObjectToSobject)).thenReturn(true);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.initializeSendToSSMO(contract.Id,'Contract');
        Test.stopTest();

        System.assert(result.objectWrapper != null,'result not fetched');
        System.assert(result.objectWrapper.quote != null,'quote not fetched');
        System.assert(result.objectWrapper.storeAccount.Name == 'Test Store Account','Store Name not equal');
        System.assert(result.objectWrapper.paymentAccount != null,'Payment Account not fetched');
        Assert.areEqual(((map<String,Object>)JSON.deserializeUntyped(RESSMO_UI_PAYLOAD_CONTRACT)).get('genericInput'),result.objectWrapper.genericInput,'Genric input didnt not match');
    }

    @isTest
    static void testWhenAccountIdIsPresentThenSelectStoreInCaseofContract(){

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

        map<String,Set<String>> objectToSobjectFields = new map<String,Set<String>>{
            'Account' => new Set<String>{'Order_Protocol__c'},
            'Contact' => new Set<String>{'Contact.FirstName'}
        };

        Id storeId = Fake.generateId(Account.sObjectType);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.sObjectType);

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
                                                        .setParent('Contact',new Fake(Contact.class)
                                                            .setField(Contact.FirstName,'Test')
                                                            .setField(Contact.LastName,'Contact')
                                                            .setField(Contact.Email,'test@gamil.com')
                                                            .setFakeId())})
                .setFakeId()
                .tosObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.ParentId,businessAccount.id)
            .setField(Account.Address_Verification_Status__c,'Verified')
            .setField(Account.Coverage__c,'In Coverage')
            .setChildren('Account_Payment_Account_Relations__r',new List<Fake>{
                    new Fake(Account_Payment_Account_Relation__c.class)
                        .setField(Account_Payment_Account_Relation__c.Account__c,storeId)
                        .setParent('Payment_Account__r',new Fake(Payment_Account__c.class)
                                .setField(Payment_Account__c.Id,paymentAccountId)
                                )
                        .setFakeId()
                })
            .setField(Account.Id,storeId)
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
        .setField(Contract.SBQQ__Quote__c,quote.Id)
        .setField(Contract.SBQQ__Opportunity__c,opp.Id)
        .setField(Contract.AccountId,businessAccount.Id)
        .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
        .setFakeId()
        .tosObject();

        map<String,sObject> ddmxObjectToSobject = new map<String,sObject>{
            'Account (Store Account)' => storeAccount,
            'Payment_Account__c' => storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector mockContractsSelector = (IContractsSelector)mocks.mock(IContractsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IOpportunitiesSelector mockOppSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);
        IRESSMOUIInputsSelector mockRESSMOInputSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockContractsSelector.sObjectType()).thenReturn(Schema.Contract.sObjectType);
            mocks.when(mockContractsSelector.selectByIdWithRESSMOSourceMxOnboarding(contract.Id)).thenReturn(contract);
            mocks.when(mockContractsSelector.selectByIdWithMxActiveOnboarding(contract.Id)).thenReturn(contract);

            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectByBusinessAccountIdAndgetStoreDetails(businessAccount.Id,objectToSobjectFields)).thenReturn(new List<Account>{storeAccount});

            mocks.when(mockOppSelector.sObjectType()).thenReturn(Opportunity.sObjectType);
            mocks.when(mockOppSelector.selectOpportunityContactRoleByOpportunityId(opp.Id,objectToSobjectFields)).thenReturn(opp);

            mocks.when(mockRESSMOInputSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
            mocks.when(mockRESSMOInputSelector.selectRessmoUiInputsOfContract()).thenReturn(uiInputs);

        	mocks.when(mockService.bankingInfoExists(ddmxObjectToSobject)).thenReturn(true);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOInputSelector);
        APPLICATION.SELECTOR.setMock(mockOppSelector);
        APPLICATION.SELECTOR.setMock(mockContractsSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.initializeSendToSSMO(contract.Id,'Contract');
        Test.stopTest();

        System.assert(result.objectWrapper != null,'result not fetched');
        System.assert(result.objectWrapper.quote != null,'quote not fetched');
        System.assert(result.objectWrapper.storeAccount.Name == 'Test Store Account','Store Name not equal');
        System.assert(result.objectWrapper.paymentAccount != null,'Payment Account not fetched');

    }

    @isTest
    static void testWhenAccountContactisRecievedThenItIsUpdatedAndContractEligible(){

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
            .setFakeId()
            .tosObject();

        map<Object,Object> mapGenricInput = new Map<Object,Object>{
                'Quote' => new map<String,Object>{
                               'SSMOExpirationDate' => '2024-02-10'
                           }
        };

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.genericInput = (Object)mapGenricInput;
        dataFromUI.openedFrom = 'Contract';


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
            mocks.when(mockService.getEligibilityMessagesForContract(contract,storeAccount,contact,quote)).thenReturn(new Map<string,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Account.Name =>  'Test Store Account',
                Account.Menu_URL__c => 'www.menu.com'
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Schema.Contact.FirstName =>  'Test',
                Schema.Contact.LastName => 'Contact'
             }
        )
        );

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Schema.Contract.RESSMO_Store_Account_id__c => storeAccount.Id
             }
        )
        );

        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');

    }

    @isTest
    private static void testWhenPaymentAccountThenCreateRecordAndReturn(){

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setField(SBQQ__Quote__c.SBQQ__Account__c,businessAccount.Id)
            .setFakeId()
            .toSObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
            .setFakeId()
            .tosObject();

        Payment_Account__c paymentAccount = (Payment_Account__c)new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Bank_Account_Number__c	 ,'12345')
            .setField(Payment_Account__c.Business_Account__c,businessAccount.Id)
            .tosObject();

        map<Object,Object> mapGenricInput = new Map<Object,Object>{
                'Quote' => new map<String,Object>{
                               'SSMOExpirationDate' => '2024-02-10'
                           }
        };

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.businessAccount = businessAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.paymentAccount = paymentAccount;
        dataFromUi.resetSSMOLogin = false;
        dataFromUI.genericInput = (Object)mapGenricInput;
        dataFromUI.openedFrom = 'Contract';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IPaymentAccountsSelector mockPaymentSelector = (IPaymentAccountsSelector)mocks.mock(IPaymentAccountsSelector.class);
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);

        mocks.startStubbing();
            mocks.when(mockPaymentSelector.sObjectType()).thenReturn(Payment_Account__c.sObjectType);
            mocks.when(mockPaymentSelector.selectById(new Set<Id>{null})).thenReturn(new List<Payment_Account__c>{paymentAccount});

            mocks.when(mockService.getContractsWithSubscriptionsProducts(contract.Id)).thenReturn(contract);
            mocks.when(mockService.getEligibilityMessagesForContract(contract,storeAccount,contact,quote)).thenReturn(new Map<string,List<String>>());
        mocks.stopStubbing();

        APPLICATION.UNITOFWORK.setMock(mockUOW);
        APPLICATION.SELECTOR.setMock(mockPaymentSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);

        Test.startTest();
        SendSSMOQuickActionController.SendToRESSMODataWrapper result = SendSSMOQuickActionController.updateRecordsFromSSMOUI(dataFromUI);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerNew(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Payment_Account__c.Bank_Account_Number__c =>  paymentAccount.Bank_Account_Number__c,
                Payment_Account__c.Business_Account__c =>  businessAccount.Id
             }
        ));

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerNew(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Account_Payment_Account_Relation__c.Account__c =>  storeAccount.Id
             }
        ),
        (sObjectField)fflib_Match.eq(Account_Payment_Account_Relation__c.Payment_Account__c),
        fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Payment_Account__c.Bank_Account_Number__c =>  paymentAccount.Bank_Account_Number__c
             }
        ));

        Assert.areEqual(paymentAccount,result.objectWrapper.paymentAccount,'Invalid payment account');
        Assert.areEqual('Success',result.ressmoResponse.status,'Wrong Status');
    }


    @isTest
    private static void testWhenSendToSSMOFromContractSuccessThenReturnOnboardingLink(){

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
            .setField(Contract.Payment_Method__c,'Invoicing')
            .setFakeId()
            .tosObject();

        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        result.status = 'Success';
        result.onboardingLink = 'https://identity-service.doorcrawl.com/auth/user/signup/?response_type=code&redirect_uri=https%3A%2F%2Fmerchant-portal.doorcrawl.com%2Fonboarding%2Fapi%2Fv1%2Fsignup%2FauthCallback&scope=*&client_id=1629278785588850688&prompt=none&layout=merchant_web_ssmo_singularity&state=e2f7770e-c213-4393-89d3-8e5e160b9d84&email=tbbdsa%40ddr.invalid&phone=%2B14156711110&intl=en-us&first_name=first8thaug&last_name=TEST&ssmo_signup_type=marketplace_rep_enabled';
        result.uuid = '1234';

        map<Object,Object> mapGenricInput = new Map<Object,Object>{
            'Quote' => new map<String,Object>{
                           'SSMOExpirationDate' => '2024-02-10'
                       }
        };

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.genericInput = (Object)mapGenricInput;
        dataFromUI.openedFrom = 'Contract';


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);

        mocks.startStubbing();
            mocks.when(mockService.sendNewStore(contract.Id,storeAccount,contact,quote,false)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);
        APPLICATION.UNITOFWORK.setMock(mockUow);

        Test.startTest();
            SendSSMOQuickActionController.RESSMOResponseWrapper finalResult = SendSSMOQuickActionController.sendToSSMOContractUI(dataFromUI);
        Test.stopTest();

        Assert.areEqual('Success',finalResult.status,'Status should be success');

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUow,1)).registerNew(fflib_match.sObjectWith(
            new Map<sObjectField,Object>{
                Mx_Onboarding_Link__c.UUID__C => result.uuid,
                Mx_Onboarding_Link__c.Status__c => 'Active',
                Mx_Onboarding_Link__c.Contract__c => contract.Id,
                Mx_Onboarding_Link__c.Expiration_Date_Time__c => Date.valueOf('2024-02-10'),
                Mx_Onboarding_Link__c.Onboarding_Scenario__c => MX_ONBOARDING_NEW_STORE_EXPANSION,
                Mx_Onboarding_Link__c.Business_Account__c => businessAccount.Id,
                Mx_Onboarding_Link__c.Payment_Method__c => Contract.Payment_Method__c,
                Mx_Onboarding_Link__c.Rep_Collecting_On_Mx_Behalf__c => REP_COLLECTING_ON_MX_BEHALF_YES
            }
        ));
    }


    @isTest
    private static void testWhenSendToSSMOFromContractFailedThenReturnFailed(){

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
            .setField(Contract.Payment_Method__c,'Invoicing')
            .setFakeId()
            .tosObject();

        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        result.status = 'Failed';

        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.openedFrom = 'Contract';



        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);

        mocks.startStubbing();
            mocks.when(mockService.sendNewStore(contract.Id,storeAccount,contact,quote,false)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);
        APPLICATION.UNITOFWORK.setMock(mockUow);

        Test.startTest();
            SendSSMOQuickActionController.RESSMOResponseWrapper finalResult = SendSSMOQuickActionController.sendToSSMOContractUI(dataFromUI);
        Test.stopTest();

        Assert.areEqual('Failed',finalResult.status,'Status should be Failed');

    }

    @isTest
    private static void testWhenSendToSSMOFromContractHasExceptionThenReturnException(){
        String exceptionMessage;
        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.valueOf('2024-12-01'))
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account)new Fake(Account.class)
            .setField(Account.Total_Number_Of_Stores__c,1)
            .setFakeId()
            .tosObject();

        Account storeAccount =(Account) new Fake(Account.class)
            .setField(Account.ParentId,businessAccount.Id)
            .setField(Account.Name,'Test Store Account')
            .setField(Account.Menu_URL__c,'www.menu.com')
            .setField(Account.POS_System__c,'AccuPOS')
            .setFakeId()
            .tosObject();

        Contact contact = (Contact)new Fake(Contact.class)
            .setField(Contact.FirstName,'Test')
            .setField(Contact.LastName,'Contact')
            .setField(Contact.Email,'test@gamil.com')
            .setFakeId()
            .tosObject();

        Contract contract = (Contract)new Fake(Contract.class)
            .setField(Contract.SBQQ__Quote__c,quote.Id)
            .setField(Contract.AccountId,businessAccount.Id)
            .setField(contract.RESSMO_Store_Account_id__c,storeAccount.Id)
            .setField(Contract.Payment_Method__c,'Invoicing')
            .setFakeId()
            .tosObject();

        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        result.status = 'Failed';


        SendSSMOQuickActionController.RESSMOUIObjectWrapper dataFromUI = new SendSSMOQuickActionController.RESSMOUIObjectWrapper();
        dataFromUI.storeAccount = storeAccount;
        dataFromUI.contact = contact;
        dataFromUI.quote = quote;
        dataFromUI.contract = contract;
        dataFromUI.openedFrom = 'Contract';


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);

        mocks.startStubbing();
            mocks.when(mockService.sendNewStore(contract.Id,storeAccount,contact,quote,false)).thenReturn(null);
        mocks.stopStubbing();

        APPLICATION.SERVICE.setMock(IRESSMOService.class,mockService);
        APPLICATION.UNITOFWORK.setMock(mockUow);

        Test.startTest();
        try{
            SendSSMOQuickActionController.sendToSSMOContractUI(dataFromUI);
        }
        Catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.areNotEqual(null,exceptionMessage,'Exception should be thrown');

    }

    @isTest
    private static void testWhenPayloadThenGenerateMxLinkRelatedRecords(){

        Id businessAccountId = Fake.generateId(Account.sObjectType);
        Id contractId = Fake.generateId(Schema.Contract.sObjectType);
        Id mxLinkId = Fake.generateId(Mx_Onboarding_Link__c.sObjectType);

        Account storeAccountPreData = (Account)new Fake(Account.class)
            .setField(Account.Order_Protocol__c,'POS')
            .setField(Account.Name,'test store')
            .setFakeId()
            .tosObject();


        List<RESSMO_UI_Input__mdt> ressmoUiInputs = new List<RESSMO_UI_Input__mdt>{
            new RESSMO_ui_Input__mdt(
                Section__c = 'Account',
                Field_API_Name__c = 'Order_Protocol__c',
                OIAttributes__c = ((OIAttributes__mdt)new Fake(OIAttributes__mdt.class)
                                        .setField(OIAttributes__mdt.Field_API_Name__c,'Order_Protocol__c')
                                        .setField(OIAttributes__mdt.Data_Type__c,'Text')
                                        .setFakeId()
                                        .tosObject()).Id
                ),
            new RESSMO_ui_Input__mdt(
                Section__c = 'Account',
                Field_API_Name__c = 'Name',
                OIAttributes__c = ((OIAttributes__mdt)new Fake(OIAttributes__mdt.class)
                                        .setField(OIAttributes__mdt.Field_API_Name__c,'Store_Name_Account_Name__c')
                                        .setField(OIAttributes__mdt.Data_Type__c,'Text')
                                        .setFakeId()
                                        .tosObject()).Id
                ),
            new RESSMO_ui_Input__mdt(
                Section__c = 'Contact',
                Field_API_Name__c = 'FirstName',
                OIAttributes__c = ((OIAttributes__mdt)new Fake(OIAttributes__mdt.class)
                                        .setField(OIAttributes__mdt.Field_API_Name__c,'DM_First_Name__c')
                                        .setField(OIAttributes__mdt.Data_Type__c,'Text')
                                        .setFakeId()
                                        .tosObject()).Id
                ),
            new RESSMO_ui_Input__mdt(
                Section__c = 'Photoshoot',
                Field_API_Name__c = 'FirstName',
                OIAttributes__c = ((OIAttributes__mdt)new Fake(OIAttributes__mdt.class)
                                        .setField(OIAttributes__mdt.Field_API_Name__c,'Photoshoot_Contact_First_Name__c')
                                        .setField(OIAttributes__mdt.Data_Type__c,'Text')
                                        .setFakeId()
                                        .tosObject()).Id
                ),
            new RESSMO_ui_Input__mdt(
                Section__c = 'Photoshoot',
                Type__c = 'Generic Input',
                Field_API_Name__c = 'PhotoshootMxRequested',
                OIAttributes__c = ((OIAttributes__mdt)new Fake(OIAttributes__mdt.class)
                                        .setField(OIAttributes__mdt.Field_API_Name__c,'Mx_Requested_Photoshoot__c')
                                        .setField(OIAttributes__mdt.Data_Type__c,'Picklist')
                                        .setFakeId()
                                        .tosObject()).Id
                )
        };

        String payload = '{"storeAccount": {"attributes": {"type": "Account","url": "/services/data/v61.0/sobjects/Account/001O100000BkUCtIAN"},"Order_Protocol__c":"POS","Name": "test store","Id":"'+storeAccountPreData.Id+'"},"photoshootContact": {"attributes": {"type": "Contact","url": "/services/data/v61.0/sobjects/Contact/003O300000OaQNxIAN"},"FirstName": "Contract Minna"},"contract" : {"attributes":{"type":"Contract","url":"/services/data/v61.0/sobjects/Contract/800O1000007QKOtIAO"},"Payment_Method__c":"Invoicing","AccountId":"'+businessAccountId+'","SBQQ__Opportunity__c":"006O1000008uQwHIAU","SBQQ__Quote__c":"a1pO1000001UnYzIAK","Id":"'+contractId+'","RESSMO_Store_Account_Id__c":"001O100000BkUCtIAN"},"openedFrom": "Contract","mxOnboardingLinkId": "'+mxLinkId+'","genericInput": {"Photoshoot": {"PhotoshootMxRequested": "Yes"}},"contact": {"attributes": {"type": "Contact","url": "/services/data/v61.0/sobjects/Contact/003O100000AQQfwIAH"},"FirstName": "Akankshya"}}';
        map<String,Object> parseMap = (map<String,Object>)JSON.deserializeUntyped(payload);
        Contract contract = (Contract)JSON.deserialize(JSON.serialize(parseMap.get('contract')),Contract.class);
        Account storeAccount = (Account)JSON.deserialize(JSON.serialize(parseMap.get('storeAccount')),Account.class);
        Contact contact = (Contact)JSON.deserialize(JSON.serialize(parseMap.get('contact')),Contact.class);
        Contact photoshootContact = (Contact)JSON.deserialize(JSON.serialize(parseMap.get('photoshootContact')),Contact.class);
        map<String,Object> genericInput = (map<String,Object>)parseMap.get('genericInput');
        Map<String,Object> photoshootDateTime = (map<String,Object>)genericInput.get('Photoshoot');

        Mx_Onboarding_Link__c mxLink = (Mx_Onboarding_Link__c)new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Payload__c,payload)
            .setField(Mx_Onboarding_Link__c.Id,mxLinkId)
            .tosObject();

        Mx_Onboarding_Link__c newMxLink = (Mx_Onboarding_Link__c)new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Source__c,MX_ONBOARDING_SOURCE_ONA)
            .setFakeId()
            .tosObject();

        OIMainDataWrapper oiMainDataWrapper = new OIMainDataWrapper(businessAccountId,contractId);

        ContractInfoWrapper contractInfoWrapper = new ContractInfoWrapper();
        OIFormPayloadWrapper oiFormPayload = new OIFormPayloadWrapper(contract.Id);
        contractInfoWrapper.payload = oiFormPayload;
        contractInfoWrapper.payload.isActivateCentrallyValue = 'Yes';
        contractInfoWrapper.payload.orderProtocol = storeAccount.Order_Protocol__c;
        contractInfoWrapper.payload.brandName = null;
        oiMainDataWrapper.payload = oiFormPayload;

        List<OIFieldWrapper> oiFieldWrapperStore = new List<OIFieldWrapper>{
            new OIFieldWrapper(ressmoUiInputs[0].OIAttributes__r.Field_API_Name__c,(String)storeAccount.get(ressmoUiInputs[0].Field_API_Name__c),ressmoUiInputs[0].OIAttributes__r.Data_Type__c),
            new OIFieldWrapper(ressmoUiInputs[1].OIAttributes__r.Field_API_Name__c,(String)storeAccount.get(ressmoUiInputs[1].Field_API_Name__c),ressmoUiInputs[1].OIAttributes__r.Data_Type__c),
            new OIFieldWrapper(ressmoUiInputs[2].OIAttributes__r.Field_API_Name__c,(String)contact.get(ressmoUiInputs[2].Field_API_Name__c),ressmoUiInputs[2].OIAttributes__r.Data_Type__c)
        };
        List<StoreDataWrapper> storeDataWrapper = new List<StoreDataWrapper>{
            new StoreDataWrapper(1,oiFieldWrapperStore,null)
        };
        oiMainDataWrapper.storeDataWrappers = storeDataWrapper;
        List<OIFieldWrapper> oiFieldWrapperBusiness = new List<OIFieldWrapper>{
            new OIFieldWrapper(ressmoUiInputs[3].OIAttributes__r.Field_API_Name__c,(String)photoshootContact.get(ressmoUiInputs[3].Field_API_Name__c),ressmoUiInputs[3].OIAttributes__r.Data_Type__c),
            new OIFieldWrapper(ressmoUiInputs[4].OIAttributes__r.Field_API_Name__c,(String)photoshootDateTime.get(ressmoUiInputs[4].Field_API_Name__c),ressmoUiInputs[4].OIAttributes__r.Data_Type__c)
        };
        oiMainDataWrapper.businessInfoWrappers = oiFieldWrapperBusiness;
        oiMainDataWrapper.onboardingScenario = MX_ONBOARDING_NEW_STORE_EXPANSION;
        oiMainDataWrapper.isMxInputRequired = true;
        oiMainDataWrapper.repCollectingOnMxBehalf = REP_COLLECTING_ON_MX_BEHALF_YES;


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IMxOnboardingLinksSelector mockSelector = (IMxOnboardingLinksSelector)mocks.mock(IMxOnboardingLinksSelector.class);
        IRESSMOUIInputsSelector mockRESSMOSelector = (IRESSMOUIInputsSelector)mocks.mock(IRESSMOUIInputsSelector.class);
        IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IOIDataService mockService = (IOIDataService)mocks.mock(IOIDataService.class);

        mocks.startStubbing();
            mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountsSelector.selectById(new Set<Id>{storeAccountPreData.Id})).thenReturn(new List<Account>{storeAccountPreData});

            mocks.when(mockSelector.sObjectType()).thenReturn(Mx_Onboarding_Link__c.sObjectType);
            mocks.when(mockSelector.selectByIdWithPayloadAndRelated(mxLink.Id)).thenReturn(new List<Mx_Onboarding_Link__c>{mxLink});

            mocks.when(mockRESSMOSelector.sObjectType()).thenReturn(RESSMO_UI_Input__mdt.sObjectType);
            mocks.when(mockRESSMOSelector.selectAllREESMOUIInputContract()).thenReturn(ressmoUiInputs);

            mocks.when(mockService.fetchContractDetails(contract.Id,MX_ONBOARDING_NEW_STORE_EXPANSION)).thenReturn(contractInfoWrapper);
            mocks.when(mockService.saveMxOnboardingLinkRecord(JSON.serialize(new List<OIMainDataWrapper>{oiMainDataWrapper}))).thenReturn(newMxLink);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockSelector);
        APPLICATION.SELECTOR.setMock(mockRESSMOSelector);
        APPLICATION.SERVICE.setMock(IOIDataService.class,mockService);
        APPLICATION.SELECTOR.setMock(mockAccountsSelector);
        APPLICATION.UNITOFWORK.setMock(mockUOW);


        test.startTest();
            Boolean result = SendSSMOQuickActionController.generateMxLinkRecord(mxLink.Id);
        test.stopTest();

        Assert.areEqual(true,result,'Result should be true');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Mx_Onboarding_Link__c.Id => mxLink.Id,
                Mx_Onboarding_Link__c.status__c => 'Inactive',
                Mx_Onboarding_Link__c.Inactive_Reason__c => 'Deactivated'
            }
        ));

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).registerDirty(fflib_Match.sObjectWith(
            new map<sObjectField,Object>{
                Mx_Onboarding_Link__c.Source__c => MX_ONBOARDING_SOURCE_ONA
            }
        ));
  }


  @isTest
  static void testWhenBusinessAccountIdisPassedThenReturnActiveStoreIds(){
      Map<String,Set<String>> objectTosOjectFields = new Map<String,Set<String>>{
          'Account' => new Set<String>(),
          'Contact' => new Set<String>()
      };
      Id businessId = Fake.generateId(Account.sObjectType);
      Account storeAccount = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Account')
          .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                      .setField(Xref__c.External_ID__c,'1234')
                                      .setField(Xref__c.Record_Source__c,'MDS')
                                      .setField(Xref__c.Xref_Status__c,'Active')})
          .setFakeId()
          .tosObject();

      Account storeAccountTwo = (Account)new Fake(Account.class)
          .setField(Account.Name,'Test Account Two')
          .setFakeId()
          .tosObject();

      fflib_ApexMocks mocks  = new fflib_ApexMocks();
      IAccountsSelector mockSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

      mocks.startStubbing();
          mocks.when(mockSelector.sObjectType()).thenReturn(Account.sObjectType);
          mocks.when(mockSelector.selectByBusinessAccountIdAndgetStoreDetails(businessId,objectTosOjectFields)).thenReturn(new List<Account>{storeAccount,storeAccountTwo});
      mocks.stopStubbing();

      APPLICATION.SELECTOR.setMock(mockSelector);

      Test.startTest();
          List<Id> activeStoreId = SendSSMOQuickActionController.getStoresWithActiveXref(businessId);
      Test.stopTest();

      Assert.areEqual(true,activeStoreId.contains(storeAccount.Id),'Active store id should be there');
      Assert.areEqual(false,activeStoreId.contains(storeAccountTwo.Id),'Inactive store id should not be there');

  }

  /**
  * @description -  Test when get active xref store has exception then catch exception
  * @author Soumya Dash | 10-14-2024
  **/
  @isTest
  static void testWhenStoreWithActiveXrefHasExceptionThenCatchException(){
      Map<String,Set<String>> objectTosOjectFields = new Map<String,Set<String>>{
          'Account' => new Set<String>(),
          'Contact' => new Set<String>()
      };
      Id businessId = Fake.generateId(Account.sObjectType);

      fflib_ApexMocks mocks  = new fflib_ApexMocks();
      IAccountsSelector mockSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

      mocks.startStubbing();
          mocks.when(mockSelector.sObjectType()).thenReturn(Account.sObjectType);
          mocks.when(mockSelector.selectByBusinessAccountIdAndgetStoreDetails(businessId,objectTosOjectFields)).thenThrow(new DmlException());
      mocks.stopStubbing();

      APPLICATION.SELECTOR.setMock(mockSelector);

      Test.startTest();
      try{
          SendSSMOQuickActionController.getStoresWithActiveXref(businessId);
      }
      Catch(Exception ex){
        Assert.areNotEqual(null, ex.getMessage(),'Exception should be catched');
      }
      Test.stopTest();

  }
}
