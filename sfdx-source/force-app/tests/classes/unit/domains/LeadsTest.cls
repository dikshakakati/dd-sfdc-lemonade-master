/**
 * @author Deloitte
 * @date 27/03/2024
 * @description Test class for Leads domain class.
 */
@isTest(SeeAllData=false)
/**
 * @description It is used to test the initialisation of the domain class.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class LeadsTest {
    static final String ACCOUNT_NAME_BUSINESS = 'Test Business';
    static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    static final String ASSERT_MESSAGE = 'Unexpected Result: Last Inbound Date is null';
    static final String UNVERIFIED = 'Unverified';
    static final String INCOVERAGE = 'In Coverage';
    static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    static final String OPPORTUNITY_NAME = 'Test Opportunity';
    static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    static final String CONTACT_FIRSTNAME = 'Stephen';
    static final String CONTACT_LASTNAME = 'Ross';
    static final String STATIC_RESOURCE_TEST_CSV = 'LeadToStoreAccountConversionMapping';
    static final String STATIC_RESOURCE_TEST_MAPPINGS = 'LeadConversionSObjectsMapping';
    private static final String UNIQUE_IDENTIFIER1 = '12345a53-e8d9-4a0c-9193-9152aeb86fe4';

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Lead> leadsToInstantiate = new List<Lead>();
        //ILeads Instance Creation Call
        Leads.newInstance(leadsToInstantiate);
        //Default Constructor Call
        Leads newLead = new Leads(leadsToInstantiate);
        //fflib_IDomainConstructor call
        Leads.Constructor constructorObject = new Leads.Constructor();
        constructorObject.construct(leadsToInstantiate);
        System.assertNotEquals(
            Leads.newInstance(leadsToInstantiate),
            newLead,
            'These objects should not be similar'
        );
    }

    /**
     * @description To test whether address fields are nullified.
     */
    @isTest
    private static void testWhenLeadAddressUpdatedThenResetAttributes() {
        Id mcDonaldId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id pizzaHutId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = mcDonaldId,
                FirstName = 'Mc Donald Australia',
                Street = 'Sydney',
                Coverage__c = INCOVERAGE,
                Address_Verification_Status__c = UNVERIFIED
            ),
            new Lead(Id = pizzaHutId, FirstName = 'Pizza Hut', Street = 'Queensland')
        };

        Leads.newInstance(newLeads).resetAddressAttributes();

        System.assertEquals(null, newLeads[0].Coverage__c, 'Coverage is not reset.');
        System.assertEquals(
            'Unverified',
            newLeads[0].Address_Verification_Status__c,
            'Status is not updated to unverified.'
        );
    }

    /**
     * @description To test whether fields are defaulted on Lead insert.
     */
    @isTest
    private static void testWhenLeadInsertedThenDefaultAttributes() {
        Id mcDonaldId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id pizzaHutId = fflib_IDGenerator.generate(Lead.SObjectType);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = mcDonaldId,
                FirstName = 'Mc Donald Australia',
                Street = 'Sydney',
                Coverage__c = INCOVERAGE,
                Address_Verification_Status__c = UNVERIFIED
            ),
            new Lead(Id = pizzaHutId, FirstName = 'Pizza Hut', Street = 'Queensland')
        };
        Leads.newInstance(newLeads).setDefaultValuesBeforeConversion();
        System.assertEquals('New', newLeads[0].Type__c, 'Lead Type is not defaulted.');
    }

    /**
     * @description To test lead conversion with existing store account scenario.
     */
    @isTest
    private static void testWhenLeadsConvertedWithExistingStoreAccountsThenDontCreateStoreAccount() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        List<Xref__c> xrefsByExternalId = new List<Xref__c>();
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
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Substage__c, 'Untouched')
            .setField(Opportunity.Type, 'New')
            .setField(Opportunity.Deal_Type__c, 'Standard')
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Former Partner')
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
            .setField(Account.Name, 'TestMcdonaldCompany')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .setField(Account.Account_ID18__c, storeAccountId)
            .setField(Account.parentId, parentAccountId)
            .setField(Account.BillingStreet, 'Test Street')
            .setField(Account.BillingCity, 'Test City')
            .setField(Account.BillingCountry, 'Test Country')
            .setField(Account.BillingPostalCode, '12345')
            .setField(Account.BillingState, 'Test State')
            .setField(Account.Preferred_Language__c, '')
            .setField(Account.Hours_of_Operation__c, '');
        Account testStoreAccount = (Account) testStoreAccountFake.toSObject();
        Xref__c testXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Xref_Status__c, 'Active')
            .setField(Xref__c.Salesforce_Account_Name__c, testStoreAccount.Id)
            .setField(Xref__c.External_ID__c, '12345')
            .setParent('Salesforce_Account_Name__r', testStoreAccountFake)
            .toSObject();
        Lead testLead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.FirstName, 'McDonald')
            .setField(Lead.LastName, 'Franchise')
            .setField(Lead.Company, 'TestMcdonaldCompany')
            .setField(Lead.Email, 'testMcdonald@test.com')
            .setField(Lead.Street, 'Test Street')
            .setField(Lead.City, 'Test City')
            .setField(Lead.Country, 'Test Country')
            .setField(Lead.State, 'Test State')
            .setField(Lead.PostalCode, '12345')
            .setField(Lead.Store_ID__c, '12345')
            //.setField(Lead.PreferredLanguage__c, 'English')
            .setField(Lead.HoursOfOperation__c, '2')
            .setField(Lead.IsConverted, true)
            .setField(Lead.convertedAccountId, testAccount.Id)
            .setField(Lead.convertedContactId, testContact.Id)
            .setField(Lead.convertedOpportunityId, testOpportunity.Id)
            .setField(Lead.Lead_Conversion_Type__c, 'Manual')
            .toSObject();
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        xrefsByExternalId.add(testXref);
        List<StaticResource> staticResourceList1 = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_MAPPINGS
        ];
        List<StaticResource> staticResourceList2 = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IStaticResourcesSelector staticResourceSelectorMock = (IStaticResourcesSelector) mocks.mock(
            IStaticResourcesSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(staticResourceSelectorMock.SObjectType()).thenReturn(StaticResource.SObjectType);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_TEST_MAPPINGS))
            .thenReturn(staticResourceList1);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_TEST_CSV))
            .thenReturn(staticResourceList2);
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectXrefByExternalId(new List<String>{ testLead.Store_ID__c })
            )
            .thenReturn(xrefsByExternalId);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.Selector.setMock(staticResourceSelectorMock);
        Application.Selector.setMock(xrefSelectorMock);
        Leads.newInstance(new List<Lead>{ testLead }).processLeadsOnConversion();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerUpsert(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        //Account.Preferred_Language__c => testLead.PreferredLanguage__c,
                        Account.Hours_of_Operation__c => testLead.HoursOfOperation__c
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test lead conversion with no existing store account scenario.
     */
    @isTest
    private static void testWhenLeadsConvertedThenAccountContactAndOpportunitySourceStamped() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
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
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Substage__c, 'Untouched')
            .setField(Opportunity.Type, 'New')
            .setField(Opportunity.Deal_Type__c, 'Standard')
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Former Partner')
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
        Lead testLead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.FirstName, 'McDonald')
            .setField(Lead.LastName, 'Franchise')
            .setField(Lead.Company, 'TestMcdonaldCompany')
            .setField(Lead.Email, 'testMcdonald@test.com')
            .setField(Lead.Street, 'Test Street')
            .setField(Lead.IsConverted, true)
            .setField(Lead.convertedAccountId, testAccount.Id)
            .setField(Lead.convertedContactId, testContact.Id)
            .setField(Lead.convertedOpportunityId, testOpportunity.Id)
            .setField(Lead.Lead_Conversion_Type__c, 'Manual')
            .toSObject();
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<StaticResource> staticResourceList = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IStaticResourcesSelector staticResourceSelectorMock = (IStaticResourcesSelector) mocks.mock(
            IStaticResourcesSelector.class
        );
        ILeads leadInstance = Leads.newInstance(new List<Lead>{ testLead });
        mocks.startStubbing();
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(staticResourceSelectorMock.SObjectType()).thenReturn(StaticResource.SObjectType);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_TEST_CSV))
            .thenReturn(staticResourceList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.Selector.setMock(staticResourceSelectorMock);
        leadInstance.processLeadsOnConversion();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test lead conversion with existing store account scenario.
     */
    @isTest
    private static void testWhenLeadsConvertedThenBusinessReferenceCreated() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Account testAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, '')
            .setField(Account.Is_Lead_Converted_To_Existing_Account__c, true)
            .toSObject();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(Brand_Association__c.class)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccountId)
            .setField(Brand_Association__c.Brand_Name__c, brandId)
            .toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, testAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Substage__c, 'Untouched')
            .setField(Opportunity.Type, 'New')
            .setField(Opportunity.Deal_Type__c, 'Standard')
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Former Partner')
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
        Lead testLead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.FirstName, 'McDonald')
            .setField(Lead.LastName, 'Franchise')
            .setField(Lead.Company, 'TestMcdonaldCompany')
            .setField(Lead.Email, 'testMcdonald@test.com')
            .setField(Lead.Street, 'Test Street')
            .setField(Lead.IsConverted, true)
            .setField(Lead.convertedAccountId, testAccount.Id)
            .setField(Lead.convertedContactId, testContact.Id)
            .setField(Lead.convertedOpportunityId, testOpportunity.Id)
            .setField(Lead.Lead_Conversion_Type__c, 'Manual')
            .setField(Lead.SSMO_UUID__c, UNIQUE_IDENTIFIER1)
            .setField(Lead.Store_ID__c, storeId)
            .toSObject();
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<StaticResource> staticResourceList = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        ILeadsSelector leadsSelectorMock = (ILeadsSelector) mocks.mock(
            ILeadsSelector.class
        );
        IStaticResourcesSelector staticResourceSelectorMock = (IStaticResourcesSelector) mocks.mock(
            IStaticResourcesSelector.class
        );
        IBrandAssociationsSelector brandassociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
        	IBrandAssociationsSelector.class);
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        ILeads leadInstance = Leads.newInstance(new List<Lead>{ testLead });
        mocks.startStubbing();
        mocks.when(businessVerticalsSelectorMock.SObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(staticResourceSelectorMock.SObjectType()).thenReturn(StaticResource.SObjectType);
        mocks.when(staticResourceSelectorMock.selectByName(STATIC_RESOURCE_TEST_CSV))
            .thenReturn(staticResourceList);
        mocks.when(leadsSelectorMock.SObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(leadsSelectorMock.selectById(new Set<Id>{leadId})).thenReturn(new List<Lead>{ testLead });
        mocks.when(brandassociationsSelectorMock.SObjectType()).thenReturn(Brand_Association__c.SObjectType);
        mocks.when(brandassociationsSelectorMock.selectByBusinessAccountIds(new Set<Id>{parentAccountId})).thenReturn(new List<Brand_Association__c>{ brandAssociation });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(brandassociationsSelectorMock);
        Application.Selector.setMock(leadsSelectorMock);
        Application.Selector.setMock(businessVerticalsSelectorMock);
        Application.Selector.setMock(staticResourceSelectorMock);
         Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        leadInstance.processLeadsOnConversion();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject());
    }

     /**
     * @description To test whether Last Inbound Date is updated on Lead.
     */
    @isTest
    private static void testWhenLeadPrimaryCampaignSourceUpdatedThenLastInboundDateUpdated() {
        Id leadId1 = fflib_IDGenerator.generate(Lead.SObjectType);
        Id leadId2 = fflib_IDGenerator.generate(Lead.SObjectType);
        Id campaignId = fflib_IDGenerator.generate(Campaign.SObjectType);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId1,
                Coverage__c = INCOVERAGE,
                Address_Verification_Status__c = UNVERIFIED,
                Primary_Campaign_Source__c = campaignId
            ),
            new Lead(
                Id = leadId2,
                Coverage__c = INCOVERAGE,
                Address_Verification_Status__c = UNVERIFIED
            )
        };
        Leads.newInstance(newLeads).updateLastInboundDateTime();
        System.assertNotEquals(null, newLeads[0].Last_Inbound_Date_Time__c, ASSERT_MESSAGE);
        System.assertEquals(null, newLeads[1].Last_Inbound_Date_Time__c, ASSERT_MESSAGE);
    }
}