/**
 * @author Deloitte
 * @date 05/20/2024
 * @description This is test class SSMO Lead Creation
 */
@isTest(seeAllData=false)
private class SSMOLeadCreationServiceImplTest {
    private static final String COMPLETED = 'Completed';
    private static final String STATIC_RESOURCE_TEST_JSON = 'SSMO_Lead_Ingestion_Mock_Payload';
    private static final String SSMO_HOLDING_QUEUE = 'SSMO Holding Queue';
    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';
    private static final String LEAD_STATUS_UNTOUCHED = 'Untouched';
    private static final String LEAD_STATUS_DISQUALIFIED = 'Disqualified';
    private static final String LEAD_FIRSTNAME = 'Mc Donald';
    private static final String LEAD_LASTNAME = 'Australia';
    private static final String PRIMARY_VERTICAL_MARKETING = 'Marketing';
    private static final String DML_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String UNEXPECTED_DML_EXCEPTION_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException.';
    private static final String STATIC_RESOURCE_TEST_JSON_REJECTED_ADDRESS= 'SSMO_Lead_Ingestion_Mock_Payload_Rejected_Address';
    private static final String RAW_ADDRESS = '1500 Kennedy Road, Toronto, ON, Canada, CA, M3P 2L6';
    private static final String ASSERT_MESSAGE_FIELD_VALUE_MISMATCH = 'Unexpected Result: Field Value do not match';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String TEST_PHONE = '0385938594';
    private static final String TEST_EMAIL = 'Test@email.com';
    private static final String TEST_STORE_ID = '353535';
    private static final String TEST_BUSINESS_ID = '0385938';
    private static final Integer FIRSTNAME_LASTNAME_MAX_LENGTH = 40;

    /**
     * @description To test lead creation.
     * */
    @isTest
    private static void testWhenFalloutPayloadReceivedThenCreateLead() {
        Id groupId = fflib_IDGenerator.generate(Group.SObjectType);
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Lead leadsToInsert = new Lead();
        Lead leadsTobeInserted = SSMOLeadCreationService.insertLead(parsedPayloads, leadsToInsert, groupId);

        System.assertEquals(parsedPayloads.storeName, leadsTobeInserted.Company, 'False');
        System.assertEquals(groupId, leadsTobeInserted.OwnerId, 'False');
        System.assertEquals(parsedPayloads.ownerFirstName, leadsTobeInserted.FirstName, 'False');
        System.assertEquals((parsedPayloads.ownerLastName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH), leadsTobeInserted.LastName, 'False');
        System.assertEquals(parsedPayloads.ownerPhone, leadsTobeInserted.MobilePhone, 'False');
        System.assertEquals(parsedPayloads.email, leadsTobeInserted.Email, 'False');
        System.assertEquals('Premier', leadsTobeInserted.Package__c, 'False');
    }
    /**
     * @description To test lead updation with Additional fields.
     * */

