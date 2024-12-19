/**
 * @description       :
 * @author            : SamikshaDD
 * @group             :
 * @last modified on  : 08-14-2024
 * @last modified by  : SamikshaDD
**/
@isTest
public with sharing class ManageRESSMOLinkControllerTest {

    @isTest
    private static void testWhenCalledThenPrepareManageRESSMOLinkPayload(){

        Account storeAccount = (Account)new Fake(Account.class)
            .setField(Account.Name,'test Store Account')
            .setField(Account.Unique_Identifier__c,'1122')
            .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                    .setfield(Xref__c.External_Id__c,'12345')
                                    .setFakeId()
                                    })
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.today().addDays(-1))
            .setFakeId()
            .tosObject();

        Map<String, Object> jsonMap = new Map<String, Object>();

        Map<String, Object> storeAccountMap = new Map<String, Object>();
        storeAccountMap.put('Unique_Identifier__c', storeAccount.Unique_Identifier__c!=null?storeAccount.Unique_Identifier__c:''); //variables to be added
        jsonMap.put('StoreAccount', storeAccountMap);


        Map<String, Object> dateMap = new Map<String, Object>();
        dateMap.put('SSMO_Expiration_Date__c', quote.SSMO_Expiration_Date__c);
        jsonMap.put('Quote', dateMap);

        Map<String, Object> paymentAccountObj = new Map<String, Object>();
        jsonMap.put('PaymentAccount', paymentAccountObj);
         jsonMap.put('voidOrExpire', true);

        String expectedPayload = JSON.serialize(jsonMap);
        String payload = ManageRESSMOLinkController.prepareManageRESSMOLinkPayload(System.Today()-1, storeAccount);

        Assert.areEqual(expectedPayload, payload, 'Payload Response is not a valid one');
    }

    @isTest
    private static void testWhenVoidQuoteAPIReturnsSuccessThenReturnSuccessTrue(){
        ManageRESSMOLinkController.Request request = new ManageRESSMOLinkController.Request();
        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        request.source = 'Quote';

        Account storeAccount = (Account)new Fake(Account.class)
            .setField(Account.Name,'test Store Account')
            .setField(Account.Unique_Identifier__c,'1122')
            .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                    .setfield(Xref__c.External_Id__c,'12345')
                                    .setFakeId()
                                    })
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c,storeAccount.Id)
            .setField(SBQQ__Quote__c.SSMO_Expiration_Date__c,Date.today())
            .setFakeId()
            .tosObject();

        request.quoteId = quote.Id;
        request.ExpirationDate = System.Today() - 1;

        Set<String> quoteFieldSet = new Set<String>{'RESSMO_Store_Account_Id__c','SSMO_Expiration_Date__c'};
        Set<String> accountFieldSet = new Set<String>{'Unique_Identifier__c'};
        Set<String> xrefFieldSet = new Set<String>{'External_Id__c'};
        map<String,set<String>> sObjectToFIeld = new map<String,set<String>>{
            'Account' => accountFieldSet,
            'Xref' => xrefFieldSet
        };

        String payLoad = ManageRESSMOLinkController.prepareManageRESSMOLinkPayload(request.ExpirationDate,storeAccount);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IQuotesSelector mockQuoteSelector = (IQuotesSelector)mocks.mock(IQuotesSelector.class);
        IRESSMOService mocksService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        mocks.startStubbing();
            mocks.when(mockQuoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.sObjectType);
            mocks.when(mockQuoteSelector.selectQuoteByIdWithGivenFields(new Set<Id>{quote.Id},quoteFieldSet)).thenReturn(new List<SBQQ__Quote__c>{quote});

            mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectAccountByIdWithXref(new Set<Id>{storeAccount.Id},sObjectToFIeld)).thenReturn(new List<Account>{storeAccount});

            mocks.when(mocksService.ssmoManageRESSMOLinkAPICall(payLoad)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockQuoteSelector);
        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mocksService);

        Test.startTest();
            List<ManageRESSMOLinkController.Response> actualResponse = ManageRESSMOLinkController.manageRESSMOLink(new List<ManageRESSMOLinkController.Request>{request});
        Test.stopTest();
        Assert.areEqual(true, actualResponse[0].success,'Result not match');

    }

    @isTest
    private static void testWhenVoidContractAPIReturnsSuccessThenReturnSuccessTrue(){
        ManageRESSMOLinkController.Request request = new ManageRESSMOLinkController.Request();
        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        request.source = 'Contract';

        Account storeAccount = (Account)new Fake(Account.class)
            .setField(Account.Name,'test Store Account')
            .setField(Account.Unique_Identifier__c,'1122')
            .setChildren('Xrefs__r',new List<Fake>{new Fake(Xref__c.class)
                                    .setfield(Xref__c.External_Id__c,'12345')
                                    .setFakeId()
                                    })
            .setFakeId()
            .tosObject();

        Contract contractRecord = (Contract)new Fake(Contract.class)
            .setField(Contract.RESSMO_Store_Account_Id__c,storeAccount.Id)
            .setChildren('Mx_Onboarding_Links__r',new List<Fake>{new Fake(Mx_Onboarding_Link__c.class)
                                    .setfield(Mx_Onboarding_Link__c.Status__c,'Active')
                					.setfield(Mx_Onboarding_Link__c.Source__c,'RESSMO')
                                    .setFakeId()
                                    })
            .setFakeId()
            .tosObject();

        request.contractId = contractRecord.Id;
        request.ExpirationDate = System.Today() - 1;

        Set<String> contractFieldSet = new Set<String>{'RESSMO_Store_Account_Id__c'};
        Set<String> accountFieldSet = new Set<String>{'Unique_Identifier__c'};
        Set<String> xrefFieldSet = new Set<String>{'External_Id__c'};
        map<String,set<String>> sObjectToFIeld = new map<String,set<String>>{
            'Account' => accountFieldSet,
            'Xref' => xrefFieldSet
        };

        String payLoad = ManageRESSMOLinkController.prepareManageRESSMOLinkPayload(request.ExpirationDate,storeAccount);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
        IContractsSelector mockContractSelector = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IRESSMOService mocksService = (IRESSMOService)mocks.mock(IRESSMOService.class);
        IMxOnboardingLinksSelector mxOnboardingLinksSelector = (IMxOnboardingLinksSelector) mocks.mock(IMxOnboardingLinksSelector.class);
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);

        mocks.startStubbing();
            mocks.when(mockContractSelector.sObjectType()).thenReturn(Contract.sObjectType);
            mocks.when(mockContractSelector.selectContractByIdWithGivenFields(new Set<Id>{contractRecord.Id},contractFieldSet)).thenReturn(new List<Contract>{contractRecord});

        	mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.sObjectType);
            mocks.when(mockAccountSelector.selectAccountByIdWithXref(new Set<Id>{storeAccount.Id},sObjectToFIeld)).thenReturn(new List<Account>{storeAccount});
			mocks.when(mocksService.ssmoManageRESSMOLinkAPICall(payLoad)).thenReturn(result);
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mxOnboardingLinksSelector);
        APPLICATION.SELECTOR.setMock(mockContractSelector);
        APPLICATION.SELECTOR.setMock(mockAccountSelector);
        APPLICATION.SERVICE.setMock(IRESSMOService.class,mocksService);
        APPLICATION.UNITOFWORK.setMock(mockUow);

        Test.startTest();
            List<ManageRESSMOLinkController.Response> actualResponse = ManageRESSMOLinkController.manageRESSMOLink(new List<ManageRESSMOLinkController.Request>{request});
        Test.stopTest();
        Assert.areEqual(true, actualResponse[0].success,'Result not match');

    }

}