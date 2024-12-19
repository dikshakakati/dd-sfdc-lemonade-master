/**
 * @author Deloitte
 * @date 03/27/2023
 * @description Test class for Leads Handler.
 */
@isTest(SeeAllData=false)
private class LeadsHandlerTest {
    static final String VERIFIED = 'Verified';
    static final String REJECTED = 'Rejected';
    static final String INCOVERAGE = 'In Coverage';
    static final String LEAD_NAME = 'Test Lead';
    static final String TIME_ZONE_BACKEND_AMERICA_LOSANGELES = 'America/Los_Angeles';
    static final String TIME_ZONE_BACKEND_AMERICA_NEWYORK = 'America/New_York';
    /**
     * @description This method is used to test Leads TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Lead> newLeads = new List<Lead>();
        LeadsHandler leadsHandlerObject = new LeadsHandler(newLeads);
        LeadsHandler.Constructor objConstructor = new LeadsHandler.Constructor();
        objConstructor.construct(newLeads);
        System.assertNotEquals(
            leadsHandlerObject,
            objConstructor.construct(newLeads),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on Lead update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadsUpdatedThenCallResetAddressAttributes() {
        Id leadId = Fake.generateId(Lead.class);
        Id campaignId = Fake.generateId(Campaign.class);
        List<Lead> newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Address_Verification_Status__c = REJECTED,
                Street = 'Queensland Street',
                Phone = '998888',
                isConverted = true,
                Primary_Campaign_Source__c = campaignId
            )
        };
        List<Lead> oldLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Address_Verification_Status__c = VERIFIED,
                Coverage__c = INCOVERAGE,
                Phone = '887778',
                Street = 'Sydney St',
                isConverted = false
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILeads leadsMock = (ILeads) mocks.mock(ILeads.class);
        mocks.startStubbing();
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(leadsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, Lead>(oldLeads));
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);

        ((ILeads) mocks.verify(leadsMock, 1)).resetAddressAttributes();
        ((ILeads) mocks.verify(leadsMock, 1)).updateLastInboundDateTime();
        System.assertEquals(newLeads[0].Coverage__c, null, 'The attributes are not reset');
    }

    /**
     * @description To test method call on Lead insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadsInsertedThenResetAddressAttributeNotCalled() {
        Id leadId = Fake.generateId(Lead.class);
        List<Lead> newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '839393',
                Company = 'KFC',
                LastName = 'Wraps Last'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Leads leadsMock = (Leads) mocks.mock(Leads.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(leadsMock);
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Leads.setConstructorMock(constructor);
        IAddressVerificationService accountAddressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );

        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            accountAddressVerificationServiceMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(newLeads);
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((IAddressVerificationService) mocks.verify(accountAddressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(newLeads);
        ((ILeads) mocks.verify(leadsMock, 0)).resetAddressAttributes();
    }

    /**
     * @description To test method call time zone calculation service on Lead insert.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadInsertedThenCallTimeZoneCalculationService() {
        List<Lead> newLeads = new List<Lead>{
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.SObjectType),
                LastName = LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_NEWYORK
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITimeZoneCalculationService timeZoneCalculationServiceMock = (ITimeZoneCalculationService) mocks.mock(
            ITimeZoneCalculationService.class
        );
        Application.SERVICE.setMock(
            ITimeZoneCalculationService.class,
            timeZoneCalculationServiceMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(newLeads);
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((ITimeZoneCalculationService) mocks.verify(timeZoneCalculationServiceMock, 1))
            .calculateTimeZone(newLeads);
    }

    /**
     * @description To test method call time zone calculation service on Lead update.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadUpdatedThenCallTimeZoneCalculationService() {
        Id leadIdToBeUpdated = fflib_IDGenerator.generate(Lead.SObjectType);
        List<Lead> oldLeads = new List<Lead>{
            new Lead(
                Id = leadIdToBeUpdated,
                LastName = LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_NEWYORK
            )
        };
        List<Lead> newLeads = new List<Lead>{
            new Lead(
                Id = leadIdToBeUpdated,
                LastName = LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_LOSANGELES
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITimeZoneCalculationService timeZoneCalculationServiceMock = (ITimeZoneCalculationService) mocks.mock(
            ITimeZoneCalculationService.class
        );
        Application.SERVICE.setMock(
            ITimeZoneCalculationService.class,
            timeZoneCalculationServiceMock
        );
        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, Lead>(oldLeads));
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((ITimeZoneCalculationService) mocks.verify(timeZoneCalculationServiceMock, 1))
            .calculateTimeZone(newLeads);
    }

    /**
     * @description To test method call on Lead conversion.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadsConvertedThenProcessLeadsCalled() {
        Id leadId = Fake.generateId(Lead.class);
        List<Lead> newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '839393',
                Company = 'KFC',
                LastName = 'Wraps Last',
                IsConverted = true
            )
        };
        List<Lead> oldLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Address_Verification_Status__c = VERIFIED,
                Coverage__c = INCOVERAGE,
                Phone = '887778',
                Street = 'Sydney St',
                isConverted = false
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Leads leadsMock = (Leads) mocks.mock(Leads.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(leadsMock);
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Leads.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, Lead>(oldLeads));
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((ILeads) mocks.verify(leadsMock, 1)).processLeadsOnConversion();
    }

    /**
     * @description To test if the Cassie Id is encryption is triggered on lead update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadIsInsertedThenCassieIdEncryptionInitiated() {
        Id leadId = Fake.generateId(Lead.class);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '839393',
                Company = 'KFC',
                LastName = 'Wraps Last',
                Email = 'abc@gmail.com'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Leads leadsMock = (Leads) mocks.mock(Leads.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(leadsMock);
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Leads.setConstructorMock(constructor);
        ICassieIdEncryptionService serviceMock = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );

        Application.SERVICE.setMock(ICassieIdEncryptionService.class, serviceMock);

        fflib_SObjectDomain.Test.Database.onInsert(newLeads);
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newLeads, 'Email', 'Email_Cassie_ID__c');
    }

    /**
     * @description To test if the Cassie Id is encryption and DoNotCall field update
     * is triggered on lead update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadIsUpdatedThenCassieIdEncryptionAndDoNotCallUpdated() {
        Id leadId = Fake.generateId(Lead.class);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '1234567',
                Company = 'KFC',
                LastName = 'Wraps Last',
                Email = 'abc@gmail.com',
                SMS_Opted_Out__c = true
            )
        };
        Lead[] oldLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '123456789',
                Company = 'KFC',
                LastName = 'Wraps Last',
                Email = 'abcdef@gmail.com',
                SMS_Opted_Out__c = false
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Leads leadsMock = (Leads) mocks.mock(Leads.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(leadsMock);
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Leads.setConstructorMock(constructor);
        ICassieIdEncryptionService serviceMock = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );
        IOptOutOfCommunicationsService optOutOfCommunicationsServiceMock = (IOptOutOfCommunicationsService) mocks.mock(
            IOptOutOfCommunicationsService.class
        );

        Application.SERVICE.setMock(ICassieIdEncryptionService.class, serviceMock);
        Application.SERVICE.setMock(
            IOptOutOfCommunicationsService.class,
            optOutOfCommunicationsServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, Lead>(oldLeads));
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newLeads, 'Email', 'Email_Cassie_ID__c');
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 1))
            .updateDoNotCallAndSMSOptedOut(newLeads);
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 1))
            .updateDateSMSOptedOutOrIn(newLeads);
    }

    /**
     * @description To test if the Cassie Id is encryption and DoNotCall field update
     * is triggered on lead update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLeadIsUpdatedThenDateSMSOptedOutNotUpdated() {
        Id leadId = Fake.generateId(Lead.class);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '1234567',
                Company = 'KFC',
                LastName = 'Wraps Last',
                Email = 'abc@gmail.com',
                SMS_Opted_Out__c = true
            )
        };
        Lead[] oldLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                FirstName = 'Fujito Wraps',
                Street = 'Queensland Street',
                Phone = '123456789',
                Company = 'KFC',
                LastName = 'Wraps Last',
                Email = 'abcdef@gmail.com',
                SMS_Opted_Out__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Leads leadsMock = (Leads) mocks.mock(Leads.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(leadsMock);
        mocks.when(leadsMock.getType()).thenReturn(Schema.Lead.SObjectType);
        mocks.stopStubbing();
        Leads.setConstructorMock(constructor);
        IOptOutOfCommunicationsService optOutOfCommunicationsServiceMock = (IOptOutOfCommunicationsService) mocks.mock(
            IOptOutOfCommunicationsService.class
        );
        Application.SERVICE.setMock(
            IOptOutOfCommunicationsService.class,
            optOutOfCommunicationsServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, Lead>(oldLeads));
        fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 0))
            .updateDateSMSOptedOutOrIn(newLeads);
    }
}