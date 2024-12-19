/**
 * @author Deloitte
 * @date 14/09/2023
 * @description Test class for RateChangeRequestServiceImpl class.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class RateChangeRequestServiceImplTest {
    private static final String ACTIVATION_INITIATED = 'Activation Initiated';
    private static final String AGREEMENT_EVENTS_CHUNK_SIZE = 'Agreement_Events_Chunk_Size';
    private static final Integer AGREEMENT_EVENTS_CHUNK_SIZE_RECORD = 50;
    private static final String STATUS_CANCELLED = 'Canceled';
    private static final String APPROVED = 'Approved';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final Date TODAY_DATE = System.today();
    private static final String ASSERT_MESSAGE_UPDATED_RATE_CHANGE_COMPLETE = 'Unexpected result: Rate change request is not completed';
    private static final String READY_FOR_ACTIVATION = 'Ready for Activation';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'CREATE_ACTIVATION_ORDER_AND_PRODUCTS';
    private static final String EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST = 'UPDATE_RATE_CHANGE_REQUEST';
    private static final String METADATA_INSTANCE_NAME = 'Activation_Order_Payload_Chunk_Size';
    private static final String METADATA_VALUE = '3';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP = 'Create_Activation_Order_Products_ARP';

    @isTest
    private static void testWhenAllSubscriptionRateChangesAreCompletedThenRCRisCompleted() {
        //ARRANGE
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c rateChangeRequestinstance = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Id, rateChangeReqId)
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .setField(Rate_Change_Request__c.Order_Products_Updated__c, false)
            .setField(Rate_Change_Request__c.Associated_stores_updated__c, true)
            .setChildren(
                'Subscription_Rate_Changes__r',
                new List<Fake>{
                    new Fake(Subscription_Rate_Change__c.class)
                        .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
                        .setField(
                            Subscription_Rate_Change__c.Rate_Change_Request__c,
                            rateChangeReqId
                        )
                        .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '53')
                        .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '43')
                        .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
                        .setField(Subscription_Rate_Change__c.Update_complete__c, true)
                }
            )
            .toSObject();

        Subscription_Rate_Change__c subscriptionRateChangeRequest = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeReqId)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '53')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '43')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
            .setField(Subscription_Rate_Change__c.Update_complete__c, true)
            .setParent(
                'Rate_Change_Request__r',
                new Fake(Rate_Change_Request__c.class)
                    .setField(Rate_Change_Request__c.Id, rateChangeReqId)
                    .setField(Rate_Change_Request__c.Contract__c, contractId)
                    .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
                    .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
                    .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
                    .setField(Rate_Change_Request__c.Status__c, APPROVED)
            )
            .toSObject();

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.add(subscriptionRateChangeRequest);

        List<Rate_Change_Request__c> rateChangeRequestsList = new List<Rate_Change_Request__c>();
        rateChangeRequestsList.add(rateChangeRequestinstance);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IRateChangeRequestSelector rateChangeSelectorMock = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(rateChangeSelectorMock.sObjectType())
            .thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.when(
                rateChangeSelectorMock.selectRateChangeRequestById(new Set<Id>{ rateChangeReqId })
            )
            .thenReturn(rateChangeRequestsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(rateChangeSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        RateChangeRequestService.setRateChangeRequestComplete(subscriptionRateChangeRequests);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Rate_Change_Request__c.Id => rateChangeRequestsList[0].Id,
                            Rate_Change_Request__c.Order_Products_Updated__c => true,
                            Rate_Change_Request__c.Activation_Status__c => READY_FOR_ACTIVATION
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenAllStoresAreUpdatedThenRCRStoreUpdatedFlagIsTrue() {
        //ARRANGE
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c rateChangeRequestinstance = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Id, rateChangeReqId)
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .setField(Rate_Change_Request__c.Order_Products_Updated__c, true)
            .setChildren(
                'Subscription_Rate_Changes__r',
                new List<Fake>{
                    new Fake(Subscription_Rate_Change__c.class)
                        .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
                        .setField(
                            Subscription_Rate_Change__c.Rate_Change_Request__c,
                            rateChangeReqId
                        )
                        .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '53')
                        .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '43')
                        .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
                        .setField(Subscription_Rate_Change__c.Update_complete__c, true)
                }
            )
            .toSObject();

        List<Rate_Change_Request__c> rateChangeRequestsList = new List<Rate_Change_Request__c>();
        rateChangeRequestsList.add(rateChangeRequestinstance);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IRateChangeRequestSelector rateChangeSelectorMock = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(rateChangeSelectorMock.sObjectType())
            .thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.when(
                rateChangeSelectorMock.selectRateChangeRequestById(new Set<Id>{ rateChangeReqId })
            )
            .thenReturn(rateChangeRequestsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(rateChangeSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        RateChangeRequestService.setRateChangeRequestStoreUpdatedFlagTrue(rateChangeReqId);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Rate_Change_Request__c.Id => rateChangeRequestsList[0].Id,
                            Rate_Change_Request__c.Activation_Status__c => READY_FOR_ACTIVATION
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test method call on Order update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRateChangeRequestUpdatedThenCallPublishCreateActivationOrders() {
        Id accountId = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id agreementId = Fake.generateId(Agreement__c.class);
        Id agreementId2 = Fake.generateId(Agreement__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c rateChangeRequest = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .setFakeId()
            .toSObject();

        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, accountId)
                .setField(Agreement__c.Id, agreementId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.Rate_Change_Request__c, rcrId)
                )
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, accountId2)
                .setField(Agreement__c.Id, agreementId2)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId2)
                        .setField(Account.Rate_Change_Request__c, rcrId)
                )
                .toSObject()
        };

        Static_Configurations__mdt agreementMetadta = new Static_Configurations__mdt(
            DeveloperName = AGREEMENT_EVENTS_CHUNK_SIZE,
            MasterLabel = AGREEMENT_EVENTS_CHUNK_SIZE,
            Configuration_Value__c = String.valueOf(AGREEMENT_EVENTS_CHUNK_SIZE_RECORD)
        );

        List<Id> agreementIdsChunk1 = new List<Id>{ agreements[0].Id, agreements[1].Id };

        List<String> payloads = new List<String>{ JSON.serialize(agreementIdsChunk1) };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAgreementsSelector mockAgreementsSelector = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );

        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );

        mocks.startStubbing();
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ agreements[0].Id, agreements[1].Id },
                    AGREEMENT_EVENTS_CHUNK_SIZE_RECORD
                )
            )
            .thenReturn(payloads);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(AGREEMENT_EVENTS_CHUNK_SIZE))
            .thenReturn(agreementMetadta);
        mocks.when(mockAgreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                mockAgreementsSelector.selectStoreAgreementsByRcrIds(
                    new Set<Id>{ rateChangeRequest.Id }
                )
            )
            .thenReturn(agreements);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAgreementsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );

        Test.startTest();
        RateChangeRequestService.publishCreateActivationOrdersNotifierEvent(
            new Set<Id>{ rateChangeRequest.Id }
        );
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = JSON.serialize(
                        new List<Id>{ agreements[0].Id, agreements[1].Id }
                    ),
                    Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP
                )
            );
    }

    /**
     * @description To test method call on Rate Change Request update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXRefIsReadyForIntegrationThenCallUpdateRateChangeRequestAsActivationInitiated() {
        Id contractId = Fake.generateId(Contract.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c rateChangeRequest = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Id, rcrId)
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, READY_FOR_ACTIVATION)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);

        String eventPayload = JSON.serialize(new Set<Id>{ rateChangeRequest.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = 'UPDATE_RATE_CHANGE_REQUEST'
        );

        IRateChangeRequestSelector mockRateChangeRequestSelector = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );

        List<Rate_Change_Request__c> rateChangeRequestsList = new List<Rate_Change_Request__c>();
        rateChangeRequestsList.add(rateChangeRequest);

        mocks.startStubbing();
        mocks.when(mockRateChangeRequestSelector.sObjectType())
            .thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.when(
                mockRateChangeRequestSelector.selectRateChangeRequestById(
                    new Set<Id>{ rateChangeRequest.Id }
                )
            )
            .thenReturn(rateChangeRequestsList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockRateChangeRequestSelector);

        Test.startTest();
        RateChangeRequestService.execute(new List<Notifier__e>{ mockNotifierEvent });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Rate_Change_Request__c.Id => rateChangeRequestsList[0].Id,
                            Rate_Change_Request__c.Activation_Status__c => ACTIVATION_INITIATED
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test method call on Rate Change Request update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBatchJobExecutedThenCallupdateRateChangeRequestToCancelled() {
        Id contractId = Fake.generateId(Contract.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c rateChangeRequest = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Id, rcrId)
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, READY_FOR_ACTIVATION)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);

        IRateChangeRequestSelector mockRateChangeRequestSelector = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );

        List<Rate_Change_Request__c> rateChangeRequestsList = new List<Rate_Change_Request__c>();
        rateChangeRequestsList.add(rateChangeRequest);

        mocks.startStubbing();
        mocks.when(mockRateChangeRequestSelector.sObjectType())
            .thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockRateChangeRequestSelector);

        Test.startTest();
        RateChangeRequestService.updateRateChangeRequestToCancelled(
            new List<Rate_Change_Request__c>{ rateChangeRequest }
        );
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Rate_Change_Request__c.Id => rateChangeRequestsList[0].Id,
                            Rate_Change_Request__c.Status__c => STATUS_CANCELLED
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}