    @isTest
    private static void testWhenLeadIsUnqualifiedOrNotInterestedThenUpdateLeadStatusAsUntouched() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);

        List<Lead> testupdateLeadSSMO = new List<Lead>{
            new Lead(
                Inbound_Ingestion_Log__c = inboundIngestionLogId,
                SSMO_Matching_Account_Id__c = '',
                Status = LEAD_STATUS_DISQUALIFIED
            )
        };
        SSMOLeadCreationService.updateFieldsOnLeadAfterFallout(testupdateLeadSSMO);
        System.assertEquals('Untouched', testupdateLeadSSMO[0].Status, 'False');
    }

    /**
     * @description To test lead updation.
     * */
    @isTest
    private static void testWhenFalloutPayloadReceivedAndLeadExistThenUpdateLead() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();

        Lead leadsTobeUpdated = SSMOLeadCreationService.updateLead(
            parsedPayloads,
            testupdateLeadSSMO
        );
        System.assertEquals(parsedPayloads.sourceUniqueId, leadsTobeUpdated.SSMO_UUID__c, 'False');
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory,
            leadsTobeUpdated.Alcohol_Eligibility__c,
            'False'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.addressVerificationStatus,
            leadsTobeUpdated.Address_Verification_Status__c,
            'False'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.rejectedReason,
            leadsTobeUpdated.Rejected_Reason__c,
            'False'
        );
        String ssmoStreet =
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine1 +
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine2;
        System.assertEquals(ssmoStreet, leadsTobeUpdated.Street, 'False');
        System.assertEquals('Rx', leadsTobeUpdated.PrimaryVertical__c, 'False');
    }

    /**
     * @description To test lead updation.
     * */
    @isTest
    private static void testWhenFalloutPayloadReceivedAndLeadExistThenDoNotUpdateLead() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(DML_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(mockUOW);
        try {
            SSMOLeadCreationService.updateLead(parsedPayloads, testupdateLeadSSMO);
        } catch (Exception e) {
            System.assertEquals(
                DML_EXCEPTION_MESSAGE,
                e.getMessage(),
                UNEXPECTED_DML_EXCEPTION_MESSAGE
            );
        }
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .updateIngestionLogsWithSucessOrFailureStatus(
                (Set<Id>) fflib_Match.anyObject(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString()
            );
    }
    /**
     * @description To test Task creation.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     * */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadStatusChangeThenCreateTask() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UnitOfWork.setMock(mockUOW);

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        List<Lead> taskLead = new List<Lead>{
            new Lead(SSMO_Matching_Account_Id__c = '', Status = 'Untouched', Id = leadId ,SSMO_UUID__c ='00820065-d1f7-4b44-bed2-35f2993f772e')
        };
        Map<Id, Lead> existingLeads = new Map<Id, Lead>{ leadId => taskLead[0] };
        SSMOLeadCreationService.createTaskOnLeadAfterFallout(taskLead, existingLeads);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Task.WhoId => taskLead[0].Id,
                        Task.Subject => 'SSMO Drop Off',
                        Task.Type => 'SSMO Drop Off',
                        Task.ActivityDate => System.today().addDays(1)
                    }
                )
            );
    }

    /**
     * @description To test Task creation.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     * */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadStatusChangeThenDoNotCreateTask() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(DML_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(mockUOW);

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        List<Lead> taskLead = new List<Lead>{
            new Lead(SSMO_Matching_Account_Id__c = '', Status = 'Untouched', Id = leadId, SSMO_UUID__c ='00820065-d1f7-4b44-bed2-35f2993f772e')
        };
        Map<Id, Lead> existingLeads = new Map<Id, Lead>{ leadId => taskLead[0] };
        try {
            SSMOLeadCreationService.createTaskOnLeadAfterFallout(taskLead, existingLeads);
        } catch (Exception e) {
            System.assertEquals(
                DML_EXCEPTION_MESSAGE,
                e.getMessage(),
                UNEXPECTED_DML_EXCEPTION_MESSAGE
            );
        }
    }

    /**
     * @description To test the lead fields are correctly updated with the corresponding values from the payload.
     */
    @isTest
    private static void testWhenLeadPresentThenUpdateLead() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();

        Lead leadsTobeUpdated = SSMOLeadCreationService.updateLead(
            parsedPayloads,
            testupdateLeadSSMO
        );
        System.assertEquals(
            parsedPayloads.sourceUniqueId,
            leadsTobeUpdated.SSMO_UUID__c,
            'SSMO UUID should match'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory,
            leadsTobeUpdated.Alcohol_Eligibility__c,
            'Alcohol Eligibility should match'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.addressVerificationStatus,
            leadsTobeUpdated.Address_Verification_Status__c,
            'Address Verification Status should match'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.rejectedReason,
            leadsTobeUpdated.Rejected_Reason__c,
            'Address Rejected Reason should match'
        );
        String ssmoStreet =
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine1 +
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine2;
        System.assertEquals(ssmoStreet, leadsTobeUpdated.Street, 'Street should match');
        System.assertEquals(
            PRIMARY_VERTICAL_MARKETING,
            leadsTobeUpdated.Self_Serve_Step__c,
            'Expected Self Serve Step to be Marketing'
        );
        System.assertEquals(
            RAW_ADDRESS,
            leadsTobeUpdated.Raw_Address__c,
            'Expected Self Serve Step to be Marketing'
        );
    }

    /**
     * @description To test the lead fields are correctly updated with the corresponding values from the payload.
     */
    @isTest
    private static void testWhenAddressVerficationStatusFailedThenUpdateLead() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON_REJECTED_ADDRESS);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );

        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();

        Test.StartTest();
        Lead leadsTobeUpdated = SSMOLeadCreationService.updateLead(
            parsedPayloads,
            testupdateLeadSSMO
        );
        Test.StopTest();
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.rejectedReason,
            leadsTobeUpdated.Rejected_Reason__c,
            'Address Rejected Reason should match'
        );
        String ssmoStreet = (String.isNotBlank(parsedPayloads.storeAddress?.addressLine1) ?
            parsedPayloads.storeAddress?.addressLine1 : '') +
            (String.isNotBlank(parsedPayloads.storeAddress?.addressLine2) ?
            parsedPayloads.storeAddress?.addressLine2 : '');
        System.assertEquals(ssmoStreet, leadsTobeUpdated.Street, 'Street should match');
        System.assertEquals(
            parsedPayloads.storeAddress?.city,
            leadsTobeUpdated.city,
            'City Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.state,
            leadsTobeUpdated.StateCode,
            'state Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.country,
            leadsTobeUpdated.CountryCode,
            'country Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.postalCode,
            leadsTobeUpdated.PostalCode,
            'postalCode Should match'
        );
    }

    /**
     * @description To test lead updation.
     * */
    @isTest
    private static void testWhenLeadPresentThenUpdateLeadWithNewSubmarket() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();
        Lead leadsTobeUpdated = SSMOLeadCreationService.updateLead(
            parsedPayloads,
            testupdateLeadSSMO
        );
        System.assertEquals(parsedPayloads.sourceUniqueId, leadsTobeUpdated.SSMO_UUID__c, 'False');
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory,
            leadsTobeUpdated.Alcohol_Eligibility__c,
            'False'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.addressVerificationStatus,
            leadsTobeUpdated.Address_Verification_Status__c,
            'False'
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.rejectedReason,
            leadsTobeUpdated.Rejected_Reason__c,
            'False'
        );
        String ssmoStreet =
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine1 +
            parsedPayloads.addressVerificationInfo?.validatedAddress?.addressLine2;
        System.assertEquals(ssmoStreet, leadsTobeUpdated.Street, 'False');
    }

    /**
     * @description To test lead status update.
     * */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadIsClosedUpdateThenUpdateInboundIngestionLogsToCompletedStatus() {
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Lead newLead = new Lead(
            Id = leadId,
            FirstName = LEAD_FIRSTNAME,
            LastName = LEAD_LASTNAME,
            Status = LEAD_STATUS_UNTOUCHED
        );
        Lead existingLead = new Lead(
            Id = leadId,
            FirstName = LEAD_FIRSTNAME,
            LastName = LEAD_LASTNAME,
            Status = LEAD_STATUS_DISQUALIFIED,
            Inbound_Ingestion_Log__c = inboundIngestionLogId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs domainMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        domainMock.updateIngestionLogsWithSucessOrFailureStatus(
            new Set<Id>{ inboundIngestionLogId },
            COMPLETED,
            '',
            '',
            ''
        );
        mocks.startStubbing();
        mocks.when(domainMock.getType()).thenReturn(Schema.Inbound_Ingestion_Log__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(domainMock);
        Map<Id, Lead> existingLeads = new Map<Id, Lead>();
        existingLeads.put(leadId, existingLead);
        SSMOLeadCreationService.updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
            new List<Lead>{ newLead },
            existingLeads
        );
        ((IInboundIngestionLogs) mocks.verify(domainMock, 1))
            .updateIngestionLogsWithSucessOrFailureStatus(
                new Set<Id>{ inboundIngestionLogId },
                COMPLETED,
                '',
                '',
                ''
            );
    }

    /**
     * @description To query static resources
     * @param staticResourceName
     * @return StaticResource
     * */
    private static StaticResource fetchStaticResource(String staticResourceName) {
        StaticResource stresource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
        ];
        return stresource;
    }
    /**
     * @description To test the lead fields are correctly updated with the corresponding values from the payload.
     */
    @isTest
    private static void testWhenPayloadValuesAreNullThenDoNotUpdateFields() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead testupdateLeadSSMO = (Lead) new Fake(Lead.class).setField(Lead.Id, leadId).toSObject();
        testupdateLeadSSMO.Order_Protocol__c  = ORDER_PROTOCOL_EMAIL;
        testupdateLeadSSMO.Email = TEST_EMAIL;
        testupdateLeadSSMO.Phone = TEST_PHONE;
        testupdateLeadSSMO.Store_ID__c = TEST_STORE_ID;
        testupdateLeadSSMO.Business_Id__c  = TEST_BUSINESS_ID;
        testupdateLeadSSMO.Order_Protocol_Email__c  = TEST_EMAIL;
        Test.StartTest();
        Lead leadsTobeUpdated = SSMOLeadCreationService.updateLead(
            parsedPayloads,
            testupdateLeadSSMO
        );
        Test.StopTest();
        System.assertEquals(
            String.valueOf(parsedPayloads.storeId),
            leadsTobeUpdated.Store_ID__c,
            ASSERT_MESSAGE_FIELD_VALUE_MISMATCH
        );
        System.assertEquals(
            testupdateLeadSSMO.Order_Protocol__c,
            leadsTobeUpdated.Order_Protocol__c,
            ASSERT_MESSAGE_FIELD_VALUE_MISMATCH
        );
        System.assertEquals(
            String.valueOf(parsedPayloads.businessId),
            leadsTobeUpdated.Business_Id__c,
            ASSERT_MESSAGE_FIELD_VALUE_MISMATCH
        );
        System.assertEquals(
            parsedPayloads.businessPhone,
            leadsTobeUpdated.Phone,
            ASSERT_MESSAGE_FIELD_VALUE_MISMATCH
        );
    }
}