/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Test class for Fraud Events Service Implementation.
 */
@isTest(SeeAllData=false)
private class FraudEventsServiceImplTest {
    private static final String BUSINESS_VERIFICATION = 'BusinessVerification';
    private static final String CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST';
    private static final String EVENT_TOPIC_FRAUD_EVENT_CHECK = 'EVENT_TOPIC_FRAUD_EVENT_CHECK';
    private static final String INTEGRATION_TYPE_FRAUD_EVENT = 'Fraud Event';
    private static final String PAYLOAD_STORE_ID = '987654';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON = 'Business_Verification_Mock_Payload';
    private static final String STORE_ID = 'StoreId';
    /**
     * @description To test when Fraud Event event received then trigger update on Work Steps.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFraudEventEventsReceivedThenTriggerWorkStepUpdate() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails = new Map<String, BusinessVerficationDetails>();
        Map<Id, String> salesforceAccountIdToStoreId = new Map<Id, String>();
        BusinessVerficationDetails storeData;
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
            blobJSON.toString()
        );
        storeData = new BusinessVerficationDetails((String) payloadMap.get(STORE_ID));
        storeData.businessVerificationDetails = (BusinessVerficationDetails.BusinessVerificationStatusDetails) JSON.deserialize(
            JSON.serialize(payloadMap.get(BUSINESS_VERIFICATION)),
            BusinessVerficationDetails.BusinessVerificationStatusDetails.class
        );
        storeIdsToBusinessVertificationDetails.put((String) payloadMap.get(STORE_ID), storeData);
        salesforceAccountIdToStoreId.put(accountId, (String) payloadMap.get(STORE_ID));
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c[] newIntegrationRequest = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Integration_Type__c = INTEGRATION_TYPE_FRAUD_EVENT,
                Payload__c = payloadString
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationRequestsSelector.selectById(
                    new Set<Id>{ newIntegrationRequest[0].Id }
                )
            )
            .thenReturn(newIntegrationRequest);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefsByExternalIdsAndPrimaryVertical(
                    new List<String>{ (String) payloadMap.get(STORE_ID) },
                    PRIMARY_VERTICAL_RX
                )
            )
            .thenReturn(
                new List<Xref__c>{
                    (Xref__c) new Fake(Xref__c.class)
                        .setField(Xref__c.External_ID__c, (String) payloadMap.get(STORE_ID))
                        .setParent(
                            'Salesforce_Account_Name__r',
                            new Fake(Account.class).setField(Account.Account_ID18__c, accountId)
                        )
                        .toSObject()
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        String eventPayload = JSON.serialize(new Set<Id>{ newIntegrationRequest[0].Id });
        Onboarding_Activation__e mockOnboardingActivationEvents = new Onboarding_Activation__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_FRAUD_EVENT_CHECK
        );
        FraudEventsService.execute(
            new List<Onboarding_Activation__e>{ mockOnboardingActivationEvents }
        );
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 0))
            .updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
                new Set<Id>{ accountId },
                salesforceAccountIdToStoreId,
                storeIdsToBusinessVertificationDetails
            );
    }

    /**
     * @description To test when Fraud Event event received then trigger update on
     *  Work Steps.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts,PMD.UnusedLocalVariable')
    private static void testWhenFraudEventEventsNotReceivedThenDoNotTriggerWorkStepUpdate() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails = new Map<String, BusinessVerficationDetails>();
        Map<Id, String> salesforceAccountIdToStoreId = new Map<Id, String>();
        BusinessVerficationDetails storeData;
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
            blobJSON.toString()
        );
        BusinessVerficationDetails.BusinessVerificationStatusDetails statusDetails = new BusinessVerficationDetails.BusinessVerificationStatusDetails(
            '',
            '',
            ''
        );
        storeData = new BusinessVerficationDetails((String) payloadMap.get(STORE_ID));
        storeData.businessVerificationDetails = (BusinessVerficationDetails.BusinessVerificationStatusDetails) JSON.deserialize(
            JSON.serialize(payloadMap.get(BUSINESS_VERIFICATION)),
            BusinessVerficationDetails.BusinessVerificationStatusDetails.class
        );
        storeIdsToBusinessVertificationDetails.put((String) payloadMap.get(STORE_ID), storeData);
        salesforceAccountIdToStoreId.put(accountId, (String) payloadMap.get(STORE_ID));
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c[] newIntegrationRequest = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Integration_Type__c = INTEGRATION_TYPE_FRAUD_EVENT,
                Payload__c = payloadString
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationRequestsSelector.selectById(
                    new Set<Id>{ newIntegrationRequest[0].Id }
                )
            )
            .thenReturn(newIntegrationRequest);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        String eventPayload = JSON.serialize(new Set<Id>{ newIntegrationRequest[0].Id });
        Onboarding_Activation__e mockOnboardingActivationEvents = new Onboarding_Activation__e(
            Payload__c = eventPayload,
            Topic__c = CREATE_ACTIVATION_CHECKLIST
        );
        FraudEventsService.execute(
            new List<Onboarding_Activation__e>{ mockOnboardingActivationEvents }
        );
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 0))
            .updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
                new Set<Id>{ accountId },
                salesforceAccountIdToStoreId,
                storeIdsToBusinessVertificationDetails
            );
    }
}