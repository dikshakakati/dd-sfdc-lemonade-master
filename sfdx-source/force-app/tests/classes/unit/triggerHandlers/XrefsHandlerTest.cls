/**
 * @description This is test class for Xref__c Trigger handler class
 * @author ATG
 * @date 2022-06-29
 */
@isTest(seeAllData=false)
public class XrefsHandlerTest {
    public static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final string BUSINESS_ID = '13346';
    private static final String EVENT_TOPIC_UPDATE_WORKSTEP_STATUS = 'UPDATE_SETUP_BUSINESS_WORKSTEP_STATUS';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String SETUP_BUSINESS_WORKSTEP_UPDATE_PAYLOAD_CHUNK_SIZE = 'Setup_Business_WS_Payload_Chunk_Size';
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String STATUS_COO_SUCCESS = 'COO Success';
    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATION = 'XREF_INTEGRATE';
    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_DEACTIAVTE_COO = 'XREF_DEACTIVATE_COO';
    private static final String EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATE_COO = 'XREF_INTEGRATE_COO';
    public static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    private static final String XREF_ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String STATUS_PLANNING = 'Planning';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKPLAN_OWNER_NAME = 'O&A User';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String FAKE_EXTERNAL_ID = '123456';
    public static final String LAST_COMPLETED_CONFIGURATION_CREATED = 'Business Configuration reated';
    private static final String EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST = 'UPDATE_RATE_CHANGE_REQUEST';
    private static final String METADATA_INSTANCE_NAME = 'Rate_Change_Request_Payload_Chunk_Size';
    private static final String METADATA_VALUE = '3';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_INACTIVE = 'Inactive';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';

    /**
     * @description To test method call on Xref__c update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenPublishPlatformEvent() {
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id xrefId3 = Fake.generateId(Xref__c.class);
        Id xrefId4 = Fake.generateId(Xref__c.class);
        Id xrefId5 = Fake.generateId(Xref__c.class);

        Id xrefIdInactive = Fake.generateId(Xref__c.class);

        List<Xref__c> xrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            ),
            new Xref__c(
                Id = xrefId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_COO_INTEGRATION
            ),
            new Xref__c(
                Id = xrefId3,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION,
                Inactive_Xref__c = xrefIdInactive
            ),
            new Xref__c(
                Id = xrefId4,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_COO_SUCCESS
            ),
            new Xref__c(
                Id = xrefId5,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION,
                Inactive_Xref__c = xrefIdInactive,
                External_ID__c = FAKE_EXTERNAL_ID
            )
        };

        List<Xref__c> oldXrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_NEW
            ),
            new Xref__c(
                Id = xrefId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_NEW
            ),
            new Xref__c(
                Id = xrefId3,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_NEW,
                Inactive_Xref__c = xrefIdInactive
            ),
            new Xref__c(
                Id = xrefId4,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_NEW
            ),
            new Xref__c(
                Id = xrefId5,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_NEW,
                Inactive_Xref__c = xrefIdInactive,
                External_ID__c = FAKE_EXTERNAL_ID
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefIntegrationService xrefIntegrationMock = (IXrefIntegrationService) mocks.mock(
            IXrefIntegrationService.class
        );
        Application.SERVICE.setMock(IXrefIntegrationService.class, xrefIntegrationMock);

        fflib_SObjectDomain.Test.Database.onUpdate(xrefList, new Map<Id, SObject>(oldXrefList));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Xref__c>{ xrefList[0], xrefList[4] },
                EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATION
            );
        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Xref__c>{ xrefList[1] },
                EXTERNAL_NOTIFIER_TOPIC_XREF_DEACTIAVTE_COO
            );
        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Xref__c>{ xrefList[2] },
                EXTERNAL_NOTIFIER_TOPIC_XREF_INTEGRATE_COO
            );
        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .processCOOSuccess(new List<Xref__c>{ xrefList[3] });
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenUpdateWorkSteps() {
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        List<Xref__c> xrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_SUCCESS
            ),
            new Xref__c(
                Id = xrefId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_FAILURE
            )
        };

        List<Xref__c> oldXrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            ),
            new Xref__c(
                Id = xrefId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            )
        };

        List<Xref__c> successXRefs = new List<Xref__c>{ xrefList[0] };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        IActivationOrdersService activationOrderServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrderServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(xrefList, new Map<Id, SObject>(oldXrefList));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IWorkStepIntegrationStatusService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnXrefStatusChange(xrefList);

        ((IActivationOrdersService) mocks.verify(activationOrderServiceMock, 1))
            .activateOrderProductsOnXrefSuccess(successXRefs);
    }

    /**
     * @description It is used to test whether the update worksteps is invoked when the
     * integration status on Xref is updated to 'Waiting for Business'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefIntegrationStatusUpdatedToWaitingForBusinessThenInvokeUpdateWorkSteps() {
        Id xrefWithSuccessIntegrationStatus = Fake.generateId(Xref__c.class);
        Id xrefWithWaitingForBusinessIntegrationStatus = Fake.generateId(Xref__c.class);

        List<Xref__c> newXrefs = new List<Xref__c>{
            new Xref__c(
                Id = xrefWithSuccessIntegrationStatus,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_SUCCESS
            ),
            new Xref__c(
                Id = xrefWithWaitingForBusinessIntegrationStatus,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_WAITING_FOR_BUSINESS
            )
        };

        List<Xref__c> oldXrefs = new List<Xref__c>{
            new Xref__c(
                Id = xrefWithSuccessIntegrationStatus,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            ),
            new Xref__c(
                Id = xrefWithWaitingForBusinessIntegrationStatus,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newXrefs, new Map<Id, SObject>(oldXrefs));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
        ((IWorkStepIntegrationStatusService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnXrefStatusChange(newXrefs);
    }

    /**
     * @description To test Xref__c Trigger
     */
    @isTest
    private static void testWhenXrefInsertedThenTriggerIsCalled() {
        Account testAccount = TestDataFactory.createAccount(true);

        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = testAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            External_ID__c = '123-ABC'
        );
        insert xref;

