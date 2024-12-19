/**
 * @description Test class for InboundIngestionLogsHandler class.
 * @author Deloitte
 * @date 05/14/2024
 * Suppressed Warnings since mock verify method does not require System assert statements
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InboundIngestionLogsHandlerTest {
    private static final String CONSTRUCTOR_ERROR_MESSAGE = 'The two constructs should not be similar';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION = 'EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION';
    private static final String EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT = 'EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT';
    private static final String SSMO_FALLOUT = 'SSMO_FALLOUT';
    private static final String SOURCE_RESSMO = 'RESSMO';

    /**
     * @description Verifies that the class instantiation and constructor call work as expected,
     * ensuring that different instances are created for different constructor calls.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>();
        InboundIngestionLogsHandler inboundIngestionLogsObject = new InboundIngestionLogsHandler(
            inboundIngestionLogs
        );
        //Inner Class Constructor Call
        InboundIngestionLogsHandler.Constructor objConstructor = new InboundIngestionLogsHandler.Constructor();
        objConstructor.construct(inboundIngestionLogs);
        System.assertNotEquals(
            inboundIngestionLogsObject,
            objConstructor.construct(inboundIngestionLogs),
            CONSTRUCTOR_ERROR_MESSAGE
        );
    }

    /**
     * @description Tests the behavior of the before insert trigger, specifically checking if
     * the onBeforeInsertHandleFalloutIngestionLogs method is called regardless of the Source__c field value.
     */
    @IsTest
    static void testWhenAnyRecordsAreInsertedThenItShouldExecuteBeforeInsertMethods() {
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-98',
                Source__c = 'Some Other Value'
            ),
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-99',
                Source__c = SOURCE_RESSMO
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(inboundIngestionLogsMock.getType())
            .thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(inboundIngestionLogsMock);
        fflib_SObjectDomain.Test.Database.onInsert(inboundIngestionLogs);
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);

        // Should call the RESSMO process
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .onBeforeInsertHandleFalloutIngestionLogs();
    }

    /**
     * @description Verifies that when non-RESSMO records are inserted, all appropriate after-insert
     * methods are called, and RESSMO-specific methods are not called.
     */
    @isTest
    private static void testWhenNonRESSMOTopicWithImplementationPassedThenCorrespondingAfterInsertServiceExecuteMethodsCalled() {
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-98',
                Source__c = 'Some value'
            ),
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-99',
                Source__c = 'Some other value'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(inboundIngestionLogsMock.getType())
            .thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(inboundIngestionLogsMock);
        fflib_SObjectDomain.Test.Database.onInsert(inboundIngestionLogs);
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);

        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateSSMOOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateSSOBOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
            );
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateMxPortalNSERecordsCreation(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateMxPortalNSERecordsCreation(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateAdsPromosAmendment(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateMxPortalAmendments(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateSSMOFalloutRecordsCreation(SSMO_FALLOUT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .createParentAndChildRecordsWhenNoMatchingUUIDFound();

        // Should not call the RESSMO methods
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateRESSMOOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
            );
    }

    /**
     * @description Ensures that when RESSMO source records are inserted, only the RESSMO-specific
     * after-insert method is called, and other methods are not invoked.
     */
    @IsTest
    static void testWhenRESSMOSourceThenCorrespondingAfterInsertServiceExecuteMethodsCalled() {
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-98',
                Source__c = SOURCE_RESSMO
            ),
            new Inbound_Ingestion_Log__c(
                Id = Fake.generateId(Inbound_Ingestion_Log__c.class),
                UUID__c = 'IIL-99',
                Source__c = SOURCE_RESSMO
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(inboundIngestionLogsMock.getType())
            .thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(inboundIngestionLogsMock);
        fflib_SObjectDomain.Test.Database.onInsert(inboundIngestionLogs);
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);

        // Should call the RESSMO methods
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 1))
            .initiateRESSMOOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
            );

        // Should not call the non RESSMO process
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateSSMOOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateSSOBOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
            );
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateMxPortalNSERecordsCreation(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateMxPortalNSERecordsCreation(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateAdsPromosAmendment(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateMxPortalAmendments(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .initiateSSMOFalloutRecordsCreation(SSMO_FALLOUT);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .createParentAndChildRecordsWhenNoMatchingUUIDFound();
    }

    /**
     * @description Tests that when Inbound Ingestion Log records are updated without any changes,
     * the rollup to parent functionality is not triggered.
     */
    @isTest
    private static void testWhenAnyInboundIngestionLogHasNOTChangedThenDoNotInitiateARollupToTheParent() {
        Id inbound1Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound2Id = Fake.generateId(Inbound_Ingestion_Log__c.class);

        Inbound_Ingestion_Log__c[] newInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1234',
                Status__c = 'Completed'
            ), // Unchanged record
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '1234',
                Parent_Log__c = inbound1Id,
                Status__c = 'Pending'
            )
        };
        Inbound_Ingestion_Log__c[] oldInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1234',
                Status__c = 'Completed'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '1234',
                Parent_Log__c = inbound1Id,
                Status__c = 'Pending'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IInboundIngestionLogs inboundMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(inboundMock);
        mocks.when(inboundMock.getType()).thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        InboundIngestionLogs.setConstructorMock(constructor);
        Application.Domain.setMock(inboundMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newInboundIngestions,
            new Map<Id, SObject>(oldInboundIngestions)
        );
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 0)).construct(fflib_Match.anyList());
        ((IInboundIngestionLogs) mocks.verify(inboundMock, 0)).rollupStatusAndErrorMessage();
    }

    /**
     * @description Verifies that when Inbound Ingestion Log records are updated with changes to
     * various fields (except Status), the SSMO retry process is not initiated.
     */
    @isTest
    private static void testWhenAnyInboundIngestionLogHasNOTHasStatusChangedThenDoNotInitiateAnySSMORetry() {
        Id inbound1Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound2Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound3Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound4Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound5Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound6Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound7Id = Fake.generateId(Inbound_Ingestion_Log__c.class);

        Inbound_Ingestion_Log__c[] newInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Status__c = 'Completed'
            ), // Unchanged record
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id,
                Status__c = 'Pending'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id,
                Error_Message__c = 'Some error'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound4Id,
                UUID__c = '4444',
                Parent_Log__c = inbound1Id,
                Success_Message__c = 'Success!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound5Id,
                UUID__c = '5555',
                Parent_Log__c = inbound1Id,
                Exception_Message__c = 'Something went wrong!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound6Id,
                UUID__c = '6666',
                Parent_Log__c = inbound1Id,
                Business_Error_Message__c = 'Something went wrong!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound7Id,
                UUID__c = '7777',
                Parent_Log__c = inbound1Id,
                Stack_Trace__c = 'Step 1, Step 2'
            )
        };
        Inbound_Ingestion_Log__c[] oldInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Status__c = 'Completed'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id,
                Status__c = 'Pending'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound4Id,
                UUID__c = '4444',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound5Id,
                UUID__c = '5555',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound6Id,
                UUID__c = '6666',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound7Id,
                UUID__c = '7777',
                Parent_Log__c = inbound1Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IInboundIngestionLogs inboundMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(inboundMock);
        mocks.when(inboundMock.getType()).thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        InboundIngestionLogs.setConstructorMock(constructor);
        Application.Domain.setMock(inboundMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newInboundIngestions,
            new Map<Id, SObject>(oldInboundIngestions)
        );
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);

        ((IInboundIngestionLogs) mocks.verify(inboundMock, 0)).initiateRetrySSMORecordsCreation();
    }

    /**
     * @description Tests that when any field in an Inbound Ingestion Log record is changed,
     * the rollup to parent functionality is triggered.
     */
    @isTest
    private static void testWhenAnInboundIngestionLogHasChangedThenInitiateARollupToTheParent() {
        Id inbound1Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound2Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound3Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound4Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound5Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound6Id = Fake.generateId(Inbound_Ingestion_Log__c.class);

        Inbound_Ingestion_Log__c[] newInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Parent_Log__c = inbound1Id,
                Status__c = 'Completed'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id,
                Error_Message__c = 'Some error'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id,
                Success_Message__c = 'Success!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound4Id,
                UUID__c = '4444',
                Parent_Log__c = inbound1Id,
                Exception_Message__c = 'Something went wrong!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound5Id,
                UUID__c = '5555',
                Parent_Log__c = inbound1Id,
                Business_Error_Message__c = 'Something went wrong!'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound6Id,
                UUID__c = '6666',
                Parent_Log__c = inbound1Id,
                Stack_Trace__c = 'Step 1, Step 2'
            )
        };
        Inbound_Ingestion_Log__c[] oldInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound4Id,
                UUID__c = '4444',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound5Id,
                UUID__c = '5555',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound6Id,
                UUID__c = '6666',
                Parent_Log__c = inbound1Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IInboundIngestionLogs inboundMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(inboundMock);
        mocks.when(inboundMock.getType()).thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        InboundIngestionLogs.setConstructorMock(constructor);
        Application.Domain.setMock(inboundMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newInboundIngestions,
            new Map<Id, SObject>(oldInboundIngestions)
        );
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);
        ((IInboundIngestionLogs) mocks.verify(inboundMock, 1)).rollupStatusAndErrorMessage();
    }

    /**
     * @description Ensures that when the Status field of an Inbound Ingestion Log is changed,
     * both the rollup to parent functionality and the SSMO retry process are initiated.
     */
    @isTest
    private static void testWhenAnInboundIngestionLogHasHadStatusChangedThenInitiateSSMORetry() {
        Id inbound1Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound2Id = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id inbound3Id = Fake.generateId(Inbound_Ingestion_Log__c.class);

        Inbound_Ingestion_Log__c[] newInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Parent_Log__c = inbound1Id,
                Status__c = 'Not started'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id,
                Status__c = 'Pending'
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id,
                Status__c = 'Completed'
            )
        };
        Inbound_Ingestion_Log__c[] oldInboundIngestions = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inbound1Id,
                UUID__c = '1111',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound2Id,
                UUID__c = '2222',
                Parent_Log__c = inbound1Id
            ),
            new Inbound_Ingestion_Log__c(
                Id = inbound3Id,
                UUID__c = '3333',
                Parent_Log__c = inbound1Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IInboundIngestionLogs inboundMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(inboundMock);
        mocks.when(inboundMock.getType()).thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        InboundIngestionLogs.setConstructorMock(constructor);
        Application.Domain.setMock(inboundMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newInboundIngestions,
            new Map<Id, SObject>(oldInboundIngestions)
        );
        fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);
        ((IInboundIngestionLogs) mocks.verify(inboundMock, 1)).rollupStatusAndErrorMessage();
    }
}