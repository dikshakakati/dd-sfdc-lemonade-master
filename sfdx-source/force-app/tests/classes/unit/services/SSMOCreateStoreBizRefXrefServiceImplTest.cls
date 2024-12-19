/**
 * @author Deloitte
 * @date 07/05/2024
 * @description This is test class for SSMOCreateStoreBizRefXrefServiceImpl class
 */
@isTest
public class SSMOCreateStoreBizRefXrefServiceImplTest {
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CONTACT_FIRSTNAME = 'Matched';
    private static final String CONTACT_LASTNAME = 'Contact';
    private static final String CONTACT_EMAIL = 'test@testemail.com';
    private static final String CORPORATE = 'Corporate';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String BUSINESS = 'Business';
    private static final String STORE = 'Store';
    private static final String RESTAURANT = 'Restaurant';
    private static final String NEW_VALUE ='New';

    /**
     * @description It is used verify creation of Store account, Bizref and Xref on Contact insertion or updation.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsInsertedOrUpdatedThenCreateStoreAccountBizRefAndXref() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id brandId = Fake.generateId(Brand__c.class);

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, BUSINESS)
            .setField(Account.BillingCountryCode,'US' )
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c, businessAccountId)
                        .setField(Brand_Association__c.Brand_Name__c, brandId)
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();
        Contact newContact = new Contact(
            Id = contactId,
            AccountID = businessAccountId,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL,
            SSMO_Matching_Account_Id__c = businessAccountId,
            Inbound_Ingestion_Log__c = inboundInjestionLogId,
            Unique_Identifier__c = '4e3dc12d-2f89-421e-a71b-a8f96740bf48',
            Business_Id__c = '123455',
            Store_Id__c = '434535'
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = RESTAURANT,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = RESTAURANT,
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = RESTAURANT,
                Business_Vertical_ID__c = ''
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISSMOFalloutContactsService falloutContactsServiceMock = (ISSMOFalloutContactsService) mocks.mock(
            ISSMOFalloutContactsService.class
        );
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectBusinessVerticalByName(RESTAURANT))
            .thenReturn(businessVerticalsRecords);

        mocks.when(acountsSelectorMock.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(
                acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{ newContact.Business_Id__c },
                    new Set<String>{ CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
            )
            .thenReturn(new List<Business_Reference__c>{});
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectXrefByExternalIdsAndExternalSourceMDS(
                    new Set<String>{ newContact.Store_Id__c }
                )
            )
            .thenReturn(new List<XRef__c>{});
        mocks.stopStubbing();
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.SERVICE.setMock(
            ISSMOFalloutContactsService.class,
            falloutContactsServiceMock
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
            new List<Contact>{ newContact }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.ParentId => businessAccountId,
                        Account.Brand__c => brandId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.External_Id__c => newContact.Business_Id__c,
                        Business_Reference__c.Brand__c => brandId,
                        Business_Reference__c.CurrencyIsoCode => 'USD'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.External_ID__c => newContact.Store_Id__c,
                        Xref__c.Integration_Status__c => NEW_VALUE
                    }
                )
            );
        ((ISSMOFalloutContactsService) mocks.verify(falloutContactsServiceMock, 1))
            .createRelatedRecordsBasedOnSSMOPayload(new List<Contact>{ newContact });
    }
    /**
     * @description It is used verify creation of Bizref and Xref on Contact insertion or updation when
     * there is matching Store Account found.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsInsertedOrUpdatedWithStoreAccountThenCreateBizRefAndXref() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id brandId = Fake.generateId(Brand__c.class);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setField(Account.Record_Type_Name__c, STORE)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Id, storeAccountId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, BUSINESS)
            .setField(Account.BillingCountryCode,'NZ' )
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c, businessAccountId)
                        .setField(Brand_Association__c.Brand_Name__c, brandId)
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();
        Contact newContact = new Contact(
            Id = contactId,
            AccountID = businessAccountId,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL,
            SSMO_Matching_Account_Id__c = storeAccountId,
            Inbound_Ingestion_Log__c = inboundInjestionLogId,
            Unique_Identifier__c = '4e3dc12d-2f89-421e-a71b-a8f96740bf48',
            Business_Id__c = '123455',
            Store_Id__c = '434535'
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = RESTAURANT,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = RESTAURANT,
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = RESTAURANT,
                Business_Vertical_ID__c = '',
                Id = businessVerticalId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectBusinessVerticalByName(RESTAURANT))
            .thenReturn(businessVerticalsRecords);

        mocks.when(acountsSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(
                acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{ newContact.Business_Id__c },
                    new Set<String>{ CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
            )
            .thenReturn(new List<Business_Reference__c>{});
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectXrefByExternalIdsAndExternalSourceMDS(
                    new Set<String>{ newContact.Store_Id__c }
                )
            )
            .thenReturn(new List<XRef__c>{});
        mocks.stopStubbing();
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
            new List<Contact>{ newContact }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.External_Id__c => newContact.Business_Id__c,
                        Business_Reference__c.Brand__c => brandId,
                        Business_Reference__c.CurrencyIsoCode => 'NZD'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.External_ID__c => newContact.Store_Id__c,
                        Xref__c.Integration_Status__c => NEW_VALUE
                    }
                )
            );
    }
    /**
     * @description It is used verify creation of Xref on Contact insertion or updation when
     * there is Matching store account and Bizref is found.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsInsertedOrUpdatedWithStoreAccountBizRefThenCreateXref() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id brandId = Fake.generateId(Brand__c.class);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setField(Account.Record_Type_Name__c, STORE)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Id, storeAccountId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, BUSINESS)
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c, businessAccountId)
                        .setField(Brand_Association__c.Brand_Name__c, brandId)
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();
        Contact newContact = new Contact(
            Id = contactId,
            AccountID = businessAccountId,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL,
            SSMO_Matching_Account_Id__c = storeAccountId,
            Inbound_Ingestion_Log__c = inboundInjestionLogId,
            Unique_Identifier__c = '4e3dc12d-2f89-421e-a71b-a8f96740bf48',
            Business_Id__c = '123455',
            Store_Id__c = '434535'
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = RESTAURANT,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = RESTAURANT,
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = RESTAURANT,
                Business_Vertical_ID__c = '',
                Id = businessVerticalId
            )
        };
        Id bizzRefID = Fake.generateId(Business_Reference__c.class);
        Business_Reference__c businessRef = new Business_Reference__c(
            Id = bizzRefID,
            Default_Type__c = CORPORATE,
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            CurrencyIsoCode = 'USD',
            External_Id__c = '123455'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectBusinessVerticalByName(RESTAURANT))
            .thenReturn(businessVerticalsRecords);

        mocks.when(acountsSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(
                acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{ newContact.Business_Id__c },
                    new Set<String>{ CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef });
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectXrefByExternalIdsAndExternalSourceMDS(
                    new Set<String>{ newContact.Store_Id__c }
                )
            )
            .thenReturn(new List<XRef__c>{});
        mocks.stopStubbing();
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
            new List<Contact>{ newContact }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.External_ID__c => newContact.Store_Id__c,
                        Xref__c.Integration_Status__c => NEW_VALUE
                    }
                )
            );
    }

    /**
     * @description It is used verify Error Logging during creation of Store account, Bizref and Xref.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsInsertedOrUpdatedWithStoreAccountBizRefXRefThenDontCreate() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id brandId = Fake.generateId(Brand__c.class);
		Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setField(Account.Record_Type_Name__c,'Store' )
            .setField(Account.ParentId, businessAccountId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId,businessRecordTypeId)
            .setField(Account.Segment__c,ACCOUNT_SEGMENT_SMB )
            .setField(Account.Record_Type_Name__c,'Business' )
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c , businessAccountId)
                        .setField(Brand_Association__c.Brand_Name__c,brandId )
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class)
                            .setField(Account.Id, businessAccountId)
                        )
                }
            )
			.toSObject();
        Contact newContact = new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME,
                Email = CONTACT_EMAIL,
                SSMO_Matching_Account_Id__c = storeAccountId,
                Inbound_Ingestion_Log__c = inboundInjestionLogId,
                Business_Id__c ='123455',
                Store_Id__c = '434535',
            	Unique_Identifier__c ='4e3dc12d-2f89-421e-a71b-a8f96740bf48'
        );
         List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name ='Restaurant',
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Restaurant',
                Business_Vertical_ID__c = '',
                Id = businessVerticalId
            )
        };
        Id xrefId = Fake.generateId(Xref__c.class);
		Xref__c xRefRecord = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_ID__c, storeAccountId)
            .setField(Xref__c.External_ID__c, '434535')
        	.setField(Xref__c.External_ID_Source__c,EXTERNAL_ID_SOURCE_MDS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectBusinessVerticalByName('Restaurant'))
            .thenReturn(businessVerticalsRecords);

        mocks.when(acountsSelectorMock.selectById(new Set<Id>{storeAccountId})).thenReturn(new List<Account>{storeAccount});
        mocks.when(acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(new Set<Id>{businessAccountId})).thenReturn(new List<Account>{businessAccount});
         mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{newContact.Business_Id__c},
                    new Set<String>{CORPORATE},
                    new Set<String>{EXTERNAL_ID_SOURCE_MDS}
                )
            )
            .thenReturn(new List<Business_Reference__c>{});
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdsAndExternalSourceMDS(new Set<String>{newContact.Store_Id__c}))
            .thenReturn(new List<XRef__c>{ xRefRecord});
        mocks.stopStubbing();
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.DOMAIN.setMock(inboundIngestionLogsMock);
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(new List<Contact> {newContact});
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
     * @description It is used verify Error Logging during creation of Store account, Bizref and Xref.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsInsertedOrUpdatedWithStoreAccountBizRefXRefThenThrowException() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id brandId = Fake.generateId(Brand__c.class);
		Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setField(Account.Record_Type_Name__c,STORE )
            .setField(Account.ParentId, businessAccountId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId,businessRecordTypeId)
            .setField(Account.Segment__c,ACCOUNT_SEGMENT_SMB )
            .setField(Account.Record_Type_Name__c,BUSINESS )
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c , businessAccountId)
                        .setField(Brand_Association__c.Brand_Name__c,brandId )
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class)
                            .setField(Account.Id, businessAccountId)
                        )
                }
            )
			.toSObject();
        Contact newContact = new Contact(
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME,
                Email = CONTACT_EMAIL,
                Inbound_Ingestion_Log__c = inboundInjestionLogId,
                Business_Id__c ='123455',
                Store_Id__c = '434535',
            	Unique_Identifier__c ='4e3dc12d-2f89-421e-a71b-a8f96740bf48'
        );
         List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = RESTAURANT,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = RESTAURANT,
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = RESTAURANT,
                Business_Vertical_ID__c = '',
                Id = businessVerticalId
            )
        };
        Id xrefId = Fake.generateId(Xref__c.class);
		Xref__c xRefRecord = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_ID__c, storeAccountId)
            .setField(Xref__c.External_ID__c, '434535')
        	.setField(Xref__c.External_ID_Source__c,EXTERNAL_ID_SOURCE_MDS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectBusinessVerticalByName('Restaurant'))
            .thenReturn(businessVerticalsRecords);

        mocks.when(acountsSelectorMock.selectById(new Set<Id>{storeAccountId})).thenReturn(new List<Account>{storeAccount});
        mocks.when(acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(new Set<Id>{businessAccountId})).thenReturn(new List<Account>{businessAccount});
         mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{newContact.Business_Id__c},
                    new Set<String>{CORPORATE},
                    new Set<String>{EXTERNAL_ID_SOURCE_MDS}
                )
            )
            .thenReturn(new List<Business_Reference__c>{});
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdsAndExternalSourceMDS(new Set<String>{newContact.Store_Id__c}))
            .thenReturn(new List<XRef__c>{ xRefRecord});
        mocks.stopStubbing();
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.DOMAIN.setMock(inboundIngestionLogsMock);
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(new List<Contact> {newContact});
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionLogsMock, 0))
            .updateIngestionLogsWithSucessOrFailureStatus(
                (Set<Id>) fflib_Match.anyObject(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString(),
                (String) fflib_Match.anyString()
                 );
    }
}