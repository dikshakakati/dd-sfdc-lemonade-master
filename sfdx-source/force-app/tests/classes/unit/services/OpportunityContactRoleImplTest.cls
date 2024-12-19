/**
 * @author DoorDash
 * @date 07/21/2022
 * @description Test class for OpportunityContactRoleImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class OpportunityContactRoleImplTest {
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsUpdatedThenUpdateOppContactRoles() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        Opportunity newOpportunity = new Opportunity(
            Id = oppId,
            Name = 'Test 1',
            StageName = 'Prospecting',
            SBQQ__PrimaryQuote__c = quoteId
        );

        OpportunityContactRole oppContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.Quote__c, null)
            .setField(OpportunityContactRole.OpportunityId, oppId)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectContractSignatoryOppContactRole(
                    new Set<Id>{ oppId }
                )
            )
            .thenReturn(new List<OpportunityContactRole>{ oppContactRole });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        OpportunityContactRoleService.stampPrimaryQuoteOnOppContactRole(
            new Map<Id, Opportunity>{ oppId => newOpportunity }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OpportunityContactRole.Id => oppContactRole.Id,
                        OpportunityContactRole.Quote__c => quoteId,
                        OpportunityContactRole.OpportunityId => oppId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsUpdatedThenNoContactRoleUpdate() {
        Id quoteId = Fake.generateId(Order.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        Opportunity newOpportunity = new Opportunity(
            Id = Fake.generateId(Opportunity.class),
            Name = 'Test 1',
            StageName = 'Prospecting',
            SBQQ__PrimaryQuote__c = quoteId
        );

        OpportunityContactRole oppContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.Quote__c, null)
            .setField(OpportunityContactRole.OpportunityId, newOpportunity.Id)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectContractSignatoryOppContactRole(
                    new Set<Id>{ newOpportunity.Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        OpportunityContactRoleService.stampPrimaryQuoteOnOppContactRole(new Map<Id, Opportunity>{});
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityContactRoleIsUpdatedThenUpdateQuoteContractSignatoryFlag() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        Opportunity newOpportunity = new Opportunity(
            Id = Fake.generateId(Opportunity.class),
            Name = 'Test 1',
            StageName = 'Prospecting',
            SBQQ__PrimaryQuote__c = quoteId
        );

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = quoteId,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Status__c = 'Approved'
        );

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            Id = opportunityContactRoleId,
            OpportunityId = newOpportunity.Id,
            Role = 'Contract Signatory'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectByQuoteIdAndFilterByContractSignatory(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(new List<OpportunityContactRole>{ oppContactRole });
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectByOpportunity(new Set<Id>{ newOpportunity.Id }))
            .thenReturn(new List<SBQQ__Quote__c>{ quote });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        OpportunityContactRoleService.updateRelatedQuotesContractSignatoryExists(
            new List<OpportunityContactRole>{ oppContactRole }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIsUpdatedThenUpdateContractSignatoryFlag() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        Opportunity newOpportunity = new Opportunity(
            Id = Fake.generateId(Opportunity.class),
            Name = 'Test 1',
            StageName = 'Prospecting',
            SBQQ__PrimaryQuote__c = quoteId
        );

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = quoteId,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Status__c = 'Approved'
        );

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            Id = opportunityContactRoleId,
            OpportunityId = newOpportunity.Id,
            Role = 'Contract Signatory'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectByQuoteIdAndFilterByContractSignatory(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(new List<OpportunityContactRole>{ oppContactRole });
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectById(new Set<Id>{ quote.Id }))
            .thenReturn(new List<SBQQ__Quote__c>{ quote });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        OpportunityContactRoleService.updateContractSignatoryExists(new Set<Id>{ quote.Id });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description LEM-13474 Test to update Contact Role to 'Has Signed Contract'
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenClosedWonOpportunitiesHasContactSignatoryRoleThenUpdateContact() {
        Id accountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        Contact newContact = new Contact(
            Id = contactId,
            FirstName = 'Test',
            Has_Signed_Contract__c = ''
        );

        String opportunityJson =
            '{' +
            '"Id": "' +
            oppId +
            '",' +
            '"AccountId": "' +
            accountId +
            '",' +
            '"Name": "Test Opportunity",' +
            '"StageName": "Closed Won",' +
            '"Account_Segment__c": "SMB",' +
            '"Nintex_Use_Case__c": ""' +
            '}';

        // Deserialize the JSON string into an Opportunity object
        Opportunity newOpportunity = (Opportunity) JSON.deserialize(
            opportunityJson,
            Opportunity.class
        );

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            Id = opportunityContactRoleId,
            OpportunityId = oppId,
            ContactId = contactId,
            Role = CONTRACT_SIGNATORY_CONTACT_ROLE
        );

        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
        opptyMap.put(newOpportunity.id, newOpportunity);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectContractSignatoryOppContactRole(
                    new Set<Id>{ oppId }
                )
            )
            .thenReturn(new List<OpportunityContactRole>{ oppContactRole });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        // Call the method under test
        OpportunityContactRoleService.updateContractSignatoryContactRole(opptyMap);

        // Verify that the appropriate operations were called on the Unit of Work
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Contact.Id => newContact.Id,
                        Contact.Has_Signed_Contract__c => 'Yes'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description LEM-15246 Test to check if acr is getting created on business account when created from nintex'
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityCreatedByNintexSSMOThenSkipACRCreationOnBusinessAccount() {
        Id accountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id contactId1 = Fake.generateId(Contact.class);
        Id contactId2 = Fake.generateId(Contact.class);

        String opportunityJson =
            '{' +
            '"Id": "' +
            oppId +
            '",' +
            '"AccountId": "' +
            accountId +
            '",' +
            '"Name": "Test Opportunity",' +
            '"StageName": "Closed Won",' +
            '"Account_Segment__c": "SMB",' +
            '"Nintex_Use_Case__c": "SSMO"' +
            '}';

        // Deserialize the JSON string into an Opportunity object
        Opportunity newOpportunity = (Opportunity) JSON.deserialize(
            opportunityJson,
            Opportunity.class
        );

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            Id = opportunityContactRoleId,
            OpportunityId = oppId,
            ContactId = contactId,
            Role = CONTRACT_SIGNATORY_CONTACT_ROLE
        );

        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
        opptyMap.put(newOpportunity.id, newOpportunity);
        Map<Id, List<Id>> inputMap = new Map<Id, List<Id>>();
        List<Id> idList = new List<Id>{ contactId1, contactId2 };
        inputMap.put(accountId, idList);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountContactRelationsService acrServiceMock = (IAccountContactRelationsService) mocks.mock(
            IAccountContactRelationsService.class
        );

        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectContractSignatoryOppContactRole(
                    new Set<Id>{ oppId }
                )
            )
            .thenReturn(new List<OpportunityContactRole>{ oppContactRole });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppContactRoleSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAccountContactRelationsService.class, acrServiceMock);

        // Call the method under test
        Test.startTest();
        OpportunityContactRoleService.updateContractSignatoryContactRole(opptyMap);
        Test.stopTest();

        ((IAccountContactRelationsService) mocks.verify(acrServiceMock, 0))
            .validateAndCreateAcr(inputMap, mockUOW);
    }

    /**
     * @description To test whether OpportunityContactRole record is created or not if
     * OpportunityIdToContactId map is passed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdToContactIdMapIsPassedThenCreateOCR() {
        Map<Id, Id> opportunityIdToContactIdMap = new Map<Id, Id>();
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        opportunityIdToContactIdMap.put(opportunityId, contactId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunityContactRoleService.createOCR(opportunityIdToContactIdMap, true);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}