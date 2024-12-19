@isTest
public class MerchantServicesServiceImplTest {
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement';
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String NAME_ACCOUNT = 'Test Acc';
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
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';

    /**
     * @description To test setMxAgreedToProductValueNoFromFlow call
     * @JIRA #LEM-15980
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeactivatedAgreementsPassedThenSetMxAgreedToProductValueNofromFlow() {
        Id agreementId1 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id agreementId2 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id accountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId1 = fflib_IDGenerator.generate(Contract.SObjectType);

        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId1,
                Deactivation_Date__c = System.today()
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId2,
                Deactivation_Date__c = System.today()
            )
        };

        Merchant_Service__c merchantServiceRecordMarketPlace1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        Merchant_Service__c merchantServiceRecordMarketPlace2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        List<Merchant_Service__c> existingServices1 = new List<Merchant_Service__c>{
            merchantServiceRecordMarketPlace1,
            merchantServiceRecordMarketPlace2
        };

        // Mock AgreementsService to return specific deactivated and cancelled agreement account IDs
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsService mockAgreementsService = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );

        // Mock MerchantSelector to return specific Merchant_Service__c records
        IMerchantSelector mockMerchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        // Setup mocking for mockAgreementsService
        mocks.startStubbing();
        mocks.when(mockAgreementsService.getDeactivatedAndCancelledAgreementAccountIds(agreements))
            .thenReturn(new Set<Id>{ accountId1 });

        // Setup mocking for mockMerchantSelector
        mocks.when(mockMerchantSelector.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                mockMerchantSelector.selectActiveServicesByAccountIds(
                    new Set<Id>{ accountId1 },
                    new Set<Id>{ contractId1 }
                )
            )
            .thenReturn(existingServices1);
        mocks.stopStubbing();

        // Apply the mocks to the application
        Application.SERVICE.setMock(IAgreementsService.class, mockAgreementsService);
        Application.SELECTOR.setMock(mockMerchantSelector);

        // Invoke the method to be tested
        List<List<Agreement__c>> agreementsListFromFlow = new List<List<Agreement__c>>{
            agreements
        };
        MerchantServicesService.setMxAgreedToProductValueNoFromFlow(agreementsListFromFlow);

        // Verify that the unit of work registered the updates
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1)).commitWork();
    }

    /**
     * @description To test setMxAgreedToProductValueNoFromFlow call
     * @JIRA #LEM-15980
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeactivatedAgreementsPassedThenSetMxAgreedToProductValueNo() {
        Id agreementId1 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id agreementId2 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id accountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId1 = fflib_IDGenerator.generate(Contract.SObjectType);

        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId1,
                Deactivation_Date__c = System.today()
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId2,
                Deactivation_Date__c = System.today()
            )
        };

        Merchant_Service__c merchantServiceRecordMarketPlace1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        Merchant_Service__c merchantServiceRecordMarketPlace2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        List<Merchant_Service__c> existingServices1 = new List<Merchant_Service__c>{
            merchantServiceRecordMarketPlace1,
            merchantServiceRecordMarketPlace2
        };

        // Mock AgreementsService to return specific deactivated and cancelled agreement account IDs
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsService mockAgreementsService = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );

        // Mock MerchantSelector to return specific Merchant_Service__c records
        IMerchantSelector mockMerchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        // Setup mocking for mockAgreementsService
        mocks.startStubbing();
        mocks.when(mockAgreementsService.getDeactivatedAndCancelledAgreementAccountIds(agreements))
            .thenReturn(new Set<Id>{ accountId1 });

        // Setup mocking for mockMerchantSelector
        mocks.when(mockMerchantSelector.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                mockMerchantSelector.selectActiveServicesByAccountIds(
                    new Set<Id>{ accountId1 },
                    new Set<Id>{ contractId1 }
                )
            )
            .thenReturn(existingServices1);
        mocks.stopStubbing();

        // Apply the mocks to the application
        Application.SERVICE.setMock(IAgreementsService.class, mockAgreementsService);
        Application.SELECTOR.setMock(mockMerchantSelector);

        // Invoke the method to be tested
        MerchantServicesService.setMxAgreedToProductValueNo(
            existingServices1,
            new Set<Id>{ accountId1 }
        );

        // Verify that the unit of work registered the updates
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1)).commitWork();
    }

    /**
     * @description It is used to test weather Merchant Services Records are
     * Deleted for Churned Merchant Contract Type.
     * @JIRA #LEM-23780
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChurnedMxServicesByContractIdsThenDeleteMxServices() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Fake subscription = new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.id, subscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1);

        Merchant_Service__c merchantServiceRecordMarketPlace = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', subscription)
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, PRODUCT_NAME_MARKETPLACE)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMerchantSelector mockMerchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantSelector.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                mockMerchantSelector.selectChurnedMxServicesByContractIds(new Set<Id>{ contractId })
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceRecordMarketPlace });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockMerchantSelector);
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = MerchantServicesService.deleteChurnedMxServices(
            new Set<Id>{ contractId },
            mockUOW
        );
        Test.stopTest();
        system.assertEquals(mockUOW, uow, INVALID_ASSERT_MESSAGE);
    }
}