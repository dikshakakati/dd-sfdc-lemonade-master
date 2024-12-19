/**
 * @author DoorDash
 * @date 03/22/2023
 * @description Test class for IntegrationRequestsService class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class IntegrationRequestsServiceImplTest {
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST = 'PROCESS_NEW_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessNewPosIrChunkSize';
    private static final String PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING = 'ProcessUpdatePosIrChunkSize';
    private static final String PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING = 'ProcessCooSameStoreChunkSize';
    // @jira LEM-10464
    private static Integer integrationRequestDeleteOlderThanNMonths = 6;
    private static Set<String> integrationRequestDeleteTypes = new Set<String>{
        'POS Requests',
        'Tablet Case Sync'
    };
    private static final String INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS = 'integrationRequestDeleteOlderThanNMonths';
    private static final String INTEGRATION_REQUEST_DELETE_TYPES = 'IntegrationRequestDeleteTypes';
    private static final String INTEGRATION_REQUEST_JOB_QUERY_LAST_N_DAYS = 'IntegrationRequestQueryLostNDays';
    private static final String INTEGRATION_REQUEST_STATUS_PROCESSED = 'Processed';

    //@jira LEM-10463
    private static final String UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS = 'UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS';
    private static final String PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING = 'ProcessTabletCaseSyncChunkSize';
    private static final String METADATA_VALUE = '3';
    private static final String CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST'; //LEM-13304
    private static final String ACTIVATION_CHECKLIST_CHUNK_SIZE = 'Activation_Checklist_Chunk_Size';
    private static final String SFDC_ORG_LEMONADE = 'Lemonade';
    private static final String SFDC_STATUS_PENDING = 'Pending';
    private static final String INTEGRATION_TYPE_FRAUD_EVENT = 'Fraud Event';
    private static final String INTEGRATION_TYPE_PLACEITFORME = 'Place It For Me';
    private static final String FRAUD_EVENT_CHUNK_SIZE = 'Fraud_Event_Chunk_Size';
    private static final String EVENT_TOPIC_FRAUD_EVENT_CHECK = 'EVENT_TOPIC_FRAUD_EVENT_CHECK';
    private static final String PLACEITFORME_EVENT_CHUNK_SIZE = 'PlaceItForMe_Event_Chunk_Size';
    private static final String EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION = 'PLACEITFORME_INBOUND_INTEGRATION';

    @isTest
    private static void testWhenChildIntReqUpatedThenUpdateParentFields() {
        // Create test data: Integration Requests
        Id intReqId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Id parentIntReqId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequestOld = new Integration_Request__c(
            Id = intReqId,
            Parent_Integration_Request__c = parentIntReqId,
            sfdc_status__c = 'Pending',
            Product_Status__c = 'created'
        );
        Integration_Request__c integrationRequestNew = new Integration_Request__c(
            Id = intReqId,
            Parent_Integration_Request__c = parentIntReqId,
            sfdc_status__c = 'Processed',
            Product_Status__c = 'completed'
        );
        Map<Id, Integration_Request__c> oldIntReq = new Map<Id, Integration_Request__c>{
            integrationRequestOld.Id => integrationRequestOld
        };
        List<Integration_Request__c> newIntReq = new List<Integration_Request__c>{
            integrationRequestNew
        };

        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UnitOfWork.setMock(uowMock);

        // Call the method under test
        Test.startTest();
        IntegrationRequestsService.updateParentIntRequest(oldIntReq, newIntReq);
        Test.stopTest();

        //-- verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Integration_Request__c.Id => parentIntReqId,
                        Integration_Request__c.Stage__c => 'completed'
                    }
                )
            );
    }
    @isTest
    private static void testWhenIntegrationRequestsReceivedThenMultipleNotifierEventPublished() {
        Id onboardingId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Integration_Request__c integrationRequestCreate = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Integration_Type__c = 'POS Requests',
            SFDC_Org__c = 'Lemonade',
            Action__c = 'CREATE',
            sfdc_status__c = 'Pending'
        );
        Integration_Request__c integrationRequestUpdate = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Integration_Type__c = 'POS Requests',
            SFDC_Org__c = 'Lemonade',
            Action__c = 'UPDATE',
            sfdc_status__c = 'Pending'
        );
        Integration_Request__c integrationRequestCoo = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Integration_Type__c = 'COO Same Store',
            sfdc_status__c = 'Pending',
            batch_Id__c = 'Batch001',
            Product_Status__c = 'created'
        );

        //@jira LEM-10463
        Integration_Request__c integrationRequestTabletCaseSync = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Onboarding_Id__c = onboardingId,
            Integration_Type__c = 'Tablet Case Sync',
            SFDC_Org__c = 'Lemonade',
            sfdc_status__c = 'Pending'
        );

        Integration_Request__c integrationRequestActivationChecklist = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Onboarding_Id__c = onboardingId,
            Integration_Type__c = 'Activation Checklist',
            SFDC_Org__c = 'Lemonade',
            sfdc_status__c = 'Pending'
        );

        Integration_Request__c integrationRequestFraudEvent = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Onboarding_Id__c = onboardingId,
            Integration_Type__c = INTEGRATION_TYPE_FRAUD_EVENT,
            SFDC_Org__c = SFDC_ORG_LEMONADE,
            sfdc_status__c = SFDC_STATUS_PENDING
        );
        Integration_Request__c integrationRequestPlaceItForMeEvent = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Onboarding_Id__c = null,
            Integration_Type__c = INTEGRATION_TYPE_PLACEITFORME,
            SFDC_Org__c = SFDC_ORG_LEMONADE,
            sfdc_status__c = SFDC_STATUS_PENDING
        );
        List<Integration_Request__c> newIntReq = new List<Integration_Request__c>{
            integrationRequestCreate,
            integrationRequestUpdate,
            integrationRequestCoo,
            integrationRequestTabletCaseSync,
            integrationRequestActivationChecklist,
            integrationRequestFraudEvent,
            integrationRequestPlaceItForMeEvent
        };

        Map<Id, Integration_Request__c> oldIntReq = new Map<Id, Integration_Request__c>();
        // -- return lists
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        //LEM-13304
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );

        List<String> payloadForCreate = new List<String>{
            JSON.serialize(integrationRequestCreate.Id)
        };
        List<String> payloadForUpdate = new List<String>{
            JSON.serialize(integrationRequestUpdate.Id)
        };

        List<String> payloadForCoo = new List<String>{ JSON.serialize(integrationRequestCoo.Id) };

        //@jira LEM-10463
        List<String> payloadForTabletCaseSync = new List<String>{ JSON.serialize(onboardingId) };
        List<String> payloadForActivationChecklist = new List<String>{
            JSON.serialize(integrationRequestActivationChecklist.Id)
        };
        List<String> payloadForFraudEvent = new List<String>{
            JSON.serialize(integrationRequestFraudEvent.Id)
        };
        List<String> payloadForPlaceItForMeEvent = new List<String>{
            JSON.serialize(integrationRequestPlaceItForMeEvent.Id)
        };
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        //@jira LEM-10463
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        //@jira LEM-10464
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS,
                    Configuration_Value__c = METADATA_VALUE
                )
            );

        mocks.when(mockStaticConfigurations.getInstanceValue(ACTIVATION_CHECKLIST_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(FRAUD_EVENT_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = FRAUD_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(PLACEITFORME_EVENT_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PLACEITFORME_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );

        //@jira LEM-10464
        mocks.when(mockStaticConfigurations.getInstanceValue(INTEGRATION_REQUEST_DELETE_TYPES))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_TYPES,
                    Configuration_Value__c = METADATA_VALUE
                )
            );

        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestCreate.Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForCreate);
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestUpdate.Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForUpdate);
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestCoo.Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForCoo);

        //@jira LEM-10463
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ onboardingId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForTabletCaseSync);
        mocks.when(
            notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                new Set<Id>{ integrationRequestActivationChecklist.Id },
                INTEGER.valueOf(METADATA_VALUE)
            )
        ).thenReturn(payloadForActivationChecklist);

        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestActivationChecklist.Id },
                    INTEGER.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForActivationChecklist);
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestFraudEvent.Id },
                    INTEGER.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForFraudEvent);
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ integrationRequestPlaceItForMeEvent.Id },
                    INTEGER.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloadForPlaceItForMeEvent);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        Test.startTest();

        IntegrationRequestsService.publishEventsForProcessing(oldIntReq, newIntReq, false);

        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    PROCESS_NEW_POS_INTEGRATION_REQUEST => payloadForCreate
                }
            );
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    PROCESS_UPDATE_POS_INTEGRATION_REQUEST => payloadForUpdate
                }
            );
        //@jira LEM-10463
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS => payloadForTabletCaseSync
                }
            );
        //LEM-13304
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    CREATE_ACTIVATION_CHECKLIST => payloadForActivationChecklist
                }
            );
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_FRAUD_EVENT_CHECK => payloadForFraudEvent
                }
            );
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PLACEITFORME_INBOUND_INTEGRATION => payloadForPlaceItForMeEvent
                }
            );
        Test.stopTest();
    }

    @isTest
    private static void testWhenSchedulerRunsThenIntegrationRequestRecordsDeleted() {
        Integration_Request__c intReqInstance = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            Batch_Id__c = 'Batch001',
            Product_status__c = 'completed',
            Integration_Type__c = 'POS Requests',
            CreatedDate = System.now().addMonths(-7),
            Sfdc_Status__c = 'Pending'
        );

        List<Integration_Request__c> intRequests = new List<Integration_Request__c>{
            intReqInstance
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIntegrationRequestsSelector mockIntegrationSelector = (IIntegrationRequestsSelector) mocks.mock(
            IntegrationRequestsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        DateTime integrationRequestDeleteOlderThanNMonthDate = System.now()
            .addMonths(-integrationRequestDeleteOlderThanNMonths);
        mocks.startStubbing();

        //@jira LEM-10464
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS,
                    Configuration_Value__c = '6'
                )
            );

        //@jira LEM-10464
        mocks.when(mockStaticConfigurations.getInstanceValue(INTEGRATION_REQUEST_DELETE_TYPES))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_TYPES,
                    Configuration_Value__c = 'POS Requests,Tablet Case Sync'
                )
            );

        mocks.when(mockIntegrationSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationSelector.selectIntegrationRequestsByIntegrationType(
                    integrationRequestDeleteTypes,
                    integrationRequestDeleteOlderThanNMonthDate
                )
            )
            .thenReturn(intRequests);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockIntegrationSelector);
        Application.UnitOfWork.setMock(mockUow);

        Test.startTest();
        IntegrationRequestsService.deleteOldRecords();
        Test.stopTest();

        /* ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow))
            .registerDeleted(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Integration_Request__c.Id => intReqInstance.Id
                        }
                    }
                )
            ); */
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /*
    @description added test method to process the PE's for the MDS Store Sync IR's @LEM-11258
    */
    @isTest
    private static void testWhenMdsSyncRecievedThenPlatformEventFired() {
        Id intReqId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c intReqInstance = new Integration_Request__c(
            Id = intReqId,
            Batch_Id__c = 'Batch001',
            Integration_Type__c = 'MDS Store Sync',
            CreatedDate = System.now().addMonths(-7),
            Sfdc_Status__c = 'Pending'
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_NEW_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_UPDATE_POS_INTEGRATION_REQUEST_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    ACTIVATION_CHECKLIST_CHUNK_SIZE
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EVENT_TOPIC_FRAUD_EVENT_CHECK))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EVENT_TOPIC_FRAUD_EVENT_CHECK,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(INTEGRATION_REQUEST_DELETE_TYPES))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_TYPES,
                    Configuration_Value__c = 'POS Requests,Tablet Case Sync'
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_COO_SAME_STORE_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        //@jira LEM-10463
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PROCESS_TABLET_CASE_SYNC_CHUNK_SIZE_SETTING,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        //@jira LEM-10464
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(FRAUD_EVENT_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = FRAUD_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(PLACEITFORME_EVENT_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PLACEITFORME_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        IntegrationRequestsService.publishEventsForProcessing(
            new Map<Id, Integration_Request__c>(),
            new List<Integration_Request__c>{ intReqInstance },
            false
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        MDS_Sync_Event__e.Integration_Request_Id__c => intReqId
                    }
                )
            );
    }

    /*
    @description To test Integration Requests Status updated when Integration Request Ids
    and Status value received.
    */
    @isTest
    private static void testWhenIntegrationRequestIdsAndStatusReceivedThenUpdateStatus() {
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        IntegrationRequestsService.updateIntegrationRequestsSFDCStatus(
            new Set<Id>{ integrationRequestId },
            INTEGRATION_REQUEST_STATUS_PROCESSED
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Integration_Request__c.Id => integrationRequestId,
                            Integration_Request__c.Sfdc_Status__c => INTEGRATION_REQUEST_STATUS_PROCESSED,
                            Integration_Request__c.Stage_Status__c => INTEGRATION_REQUEST_STATUS_PROCESSED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}