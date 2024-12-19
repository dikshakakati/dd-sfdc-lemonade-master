/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Test class for SSMOFalloutHandlerService class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class SSMOFalloutHandlerServiceTest {
    private static final String CLASS_NAME = 'SSMOFalloutHandlerService';
    private static final String STATIC_RESOURCE_LEAD_TEST_JSON = 'SSMO_Lead_Ingestion_Mock_Payload';
    private static final String PAYLOAD3 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"9094"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[],"contact":[],"lead":[{"id":"00QOz000008FndJMAS"}]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';
    private static final String PAYLOAD4 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"9094"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[],"contact":[],"lead":[]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';
    private static final String STATUS_PENDING = 'Pending';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String AGREEMENT_NAME = 'Test business agreement';
    private static final String ACTIVE = 'Active';
    private static final String INACTIVE = 'Inactive';
    private static final String RAW_ADDRESS = '1500 Kennedy Road, Toronto, ON, Canada, CA, M3P 2L6';

    /**
     * @description To test execute method of InstantIngestorEvents handler class
     * is called on InstantIngestor event publish.
     */
    @isTest
    private static void testWhenMatchedContactIsFoundThenExecuteMethod() {
        String payload1 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"1"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[],"contact":[{"id":"';
        String payload2 = '"}],"lead":[]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';
        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Id contactId = Fake.generateId(Contact.class);
        String payload = payload1 + Id.valueOf(contactId) + payload2;
        String subMktId = '1';
        List<Contact> contacts = new List<Contact>{
            new Contact(
                Id = contactId,
                FirstName = 'Test1',
                LastName = 'Contact1',
                Email = 'test@gmail.com'
            )
        };
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId, Submarket_ID__c = subMktId);
        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = payload,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId })).thenReturn(contacts);
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(subMarketSelector.getSubmarketsByIds(new Set<String>{ subMktId }))
            .thenReturn(new List<Submarket__c>{ newSubMkt });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.SetMock(logSelectorMock);
        Application.SELECTOR.SetMock(mockContactsSelector);
        Application.SELECTOR.SetMock(subMarketSelector);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Contact.Id => contactId,
                            Contact.Submarket__c => submarketId
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Lead.Inbound_Ingestion_Log__c => logID1,
                            Lead.Submarket__c => submarketId,
                            Lead.Raw_Address__c => RAW_ADDRESS
                        }
                    }
                )
            );
    }

    /**
     * @description To test execute method of InstantIngestorEvents handler class
     * is called on InstantIngestor event publish.
     */
    @isTest
    private static void testWhenMatchedAccountAndContactIsFoundThenExecuteMethod() {
        String payload1 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"1"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[{"id":"001O100000BkM5RIAV"}],"contact":[{"id":"';

        String payload2 = '"}],"lead":[]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';

        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Id contactId = Fake.generateId(Contact.class);
        String payload = payload1 + Id.valueOf(contactId) + payload2;
        String subMktId = '1';
        List<Contact> contacts = new List<Contact>{
            new Contact(
                Id = contactId,
                FirstName = 'Test1',
                LastName = 'Contact1',
                Email = 'test@gmail.com'
            )
        };
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId, Submarket_ID__c = subMktId);

        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = payload,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId })).thenReturn(contacts);
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(subMarketSelector.getSubmarketsByIds(new Set<String>{ subMktId }))
            .thenReturn(new List<Submarket__c>{ newSubMkt });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.SetMock(logSelectorMock);
        Application.SELECTOR.SetMock(mockContactsSelector);
        Application.SELECTOR.SetMock(subMarketSelector);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Contact.Id => contactId,
                            Contact.Submarket__c => submarketId
                        }
                    }
                )
            );
    }

    /**
     * @description To test execute method of InstantIngestorEvents handler class
     * is called on InstantIngestor event publish.
     */
    @isTest
    private static void testWhenMatchedLeadIsFoundThenExecuteMethod() {
        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = PAYLOAD3,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.SetMock(logSelectorMock);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test execute method of InstantIngestorEvents handler class
     * is called on InstantIngestor event publish.
     */
    @isTest
    private static void testWhenNoMatchedIdIsFoundThenExecuteMethod() {
        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = PAYLOAD4,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.SetMock(logSelectorMock);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
    }
    /**
     * @description To test when Inactive Matching store account Id in the Payload then process contact
     * with Parent AccountId.
     */
    @isTest
    private static void testWhenInActiveMatchingStoreAccountIsFoundThenIdentifyBusinessAccount() {
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        String subMktId = '1';
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.Record_Type_Name__c, 'Store')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
                    .setField(Account.Id, businessAccountId)
            )
            .toSObject();
        Contact matchedContact = new Contact();
        matchedContact.Id = contactId;
        matchedContact.FirstName = 'First Name 1';
        matchedContact.LastName = 'Last Name 1';
        matchedContact.Phone = '9897969594';
        matchedContact.AccountId = businessAccountId;
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId, Submarket_ID__c = subMktId);
        String payload1 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"1"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[{"id":"';
        String payload2 = '"}],"contact":[{"id":"';
        string payload3 = '"}],"lead":[]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';
        String payload = payload1 + storeAccountId + payload2 + contactId + payload3;
        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = payload,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ matchedContact });
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(subMarketSelector.getSubmarketsByIds(new Set<String>{ subMktId }))
            .thenReturn(new List<Submarket__c>{ newSubMkt });

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.SetMock(logSelectorMock);
        Application.SELECTOR.SetMock(mockContactsSelector);
        Application.SELECTOR.SetMock(subMarketSelector);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Contact.Id => contactId,
                            Contact.SSMO_Business_Account_Id__c => businessAccountId,
                            Contact.Submarket__c => submarketId
                        }
                    }
                )
            );
    }
    /**
     * @description To test when Active Matching store account Id in the Payload then process contact
     * with Contract's AccountId associated with agreement.
     */
    @isTest
    private static void testWhenActiveMatchingStoreAccountIsFoundThenIdentifyBusinessAccount() {
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        String subMktId = '1';
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Activation_Status__c, ACTIVE)
            .setField(Account.Record_Type_Name__c, 'Store')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
                    .setField(Account.Id, businessAccountId)
            )
            .toSObject();
        Contact matchedContact = new Contact();
        matchedContact.Id = contactId;
        matchedContact.FirstName = 'First Name 1';
        matchedContact.LastName = 'Last Name 1';
        matchedContact.Phone = '9897969594';
        matchedContact.AccountId = businessAccountId;
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId, Submarket_ID__c = subMktId);

        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.MP_Bz_Id__c, '1234');
        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, storeAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Status__c, 'Active')
            .setParent('Contract__r', contractFakeInstance);
        Agreement__c agreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        String payload1 = '{"addressVerificationInfo":{"alcoholRules":{"alcoholAllowanceCategory":"Dry"},"startingPoint":{"startingPoint":"ON: Agincourt","Id":10103},"submarket":{"name":"Scarborough","id":"1"},"validatedAddress":{"timeZone":"America/Toronto","addressId":"51416762","postalCode":"M3P 2L6","countryShortname":"CA","country":"Canada","state":"ON","city":"Toronto","addressLine2":"","addressLine1":"1500 Kennedy Road","longitude":-73.980294,"latitude":40.7671773},"addressVerificationDate":"2024-05-24T05:19:57.932Z","rejectedReason":null,"addressVerificationStatus":"Verified"},"hasValidEmail":true,"matchedRecords":{"account":[{"id":"';
        String payload2 = '"}],"contact":[{"id":"';
        string payload3 = '"}],"lead":[]},"ownerPhone":"+15667676767","treatmentGroups":["is_singularity_exp"],"selectedPackageUuid":"a436236c-595d-4891-99d8-3d8c931d9f82","menuLinks":["s3://test/menu.jpg","https://menu.com"],"storeHours":"All days 8:00AM-10:00PM","orderProtocol":"ORDER_PROTOCOL_TABLET","businessId":123456,"storeId":123456,"storeAddress":{"postalCode":"M2P 2L6","country":"CA","state":"ON","city":"Toronto","addressLine1":"1500 Kennedy Road"},"experiences":["DOORDASH"],"locale":"en-US","verticalType":"VERTICAL_TYPE_RESTAURANT","email":"saranginvalid3@gmail.com","businessPhone":"0987654321","ownerLastName":"MLM","ownerFirstName":"MLM","storeName":"Sarang Store","sourceUniqueId":"79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8"}';
        String payload = payload1 + storeAccountId + payload2 + contactId + payload3;
        Id logID1 = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        List<Inbound_ingestion_log__c> logs = new List<Inbound_ingestion_log__c>{
            new Inbound_Ingestion_Log__c(
                Id = logID1,
                Payload__c = payload,
                Status__c = STATUS_PENDING,
                Integration_Type__c = 'Fallout event'
            )
        };
        Set<Id> instantIngestorLogIds = new Set<Id>{ logID1 };

        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(Payload__c = JSON.serialize(instantIngestorLogIds))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IInboundIngestionLogsSelector logSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(logSelectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(logSelectorMock.selectById(instantIngestorLogIds)).thenReturn(logs);
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ matchedContact });
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(subMarketSelector.getSubmarketsByIds(new Set<String>{ subMktId }))
            .thenReturn(new List<Submarket__c>{ newSubMkt });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectAgreementsByAccountsIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<Agreement__c>{ agreement });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.SetMock(logSelectorMock);
        Application.SELECTOR.SetMock(mockContactsSelector);
        Application.SELECTOR.SetMock(subMarketSelector);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Test.StartTest();
        SSMOFalloutHandlerService handler = new SSMOFalloutHandlerService();
        handler.execute(mockInstantIngestorEvent);
        Test.StopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Contact.Id => contactId,
                            Contact.SSMO_Business_Account_Id__c => businessAccountId,
                            Contact.Submarket__c => submarketId
                        }
                    }
                )
            );
    }
}