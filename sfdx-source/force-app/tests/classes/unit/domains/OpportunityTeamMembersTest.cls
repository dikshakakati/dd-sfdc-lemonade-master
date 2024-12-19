/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Test class for OpportunityTeamMembers class
 */
@isTest(SeeAllData=false)
private class OpportunityTeamMembersTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String ACCOUNT_NAME = 'Account 1';
    private static final String OPPORTUNITY_NAME = 'Opportunity 1';
    private static final String OPPORTUNITY_STAGE_NAME = 'Prospecting';
    private static final string SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final string DRIVE_SPECIALIST = 'Drive Specialist';
    private static final String OWNER_NOT_MATCHING_ASSERT_MESSAGE = 'Unexpected result: SDR owner not matching Opportunity Team Member user.';

    /**
     * @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<OpportunityTeamMember> opportunityTeamMemberToInstantiate = new List<OpportunityTeamMember>();
        OpportunityTeamMembers.newInstance(opportunityTeamMemberToInstantiate);
        OpportunityTeamMembers newOpportunityTeamMember = new OpportunityTeamMembers(
            opportunityTeamMemberToInstantiate
        );
        OpportunityTeamMembers.Constructor constructorObject = new OpportunityTeamMembers.Constructor();
        constructorObject.construct(opportunityTeamMemberToInstantiate);
        System.assertNotEquals(
            OpportunityTeamMembers.newInstance(opportunityTeamMemberToInstantiate),
            newOpportunityTeamMember,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test When Opportunity Team member is inserted with role SDR,
     * then update the SDR Opportunity Owner as Opportunity Team member user
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSDROpportunityTeamMemberIsInsertedThenSetSDROpportunityOwner() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);

        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember opportunityTeamMemberRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .setField(OpportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.startTest();
        OpportunityTeamMembers.newInstance(
                new List<OpportunityTeamMember>{ opportunityTeamMemberRecord }
            )
            .updateSDROpportunityOwnerOnOpportunity(new Map<Id, OpportunityTeamMember>{});
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test When Opportunity Team member is inserted with role non SDR,
     * then dont update the SDR Opportunity Owner as Opportunity Team member user
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonSDROpportunityTeamMemberIsUpdatedThenDontSetSDROpportunityOwner() {
        Id currentUserId = UserInfo.getUserID();
        Id testAccountId1 = Fake.generateId(Account.class);
        Id testOpportunityTeamMemberId1 = Fake.generateId(OpportunityTeamMember.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .setChildren(
                'OpportunityTeamMembers',
                new List<Fake>{
                    new Fake(OpportunityTeamMember.class)
                        .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId1)
                        .setField(OpportunityTeamMember.OpportunityId, testOppId1)
                        .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
                        .setField(OpportunityTeamMember.UserId, currentUserId)
                }
            )
            .toSObject();

        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember opportunityTeamMemberRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent('User', new Fake(User.class).setField(User.Id, currentUserId))
            .toSObject();

        OpportunityTeamMember opportunityTeamMemberOldRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent('User', new Fake(User.class).setField(User.Id, currentUserId))
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(
                opportunitySelectorMock.selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(
                    new Set<Id>{ testOppId1 }
                )
            )
            .thenReturn(new List<Opportunity>{ opportunityRecord });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.startTest();
        OpportunityTeamMembers.newInstance(
                new List<OpportunityTeamMember>{ opportunityTeamMemberRecord }
            )
            .updateSDROpportunityOwnerOnOpportunity(
                new Map<Id, OpportunityTeamMember>{
                    testOpportunityTeamMemberId => opportunityTeamMemberOldRecord
                }
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(fflib_Match.anySObject());
    }
    /**
     * @description To test When Opportunity Team member is updated with SDR,
     * then dont update the SDR Opportunity Owner as Opportunity Team member user
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSDROpportunityTeamMemberIsUpdatedThenSetSDROpportunityOwner() {
        Id currentUserId = UserInfo.getUserID();
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember opportunityTeamMemberRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent(
                            'User',
                            new Fake(User.class)
                                .setField(User.Id, currentUserId)
                        )
            .toSObject();

        OpportunityTeamMember opportunityTeamMemberOldRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent(
                            'User',
                            new Fake(User.class)
                                .setField(User.Id, currentUserId)
                        )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.startTest();
        OpportunityTeamMembers.newInstance(new List<OpportunityTeamMember>{opportunityTeamMemberRecord})
            .updateSDROpportunityOwnerOnOpportunity(new Map<Id,OpportunityTeamMember>{testOpportunityTeamMemberId => opportunityTeamMemberOldRecord});
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(fflib_Match.anySObject());
    }
    /**
     * @description To test When Opportunity Team member is updated with non SDR,
     * then dont clear the SDR Opportunity Owner.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonSDROpportunityTeamMemberIsUpdatedThenClearSDROpportunityOwner() {
        Id currentUserId = UserInfo.getUserID();
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember opportunityTeamMemberRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent(
                            'User',
                            new Fake(User.class)
                                .setField(User.Id, currentUserId)
                        )
            .toSObject();

        OpportunityTeamMember opportunityTeamMemberOldRecord = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .setField(OpportunityTeamMember.UserId, currentUserId)
            .setParent(
                            'User',
                            new Fake(User.class)
                                .setField(User.Id, currentUserId)
                        )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(new Set<Id>{ testOppId1 }))
            .thenReturn(new List<Opportunity>{ opportunityRecord });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.startTest();
        OpportunityTeamMembers.newInstance(new List<OpportunityTeamMember>{opportunityTeamMemberRecord})
            .updateSDROpportunityOwnerOnOpportunity(new Map<Id,OpportunityTeamMember>{testOpportunityTeamMemberId => opportunityTeamMemberOldRecord});
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(fflib_Match.anySObject());
    }
}