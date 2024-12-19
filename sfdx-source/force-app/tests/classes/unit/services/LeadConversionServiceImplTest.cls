/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Test class for LeadConversionServiceImpl class.
 */
@isTest(SeeAllData=false)
private class LeadConversionServiceImplTest {
    private static final String ACCOUNT_NAME_BUSINESS = 'Test Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACTIVE = 'Active';
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String CITY = 'Test City';
    private static final String COMPANY = 'TestMcdonaldCompany';
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String COUNTRY = 'Test Country';
    private static final String DEAL_TYPE_STANDARD = 'Standard';
    private static final String EMAIL = 'testMcdonald@test.com';
    private static final String HOURS_OF_OPERATION = '8am - 5pm all days';
    private static final String LEAD_FIRST_NAME = 'McDonald';
    private static final String LEAD_LAST_NAME = 'Franchise';
    private static final String LEAD_UUID = 'h123456c-595d-1234-99d8-3d8c931d9f82';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String OPPORTUNITY_SUB_STAGE_UNTOUCHED = 'Untouched';
    private static final String OPPORTUNITY_SUB_TYPE = 'Former Partner';
    private static final String OPPORTUNITY_TYPE = 'New';
    private static final String POSTAL_CODE = '12345';
    private static final String STATE = 'Test State';
    private static final String STATIC_RESOURCE_SOBJECTS_CSV = 'LeadConversionSObjectsMapping';
    private static final String STREET = 'Test Street';
    private static final String VALUES_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: mismatch in values returned';
    private static final String CORPORATE = 'Corporate';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_ID = '12345';
    private static final String LEAD_CONVERSION_TYPE_MANUAL = 'Manual';
    private static final String CURRENCY_CODE_USD = 'USD';

