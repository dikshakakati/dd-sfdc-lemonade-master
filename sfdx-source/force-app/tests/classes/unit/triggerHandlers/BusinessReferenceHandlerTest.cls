/**
 * @description This is test class for Business_Reference__c Trigger handler class
 * @author ATG
 * @date 2022-06-399.
 */
@isTest(seeAllData=false)
public class BusinessReferenceHandlerTest {
    private static final String DRIVE_WITH_MPBZID_YES = 'Yes';
    private static final String EXTERNAL_ID_DWH = '123456';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION = 'EBID_INTEGRATE';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO = 'EBID_INTEGRATE_COO';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING = 'EBID_WH_INTEGRATE';
    private static final String LAST_COMPLETED_STEP_CONFIGURATION_CREATED = 'Business Configuration Created';
    private static final String LAST_COMPLETED_STEP_USER_CREATED = 'Business and User Created';
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final string TRIGGER_CONTEXT_BEFORE = 'Before';

    /**
     * @description To test method call on Business_Reference__c insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessReferenceInsertedThenPublishPlatformEvent() {
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = Fake.generateId(Business_Reference__c.class),
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            ),
            new Business_Reference__c(
                Id = Fake.generateId(Business_Reference__c.class),
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_COO_INTEGRATION
            ),
            new Business_Reference__c(
                Id = Fake.generateId(Business_Reference__c.class),
                Drive_with_Mp_Bz_Id__c = DRIVE_WITH_MPBZID_YES,
                External_Id__c = EXTERNAL_ID_DWH,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusReferenceIntegrationService businessReferenceIntegrationMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        IBusinessReferences businessReferencesMock = (IBusinessReferences) mocks.mock(
            IBusinessReferences.class
        );
        mocks.startStubbing();
        mocks.when(businessReferencesMock.getType())
            .thenReturn(Schema.Business_Reference__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(businessReferencesMock);
        Application.SERVICE.setMock(
            IBusReferenceIntegrationService.class,
            businessReferenceIntegrationMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(businessReferenceList);
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Business_Reference__c>{ businessReferenceList[0] },
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION
            );
        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Business_Reference__c>{ businessReferenceList[1] },
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO
            );
        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Business_Reference__c>{ businessReferenceList[2] },
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
            );
        ((IBusinessReferences) mocks.verify(businessReferencesMock, 1))
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenPublishPlatformEvent() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id businessReferenceIdWithDriveWithholding = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            ),
            new Business_Reference__c(
                Id = businessReferenceIdWithDriveWithholding,
                Drive_with_Mp_Bz_Id__c = DRIVE_WITH_MPBZID_YES,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(Id = businessReferenceId, Integration_Status__c = 'New'),
            new Business_Reference__c(
                Id = businessReferenceIdWithDriveWithholding,
                Integration_Status__c = STATUS_FAILURE
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusReferenceIntegrationService businessReferenceIntegrationMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        IBusinessReferences businessReferencesMock = (IBusinessReferences) mocks.mock(
            IBusinessReferences.class
        );
        mocks.startStubbing();
        mocks.when(businessReferencesMock.getType())
            .thenReturn(Schema.Business_Reference__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(businessReferencesMock);
        Application.SERVICE.setMock(
            IBusReferenceIntegrationService.class,
            businessReferenceIntegrationMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Business_Reference__c>{ businessReferenceList[0] },
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION
            );
        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                new List<Business_Reference__c>{ businessReferenceList[1] },
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
            );
        ((IBusinessReferences) mocks.verify(businessReferencesMock, 1))
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenPublishCOOPlatformEvent() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_COO_INTEGRATION
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(Id = businessReferenceId, Integration_Status__c = 'New')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusReferenceIntegrationService businessReferenceIntegrationMock = (IBusReferenceIntegrationService) mocks.mock(
            IBusReferenceIntegrationService.class
        );
        Application.SERVICE.setMock(
            IBusReferenceIntegrationService.class,
            businessReferenceIntegrationMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IBusReferenceIntegrationService) mocks.verify(businessReferenceIntegrationMock, 1))
            .createIntegrationPlatformEvents(
                businessReferenceList,
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO
            );
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenUpdateXrefs() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IXrefIntegrationService xrefIntegrationMock = (IXrefIntegrationService) mocks.mock(
            IXrefIntegrationService.class
        );
        IActivationOrdersService activationOrdersServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IXrefIntegrationService.class, xrefIntegrationMock);
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .updateStatusToReadyForIntegration(businessReferenceList, false);
        ((IActivationOrdersService) mocks.verify(activationOrdersServiceMock, 1))
            .activateOrderProductsOnBusinessReferenceSuccess(businessReferenceList);
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLastCompletedStepUpdatedThenActivateOrderItems() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Last_Completed_Step__c = LAST_COMPLETED_STEP_CONFIGURATION_CREATED,
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Last_Completed_Step__c = LAST_COMPLETED_STEP_USER_CREATED,
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IXrefIntegrationService xrefIntegrationMock = (IXrefIntegrationService) mocks.mock(
            IXrefIntegrationService.class
        );
        IActivationOrdersService activationOrdersServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IXrefIntegrationService.class, xrefIntegrationMock);
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);
        //Make sure we don't update Xrefs, because we were Integration_Status__c was Success Before.
        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 0))
            .updateStatusToReadyForIntegration(businessReferenceList, false);
        ((IActivationOrdersService) mocks.verify(activationOrdersServiceMock, 1))
            .activateOrderProductsOnBusinessReferenceSuccess(businessReferenceList);
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusUpdatedThenUpdateXrefsWorkStepsCOO() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_COO_SUCCESS
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_COO_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IXrefIntegrationService xrefIntegrationMock = (IXrefIntegrationService) mocks.mock(
            IXrefIntegrationService.class
        );
        IWorkStepIntegrationStatusService workStepServiceMock = (IWorkStepIntegrationStatusService) mocks.mock(
            IWorkStepIntegrationStatusService.class
        );
        Application.SERVICE.setMock(IWorkStepIntegrationStatusService.class, workStepServiceMock);
        Application.SERVICE.setMock(IXrefIntegrationService.class, xrefIntegrationMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IXrefIntegrationService) mocks.verify(xrefIntegrationMock, 1))
            .updateStatusToReadyForIntegration(businessReferenceList, true);
        ((IWorkStepIntegrationStatusService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(businessReferenceList);
    }

    /**
     * @description To test method call on Business_Reference__c update for drive type
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateStatusForDriveThenUpdateWorkSteps() {
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id businessReferenceId2 = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId1,
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS,
                External_ID_Source__c = BusinessReferenceHandler.EXTERNAL_ID_SOURCE_DRIVE_DB,
                Last_Completed_Step__c = LAST_COMPLETED_STEP_USER_CREATED
            ),
            new Business_Reference__c(
                Id = businessReferenceId2,
                Integration_Status__c = BusinessReferenceHandler.STATUS_FAILURE,
                External_ID_Source__c = BusinessReferenceHandler.EXTERNAL_ID_SOURCE_DRIVE_DB
            )
        };

        List<Business_Reference__c> oldEbidList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId1,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            ),
            new Business_Reference__c(
                Id = businessReferenceId2,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION
            )
        };

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMapSuccess = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMapSuccess.put(businessReferenceId1, businessReferenceList[0]);

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMapFailure = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMapFailure.put(businessReferenceId2, businessReferenceList[1]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepStatusForDriveService workStepServiceMock = (IWorkStepStatusForDriveService) mocks.mock(
            IWorkStepStatusForDriveService.class
        );
        Application.SERVICE.setMock(IWorkStepStatusForDriveService.class, workStepServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            businessReferenceList,
            new Map<Id, SObject>(oldEbidList)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);
        ((IWorkStepStatusForDriveService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
                businessReferenceIdToStatusMapSuccess
            );
        ((IWorkStepStatusForDriveService) mocks.verify(workStepServiceMock, 1))
            .updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
                businessReferenceIdToStatusMapFailure
            );
    }

    /**
     * @description To test Business_Reference__c Trigger
     */
    @isTest
    private static void testWhenBusinessReferenceInsertedThenTriggerIsCalled() {
        Business_Reference__c businessReference = new Business_Reference__c(
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            External_ID__c = '123ABC'
        );
        insert businessReference;

        System.assertNotEquals(null, businessReference.Id, 'Id is null');
    }

