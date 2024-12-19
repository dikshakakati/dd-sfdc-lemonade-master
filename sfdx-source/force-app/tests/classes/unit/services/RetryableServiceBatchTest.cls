/**
 * @author Deloitte
 * @date 02/03/2022
 * @description Test class for RetryCalloutsBatch
 */
@isTest
private with sharing class RetryableServiceBatchTest {
    private static final String INTEGRATION_OUTBOUND_SERVICE_CLASSNAME = 'IIntegrationOutboundService';
    private static final Integer METADATA_VALUE = 5;
    private static final String MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET = 'Tablet_Outbound_Integration';
    private static final String MX_ORDER_STATUS_INVALID = 'Invalid';
    private static final String USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';

    /**
     * @description To test retry process is initated when failed interface transaction exists
     * for Email outbound integration.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @istest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBatchRetryCalloutsTestCallsThenVerifyRetry() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        List<Interface_Transaction__c> interfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInterfaceTransactionSelector selectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionConfigSelector interfaceConfigSelectorMock = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IMerchantOrdersSelector merchantOrdersSelectorMock = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IIntegrationOutboundService serviceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(selectorMock.queryLocatorReadyToRetry()).thenReturn(interfaceTransactions);
        mocks.when(selectorMock.selectByOriginRecordIds(new Set<String>()))
            .thenReturn(new List<Interface_Transaction__c>{});
        mocks.when(interfaceConfigSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(interfaceConfigSelectorMock.selectAllActiveInterfaceTransactionCongis())
            .thenReturn(
                new List<Interface_Transaction_Configuration__mdt>{
                    new Interface_Transaction_Configuration__mdt(
                        Enable_Retry__c = true,
                        Label = USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION,
                        Interface_Transaction_Name__c = USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION,
                        Retry_Limit__c = METADATA_VALUE,
                        Service_Class_Name__c = INTEGRATION_OUTBOUND_SERVICE_CLASSNAME
                    )
                }
            );
        mocks.when(merchantOrdersSelectorMock.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(merchantOrdersSelectorMock.selectById(new Set<Id>()))
            .thenReturn(new List<MX_Order__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(interfaceConfigSelectorMock);
        Application.SELECTOR.setMock(merchantOrdersSelectorMock);
        Application.SERVICE.setMock(IIntegrationOutboundService.class, serviceMock);
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);
        RetryableServiceBatch batch = new RetryableServiceBatch();
        batch.start(null);
        batch.execute(null, interfaceTransactions);
        batch.finish(null);
        batch.execute(null);
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .retryPayloadGeneration(new List<MX_Order__c>{});
        ((IIntegrationOutboundService) mocks.verify(serviceMock, 1)).retry(interfaceTransactions);
    }

    /**
     * @description To test retry process is not initiated when failed interface transaction exists
     * for Tablet Mx order with Status 'Invalid'.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @istest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMxOrderStatusInvalidThenDoNotRetry() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        List<Interface_Transaction__c> interfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET,
                Record_Id__c = mxOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInterfaceTransactionSelector selectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionConfigSelector interfaceConfigSelectorMock = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IMerchantOrdersSelector merchantOrdersSelectorMock = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IIntegrationOutboundService serviceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(selectorMock.queryLocatorReadyToRetry()).thenReturn(interfaceTransactions);
        mocks.when(selectorMock.selectByOriginRecordIds(new Set<String>{ mxOrderId }))
            .thenReturn(interfaceTransactions);
        mocks.when(interfaceConfigSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(interfaceConfigSelectorMock.selectAllActiveInterfaceTransactionCongis())
            .thenReturn(
                new List<Interface_Transaction_Configuration__mdt>{
                    new Interface_Transaction_Configuration__mdt(
                        Enable_Retry__c = true,
                        Label = MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET,
                        Interface_Transaction_Name__c = MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET,
                        Retry_Limit__c = METADATA_VALUE,
                        Service_Class_Name__c = INTEGRATION_OUTBOUND_SERVICE_CLASSNAME
                    )
                }
            );
        mocks.when(merchantOrdersSelectorMock.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(merchantOrdersSelectorMock.selectById(new Set<Id>{ mxOrderId }))
            .thenReturn(
                new List<MX_Order__c>{
                    new MX_Order__c(Id = mxOrderId, Status__c = MX_ORDER_STATUS_INVALID)
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(interfaceConfigSelectorMock);
        Application.SELECTOR.setMock(merchantOrdersSelectorMock);
        Application.SERVICE.setMock(IIntegrationOutboundService.class, serviceMock);
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);
        RetryableServiceBatch batch = new RetryableServiceBatch();
        batch.start(null);
        batch.execute(null, interfaceTransactions);
        batch.finish(null);
        batch.execute(null);
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .retryPayloadGeneration(
                new List<MX_Order__c>{
                    new MX_Order__c(Id = mxOrderId, Status__c = MX_ORDER_STATUS_INVALID)
                }
            );
        ((IIntegrationOutboundService) mocks.verify(serviceMock, 1))
            .retry(new List<Interface_Transaction__c>());
    }
}