    /**
     * @description To test creation of Xref and business Ref creation when SSMO Leads
     * are manually converted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSSMOLeadsManuallyConvertedThenCreateBusinessRefAndXref() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Account mockAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .toSObject();
        Opportunity mockOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, mockAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE)
            .setField(Opportunity.Substage__c, OPPORTUNITY_SUB_STAGE_UNTOUCHED)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE)
            .setField(Opportunity.CloseDate, Date.today().addMonths(1))
            .setField(Opportunity.Source__c, '')
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        Contact testContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Contact_Source__c, '')
            .setField(Contact.Id, contactId)
            .toSObject();
        Fake testStoreAccountFake = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, COMPANY)
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .setField(Account.Account_ID18__c, storeAccountId)
            .setField(Account.parentId, parentAccountId)
            .setField(Account.BillingStreet, STREET)
            .setField(Account.BillingCity, CITY)
            .setField(Account.BillingCountry, COUNTRY)
            .setField(Account.BillingPostalCode, POSTAL_CODE)
            .setField(Account.BillingState, STATE)
            .setField(Account.Preferred_Language__c, '')
            .setField(Account.Hours_of_Operation__c, HOURS_OF_OPERATION);
        Account testStoreAccount = (Account) testStoreAccountFake.toSObject();
        Lead testLead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.FirstName, LEAD_FIRST_NAME)
            .setField(Lead.LastName, LEAD_LAST_NAME)
            .setField(Lead.Company, COMPANY)
            .setField(Lead.Email, EMAIL)
            .setField(Lead.Street, STREET)
            .setField(Lead.City, CITY)
            .setField(Lead.Country, COUNTRY)
            .setField(Lead.State, STATE)
            .setField(Lead.PostalCode, POSTAL_CODE)
            .setField(Lead.Store_ID__c, '12345')
            .setField(Lead.HoursOfOperation__c, HOURS_OF_OPERATION)
            .setField(Lead.IsConverted, true)
            .setField(Lead.ConvertedAccountId, mockAccount.Id)
            .setField(Lead.ConvertedContactId, testContact.Id)
            .setField(Lead.ConvertedOpportunityId, mockOpportunity.Id)
            .setField(Lead.Lead_Conversion_Type__c, 'Manual')
            .setField(Lead.SSMO_UUID__c, LEAD_UUID)
            .toSObject();
        List<StaticResource> staticResources = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_SOBJECTS_CSV
        ];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ILeadsSelector leadSelectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IStaticResourcesSelector staticResourceSelectorMock = (IStaticResourcesSelector) mocks.mock(
            IStaticResourcesSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(leadSelectorMock.SObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(leadSelectorMock.selectById(new Set<Id>{ testLead.Id }))
            .thenReturn(new List<Lead>{ testLead });
        mocks.when(staticResourceSelectorMock.SObjectType()).thenReturn(StaticResource.SObjectType);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_SOBJECTS_CSV))
            .thenReturn(staticResources);
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectXrefByExternalId(new List<String>{ testLead.Store_ID__c })
            )
            .thenReturn(new List<Xref__c>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(leadSelectorMock);
        Application.Selector.setMock(staticResourceSelectorMock);
        Application.Selector.setMock(xrefSelectorMock);
        LeadConversionService.initiateSObjectsCreationOnManualLeadConversion(
            new Set<Id>{ leadId },
            new Map<Id, Account>{ leadId => testStoreAccount }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test collection of Account Id to list of Contracts when Opportunities
     * passed.
     */
    @isTest
    private static void testWhenOpportunitiesPassedThenReturnContractsOnAssociatedAccounts() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Map<Id, List<Contract>> accountIdToContracts = new Map<Id, List<Contract>>();
        Account mockAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Is_Lead_Converted_To_Existing_Account__c, true)
            .toSObject();
        Opportunity mockOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, mockAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE)
            .setField(Opportunity.Substage__c, OPPORTUNITY_SUB_STAGE_UNTOUCHED)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE)
            .setField(Opportunity.CloseDate, Date.today().addMonths(1))
            .setField(Opportunity.Source__c, '')
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.AccountId, mockAccount.Id)
            .setField(Contract.Id, contractId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.Is_Lead_Converted_To_Existing_Account__c, true)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectByParentAccountId(new Set<Id>{ mockAccount.Id }))
            .thenReturn(new List<Contract>{ mockContract });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(contractSelectorMock);
        accountIdToContracts = LeadConversionService.collectContractsOnAssociatedAccounts(
            new List<Opportunity>{ mockOpportunity }
        );
        System.assertEquals(accountIdToContracts.size(), 1, VALUES_MISMATCH_ASSERT_MESSAGE);
        System.assertEquals(
            accountIdToContracts.get(mockAccount.Id).size(),
            1,
            VALUES_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test map of Account Id to list of Contracts not returned when
     * Opportunities passed.
     */
    @isTest
    private static void testWhenOpportunitiesPassedThenContractsOnAssociatedAccountsNotReturned() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Map<Id, List<Contract>> accountIdToContracts = new Map<Id, List<Contract>>();
        Account mockAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Is_Lead_Converted_To_Existing_Account__c, true)
            .toSObject();
        Opportunity mockOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, mockAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE)
            .setField(Opportunity.Substage__c, OPPORTUNITY_SUB_STAGE_UNTOUCHED)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE)
            .setField(Opportunity.CloseDate, Date.today().addMonths(1))
            .setField(Opportunity.Source__c, '')
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectByParentAccountId(new Set<Id>{ mockAccount.Id }))
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(contractSelectorMock);
        accountIdToContracts = LeadConversionService.collectContractsOnAssociatedAccounts(
            new List<Opportunity>{ mockOpportunity }
        );
        System.assertEquals(accountIdToContracts.size(), 0, VALUES_MISMATCH_ASSERT_MESSAGE);
    }
    /**
     * @description To test creation of Xref creation when SSMO Leads
     * are manually converted with existing Business Refrence.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSSMOLeadsManuallyConvertedWithExistingBizRefThenCreateXref() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Account testAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, testAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE)
            .setField(Opportunity.Substage__c, OPPORTUNITY_SUB_STAGE_UNTOUCHED)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE)
            .setField(Opportunity.CloseDate, Date.today().addMonths(1))
            .setField(Opportunity.Source__c, '')
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        Contact testContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Contact_Source__c, '')
            .setField(Contact.Id, contactId)
            .toSObject();
        Fake testStoreAccountFake = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, COMPANY)
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .setField(Account.Account_ID18__c, storeAccountId)
            .setField(Account.parentId, parentAccountId)
            .setField(Account.BillingStreet, STREET)
            .setField(Account.BillingCity, CITY)
            .setField(Account.BillingCountry, COUNTRY)
            .setField(Account.BillingPostalCode, POSTAL_CODE)
            .setField(Account.BillingState, STATE)
            .setField(Account.Preferred_Language__c, '')
            .setField(Account.Hours_of_Operation__c, HOURS_OF_OPERATION);
        Account testStoreAccount = (Account) testStoreAccountFake.toSObject();
        Lead testLead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.FirstName, LEAD_FIRST_NAME)
            .setField(Lead.LastName, LEAD_LAST_NAME)
            .setField(Lead.Company, COMPANY)
            .setField(Lead.Email, EMAIL)
            .setField(Lead.Street, STREET)
            .setField(Lead.City, CITY)
            .setField(Lead.Country, COUNTRY)
            .setField(Lead.State, STATE)
            .setField(Lead.PostalCode, POSTAL_CODE)
            .setField(Lead.Store_ID__c, EXTERNAL_ID)
            .setField(Lead.Business_Id__c, EXTERNAL_ID)
            .setField(Lead.HoursOfOperation__c, HOURS_OF_OPERATION)
            .setField(Lead.IsConverted, true)
            .setField(Lead.ConvertedAccountId, testAccount.Id)
            .setField(Lead.ConvertedContactId, testContact.Id)
            .setField(Lead.ConvertedOpportunityId, testOpportunity.Id)
            .setField(Lead.Lead_Conversion_Type__c,LEAD_CONVERSION_TYPE_MANUAL )
            .setField(Lead.SSMO_UUID__c, LEAD_UUID)
            .toSObject();

        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Business_Reference__c testBusinessReference = new Business_Reference__c(
            Id = businessReferenceId,
            Default_Type__c = CORPORATE,
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            CurrencyIsoCode = CURRENCY_CODE_USD,
            External_Id__c = EXTERNAL_ID
        );
        List<StaticResource> staticResources = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_SOBJECTS_CSV
        ];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ILeadsSelector leadsSelectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IStaticResourcesSelector staticResourceSelectorMock = (IStaticResourcesSelector) mocks.mock(
            IStaticResourcesSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferencesSelector businessReferencesSelectorMock = (IBusinessReferencesSelector) mocks.mock(IBusinessReferencesSelector.class);
        mocks.startStubbing();
        mocks.when(leadsSelectorMock.SObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(leadsSelectorMock.selectById(new Set<Id>{ testLead.Id }))
            .thenReturn(new List<Lead>{ testLead });
        mocks.when(staticResourceSelectorMock.SObjectType()).thenReturn(StaticResource.SObjectType);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_SOBJECTS_CSV))
            .thenReturn(staticResources);
        mocks.when(xrefsSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
            xrefsSelectorMock.selectXrefByExternalId(new List<String>{ testLead.Store_ID__c })
            )
            .thenReturn(new List<Xref__c>{});
        mocks.when(businessReferencesSelectorMock.SObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
            businessReferencesSelectorMock.selectBusRefByExternalId(new Set<String>{ testLead.Business_ID__c })
            )
            .thenReturn(new List<Business_Reference__c>{testBusinessReference});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(leadsSelectorMock);
        Application.Selector.setMock(staticResourceSelectorMock);
        Application.Selector.setMock(xrefsSelectorMock);
        Application.Selector.setMock(businessReferencesSelectorMock);
        LeadConversionService.initiateSObjectsCreationOnManualLeadConversion(
            new Set<Id>{ leadId },
            new Map<Id, Account>{ leadId => testStoreAccount }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.External_ID__c => testLead.Store_ID__c
                    }
                ),
                (Schema.SObjectField)fflib_Match.anyObject(),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId
                    }
                )
            );
    }
}