        System.assertNotEquals(null, xref.Id, 'Id is null');
    }

    /**
     * @description To test Work step status update method call on Xref__c creation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefCreatedThenUpdateWorkStepStatus() {
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id businessReferenceId2 = Fake.generateId(Business_Reference__c.class);
        Id mdsXrefId = Fake.generateId(Xref__c.class);
        Id mdsCateringXrefId = Fake.generateId(Xref__c.class);

        List<Xref__c> xrefList = new List<Xref__c>{
            new Xref__c(
                Id = mdsXrefId,
                Business_Reference__c = businessReferenceId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS
            ),
            new Xref__c(
                Id = mdsCateringXrefId,
                Business_Reference__c = businessReferenceId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS_CATERING
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(xrefList);
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_WORKSTEP_STATUS => new List<String>{
                        JSON.serialize(new List<Id>{ mdsXrefId, mdsCateringXrefId })
                    }
                }
            );
    }

    /**
     * @description To test Work step status update method call on Xref__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefUpdatedThenUpdateWorkStepStatus() {
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id businessReferenceId2 = Fake.generateId(Business_Reference__c.class);
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        List<Xref__c> xrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                Business_Reference__c = businessReferenceId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS
            ),
            new Xref__c(
                Id = xrefId2,
                Business_Reference__c = businessReferenceId2,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS_CATERING
            )
        };

        List<Xref__c> xrefListOld = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                Business_Reference__c = null,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS
            ),
            new Xref__c(
                Id = xrefId2,
                Business_Reference__c = null,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS_CATERING
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(xrefList, new Map<Id, SObject>(xrefListOld));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_WORKSTEP_STATUS => new List<String>{
                        JSON.serialize(new List<Id>{ xrefId1, xrefId2 })
                    }
                }
            );
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedForTypeDriveThenUpdateWorkSteps() {
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);

        List<Xref__c> oldXrefRecForDrive = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Business_Reference__c, businessReferenceId1)
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_READY_FOR_INTEGRATION)
                .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_DRIVE_DB)
                .toSObject()
        };

        List<Xref__c> newXrefRecForDrive = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Business_Reference__c, businessReferenceId1)
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_SUCCESS)
                .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_DRIVE_DB)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepStatusForDriveService workStepServiceMock = (IWorkStepStatusForDriveService) mocks.mock(
            IWorkStepStatusForDriveService.class
        );
        Application.SERVICE.setMock(IWorkStepStatusForDriveService.class, workStepServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newXrefRecForDrive,
            new Map<Id, SObject>(oldXrefRecForDrive)
        );
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        Map<Id, List<Xref__c>> busRefIdXrefRecMap = new Map<Id, List<Xref__c>>();
        busRefIdXrefRecMap.Put(businessReferenceId1, newXrefRecForDrive);

        ((IWorkStepStatusForDriveService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnXrefStatusChangeForDrive(busRefIdXrefRecMap);
    }

    /**
     * @description test handling store id copy to work order
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningStatusSuccessThenCallServiceMethodToCopyStoreId() {
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);

        List<Xref__c> oldXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_READY_FOR_INTEGRATION)
                .toSObject()
        };

        List<Xref__c> newXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_SUCCESS)
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Business_Reference__c, businessReferenceId1)
                .setField(Xref__c.External_ID_Source__c, 'MDS')
                .setField(Xref__c.External_ID__c, 1)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newXrefRecs, new Map<Id, SObject>(oldXrefRecs));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .updateStoreIdsOnChildWorkOrders(new Set<Id>{ accountId });
    }

    /*
     * @description test for handling the provisioning error message updates on xref__c object
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningErrorMessageUpdatedThenCallBusinessFriendlyService() {
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        string provisioningMessage = 'Test Integration Message';

        List<Xref__c> newXrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Provisioning_Error_Message__c, provisioningMessage)
                .toSObject()
        };

        List<Xref__c> oldXrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Provisioning_Error_Message__c, provisioningMessage + ' test')
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGetBusinessFriendlyMessageService serviceMock = (IGetBusinessFriendlyMessageService) mocks.mock(
            IGetBusinessFriendlyMessageService.class
        );
        Application.SERVICE.setMock(IGetBusinessFriendlyMessageService.class, serviceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newXrefs, new Map<Id, SObject>(oldXrefs));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((IGetBusinessFriendlyMessageService) mocks.verify(serviceMock, 1))
            .getMessageDetails(provisioningMessage, Xrefs.INTEGRATION_TYPE);
    }

    /**
     * @description To test update Store Account Activation Status
     * @jira# LEM-12911
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefUpdateThenUpdateStoreAccountActivationStatus() {
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id xRefId2 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessReferenceId2 = Fake.generateId(Business_Reference__c.class);
        Map<String, String> mapofStringOld = new Map<String, String>();
        mapofStringOld.put('Name', 'XYX');
        mapofStringOld.put('Xref_Status__c', 'In Active');
        String jsonStringOld = JSON.serialize(mapofStringOld);
        Map<String, String> mapofStringNew = new Map<String, String>();
        mapofStringNew.put('Name', 'YYY');
        mapofStringNew.put('Xref_Status__c', 'Active');
        String jsonStringNew = JSON.serialize(mapofStringNew);

        List<Xref__c> oldXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_READY_FOR_INTEGRATION)
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.MDS_Last_Synced__c, jsonStringOld)
                .setField(Xref__c.Date_of_Status_Change__c, System.now())
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId2)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId2)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId2)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_READY_FOR_INTEGRATION)
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.MDS_Last_Synced__c, jsonStringOld)
                .setField(Xref__c.Date_of_Status_Change__c, System.now())
                .toSObject()
        };

        List<Xref__c> newXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_SUCCESS)
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Business_Reference__c, businessReferenceId1)
                .setField(Xref__c.External_ID_Source__c, 'MDS')
                .setField(Xref__c.MDS_Last_Synced__c, jsonStringNew)
                .setField(Xref__c.Date_of_Status_Change__c, System.now())
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId2)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId2)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId2)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_SUCCESS)
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Business_Reference__c, businessReferenceId2)
                .setField(Xref__c.External_ID_Source__c, 'MDS')
                .setField(Xref__c.MDS_Last_Synced__c, jsonStringNew)
                .setField(Xref__c.Date_of_Status_Change__c, System.now())
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newXrefRecs, new Map<Id, SObject>(oldXrefRecs));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
    }

    /**
     * @description test sending platform events for rate change request update
     * on after update of XRef__c.Integration_Status__C
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenIntegationStatusReadyForIntegrationThenSendRateChangeRequestPlatformEvent() {
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);

        List<Xref__c> oldXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_FAILURE)
                .setParent(
                    'Salesforce_Account_Name__r',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.Rate_Change_Request__c, rcrId)
                )
                .toSObject()
        };

        List<Xref__c> newXrefRecs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
                .setField(Xref__c.Salesforce_Account_ID__c, accountId)
                .setField(Xref__c.External_ID__c, 'abc123')
                .setField(Xref__c.Integration_Status__c, XrefsHandler.STATUS_READY_FOR_INTEGRATION)
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Associated_Rate_Change_Request__c, rcrId)
                .setParent(
                    'Salesforce_Account_Name__r',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.Rate_Change_Request__c, rcrId)
                )
                .toSObject()
        };

        List<Id> rcrIdsChunk = new List<Id>{ rcrId };

        List<String> payloads = new List<String>{ JSON.serialize(rcrIdsChunk) };

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

        mocks.startStubbing();

        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(METADATA_INSTANCE_NAME))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = METADATA_INSTANCE_NAME,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    SETUP_BUSINESS_WORKSTEP_UPDATE_PAYLOAD_CHUNK_SIZE
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = SETUP_BUSINESS_WORKSTEP_UPDATE_PAYLOAD_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ rcrId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(newXrefRecs, new Map<Id, Xref__c>(oldXrefRecs));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);

        ((INotifierEventsPayloadGenerationService) mocks.verify(
                notifierEventsPayloadGenerationServiceMock,
                1
            ))
            .generateChunkedPayloadsBySobjectIds(
                new Set<Id>{ rcrId },
                Integer.valueOf(METADATA_VALUE)
            );
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{ EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST => payloads }
            );
    }

    /**
     * @description To test the update Work Steps Status update is not initiated when Xref is created
     * with Integration Status 'Waiting for Business' for SMB Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWaitingForBusinessXrefCreatedForSMBAccountThenDoNotInitiateWorkStepStatusUpdate() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        List<Xref__c> xrefList = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xrefId)
                .setField(Xref__c.Business_Reference__c, businessReferenceId)
                .setField(Xref__c.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
                .setField(Xref__c.External_ID_Source__c, XrefsHandler.EXTERNAL_ID_SOURCE_MDS)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);

        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(xrefList);
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
        Test.stopTest();

        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_WORKSTEP_STATUS => new List<String>{
                        JSON.serialize(new List<Id>{ xrefId })
                    }
                }
            );
        ((IWorkStepIntegrationStatusService) mocks.verify(workStepServiceMock, 0))
            .updateWorkStepsStatusOnXrefStatusChange(xrefList);
    }

    /**
     * @description To test the update Work Steps Status update is initiated when Xref is created
     * with Integration Status 'Waiting for Business' for non SMB Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWaitingForBusinessXrefCreatedForNonSMBAccountThenDoNotInitiateWorkStepStatusUpdate() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        List<Xref__c> xrefList = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xrefId)
                .setField(Xref__c.Business_Reference__c, businessReferenceId)
                .setField(Xref__c.External_ID_Source__c, XrefsHandler.EXTERNAL_ID_SOURCE_MDS)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );

        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);

        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(xrefList);
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
        Test.stopTest();

        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_WORKSTEP_STATUS => new List<String>{
                        JSON.serialize(new List<Id>{ xrefId })
                    }
                }
            );
        ((IWorkStepIntegrationStatusService) mocks.verify(workStepServiceMock, 0))
            .updateWorkStepsStatusOnXrefStatusChange(xrefList);
    }

    /**
     * @description To test when Xref inserted with External Id Source equal MDS and Status is
     * Active then update MDS Activation on Account to true.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefInsertedWithActiveMDSThenUpdateMDSActivationOnAccountToTrue() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account> accounts = new List<Account>{
            new Account(Id = accountId, Name = 'Test Account 1')
        };
        List<Account> accountsResultList = new List<Account>{
            new Account(Id = accountId, Is_MDS_Activated__c = true)
        };

        Xref__c xref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.External_ID__c, FAKE_EXTERNAL_ID)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Xref_Status__c, STATUS_ACTIVE)
            .setField(Xref__c.Salesforce_Account_Name__c, accounts[0].Id)
            .setFakeId()
            .toSObject();
        List<Xref__c> xrefList = new List<Xref__c>{ xref1 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(AccountsService.class, accountsServiceMock);

        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(xrefList);
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
        Test.stopTest();

        ((IAccountsService) mocks.verify(accountsServiceMock, 1))
            .updateAccountsForActivatingAndDeactivatingMDSXrefs(
                new List<Account>{ accountsResultList[0] }
            );
        ((IAccountsService) mocks.verify(accountsServiceMock, 0))
            .checkAccountsForDeactivation(new Set<Id>{ accounts[0].Id });
    }

    /**
     * @description To test when Xref updated with Inactive MDS External Id Source then
     * update MDS Activation on Account to false.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefUpdatedWithInActiveMDSThenUpdateMDSActivationOnAccountToFalse() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId1 = Fake.generateId(Xref__c.class);
        List<Account> accounts = new List<Account>{
            new Account(Id = accountId, Name = 'Test Account 1')
        };
        List<Account> accountsResultList = new List<Account>{
            new Account(Id = accountId, Is_MDS_Activated__c = false)
        };
        List<Xref__c> newXrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION,
                Xref_Status__c = STATUS_INACTIVE,
                Salesforce_Account_Name__c = accounts[0].Id
            )
        };

        List<Xref__c> oldXrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                External_ID_Source__c = XrefsHandler.EXTERNAL_ID_SOURCE_MDS,
                Integration_Status__c = STATUS_READY_FOR_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsService accountsServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(AccountsService.class, accountsServiceMock);
        mocks.startStubbing();
        mocks.when(accountsServiceMock.checkAccountsForDeactivation(new Set<Id>{ accounts[0].Id }))
            .thenReturn(new Set<Id>{ accounts[0].Id });
        mocks.stopStubbing();

        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(newXrefList, new Map<Id, SObject>(oldXrefList));
        fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
        Test.stopTest();

        ((IAccountsService) mocks.verify(accountsServiceMock, 1))
            .updateAccountsForActivatingAndDeactivatingMDSXrefs(
                new List<Account>{ accountsResultList[0] }
            );
        ((IAccountsService) mocks.verify(accountsServiceMock, 1))
            .checkAccountsForDeactivation(new Set<Id>{ accounts[0].Id });
    }
}