    /**
     * @description To test uniqueness
     */
    @isTest
    private static void testWhenBusinessReferenceInsertedThenCallDomainMethod() {
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '12345',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Business_Name__c = 'Fred\'s Beds',
            Default_Type__c = 'Corporate'
        );

        insert businessReference;

        Business_Reference__c businessReference2 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '12345',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Business_Name__c = 'Fred\'s Beds',
            Default_Type__c = 'Corporate'
        );

        Database.insert(businessReference2, false);

        System.assert(businessReference2.getErrors() != null, 'expected error upon inserting.');
    }

    /**
     * @description To test uniqueness
     */
    @isTest
    private static void testWhenBusinessReferenceInsertedThenCallDomainMethodNegative() {
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '12345',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Business_Name__c = 'Fred\'s Beds',
            Default_Type__c = 'Corporate'
        );

        insert businessReference;

        Business_Reference__c businessReference2 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '12345',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Business_Name__c = 'Fred\'s Beds',
            Default_Type__c = 'Corporate'
        );
        Database.insert(businessReference2, false);

        Business_Reference__c businessReference3 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '12345',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Business_Name__c = 'Fred\'s Beds',
            Default_Type__c = DEFAULT_TYPE_COO_GRAVEYARD
        );
        Database.insert(businessReference3, false);

        System.assert(
            businessReference2.getErrors().size() == 0,
            'unexpected error upon inserting.'
        );
        System.assert(
            businessReference3.getErrors().size() == 0,
            'COO Graveyard type do not validate uniqueness.'
        );
    }

    /*
     * @description test for handling the provisioning error message updates on Business_Reference__c object
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningErrorMessageUpdatedThenCallBusinessFriendlyService() {
        Id busRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        string provisioningMessage = 'Test Integration Message';

        List<Business_Reference__c> newBusRefs = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, busRefId)
                .setField(Business_Reference__c.Provisioning_Error_Message__c, provisioningMessage)
                .toSObject()
        };

        List<Business_Reference__c> oldBusRefs = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, busRefId)
                .setField(
                    Business_Reference__c.Provisioning_Error_Message__c,
                    provisioningMessage + ' test'
                )
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGetBusinessFriendlyMessageService serviceMock = (IGetBusinessFriendlyMessageService) mocks.mock(
            IGetBusinessFriendlyMessageService.class
        );
        Application.SERVICE.setMock(IGetBusinessFriendlyMessageService.class, serviceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newBusRefs, new Map<Id, SObject>(oldBusRefs));
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);

        ((IGetBusinessFriendlyMessageService) mocks.verify(serviceMock, 1))
            .getMessageDetails(provisioningMessage, BusinessReferences.INTEGRATION_TYPE);
    }

    /**
     * @description To test method call on Business_Reference__c update
     */
    @IsTest
    private static void testWhenGetBusinessReferencesWithThenReturnStageExternalId() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId,
                Integration_Status__c = BusinessReferenceHandler.STATUS_READY_FOR_INTEGRATION,
                External_Id__c = EXTERNAL_ID_DWH
            )
        };
        BusinessReferenceHandler handler = new BusinessReferenceHandler(businessReferenceList);
        List<Business_Reference__c> references = handler.getBusinessReferencesWithExternalIdCreatedandSourceNotEmpty();
        System.assertNotEquals(1, references.size(), 'Size not equals to 1');
        System.assertEquals(
            EXTERNAL_ID_DWH,
            businessReferenceList[0].External_Id__c,
            'Returned with Business Reference with Stage External Id Created and Source Not Empty'
        );
    }

    /**
     * @description To test if populateBusinessVerticalDetails method is called when Business
     * Vertical is updated on Business Reference record.
     * @JIRA# LEM-12375
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBusinessVerticalUpdatedThenCallPopulateBusinessVerticalDetails() {
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id oldBusinessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id newBusinessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        List<Business_Reference__c> oldBusinessReferenceRecords = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId)
                .setField(Business_Reference__c.Business_Vertical__c, oldBusinessVerticalId)
                .toSObject()
        };
        List<Business_Reference__c> newBusinessReferenceRecords = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId)
                .setField(Business_Reference__c.Business_Vertical__c, newBusinessVerticalId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessVerticalsService mockBusinessVerticalService = (IBusinessVerticalsService) mocks.mock(
            IBusinessVerticalsService.class
        );
        Application.Service.setMock(IBusinessVerticalsService.class, mockBusinessVerticalService);
        fflib_SObjectDomain.Test.Database.onUpdate(
            newBusinessReferenceRecords,
            new Map<Id, SObject>(oldBusinessReferenceRecords)
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);
        ((IBusinessVerticalsService) mocks.verify(mockBusinessVerticalService, 1))
            .populateBusinessVerticalDetails(newBusinessReferenceRecords);
    }

    /**
     * @description To test method updateIsBizGroupIdLinkToBizRefId call on Business_Reference__c before update
     */
    @IsTest
    private static void testWhenUpdateBizGroupIdThenReturnIsBizGroupIdLinkToBizRefId() {
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id businessReferenceId2 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        List<Business_Reference__c> existingBusinessReference = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId)
                .setField(Business_Reference__c.Integration_Status__c, READY_FOR_INTEGRATION)
                .setField(Business_Reference__c.External_Id__c, EXTERNAL_ID_DWH)
                .setField(Business_Reference__c.Business_Group_Id__c, '124')
                .toSObject(),
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId2)
                .setField(Business_Reference__c.Integration_Status__c, READY_FOR_INTEGRATION)
                .setField(Business_Reference__c.External_Id__c, EXTERNAL_ID_DWH)
                .setField(Business_Reference__c.Business_Group_Id__c, '122')
                .toSObject()
        };

        List<Business_Reference__c> newBusinessReference = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId)
                .setField(Business_Reference__c.Integration_Status__c, READY_FOR_INTEGRATION)
                .setField(Business_Reference__c.External_Id__c, EXTERNAL_ID_DWH)
                .setField(Business_Reference__c.Business_Group_Id__c, '234')
                .toSObject(),
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, businessReferenceId2)
                .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
                .setField(Business_Reference__c.External_Id__c, EXTERNAL_ID_DWH)
                .setField(Business_Reference__c.Business_Group_Id__c, '456')
                .toSObject()
        };

        Map<Id, SObject> existingBusinessReferenceMap = new Map<Id, SObject>();
        for (Business_Reference__c record : existingBusinessReference) {
            existingBusinessReferenceMap.put(record.Id, record);
        }

        for(Business_Reference__c record : existingBusinessReference) {
                BusinessReferenceHandler.oldBGIDMap.put(record.Id, record.Business_Group_Id__c + '|' + record.External_Id__c);
        }

        fflib_SObjectDomain.Test.Database.onUpdate(
            existingBusinessReference,existingBusinessReferenceMap
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);


        Test.setMock(HttpCalloutMock.class, new BusinessReferenceHandlerHttpMock());


        BusinessReferenceHandler handler = new BusinessReferenceHandler(existingBusinessReference);
        handler.updateIsBizGroupIdLinkToBizRefId(
            newBusinessReference,
            existingBusinessReferenceMap
        );
        Business_Reference__c updatedRecord = newBusinessReference[0];
        System.assertEquals(
            true,
            updatedRecord.is_Biz_Group_Id_Link_To_Biz_Ref_Id__c,
            'is_Biz_Group_Id_Link_To_Biz_Ref_Id__c should be true after updating Business_Group_Id__c'
        );
    }
}