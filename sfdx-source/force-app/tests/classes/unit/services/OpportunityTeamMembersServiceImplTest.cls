/**
 * @author Deloitte
 * @date 14/04/2023
 * @description Test class for OpportunityTeamMembersServiceImpl class.
 */
@isTest
public class OpportunityTeamMembersServiceImplTest {
    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsCreatedThenOpportunityTeamMemberIsCreated() {
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id normalUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id userManager = fflib_IDGenerator.generate(User.SObjectType);
        Id userSuperManager = fflib_IDGenerator.generate(User.SObjectType);
        Fake superManagerFakeInstance = new Fake(User.class)
            .setField(User.Id, userSuperManager)
            .setField(User.Email, 'test3@gmail.com');
        Fake managerInstance = new Fake(User.class)
            .setField(User.Id, userManager)
            .setField(User.Email, 'test2@gmail.com')
            .setField(User.ManagerId, userSuperManager)
            .setParent('Manager', superManagerFakeInstance);
        Fake normalUserFakeInstance = new Fake(User.class)
            .setField(User.Id, normalUserId)
            .setField(User.Email, 'test1@gmail.com')
            .setField(User.ManagerId, userManager)
            .setParent('Manager', managerInstance);
        User normalUser = (User) normalUserFakeInstance.toSObject();
        Opportunity newOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.OwnerId, normalUserId)
            .toSObject();

        List<Opportunity> opportunityList = new List<Opportunity>{ newOpportunity };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IUsersSelector mockUsersSelector = (IUsersSelector) mocks.mock(IUsersSelector.class);
        mocks.startStubbing();
        mocks.when(mockUsersSelector.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(mockUsersSelector.selectUsersById(new Set<Id>{ normalUserId }))
            .thenReturn(new List<User>{ normalUser });
        mocks.stopStubbing();
        Application.Selector.setMock(mockUsersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunityTeamMembersService.createOpportunityTeamMembersForManagers(opportunityList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OpportunityTeamMember.OpportunityId => opportunityRecordId,
                        OpportunityTeamMember.UserId => userManager,
                        OpportunityTeamMember.TeamMemberRole => 'Pod Manager'
                    }
                )
            );
    }

    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     */
    @isTest
    private static void testWhenOpportunityIsCreatedThenOpportunityTeamMemberFailed() {
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id normalUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id userManager = fflib_IDGenerator.generate(User.SObjectType);
        Id userSuperManager = fflib_IDGenerator.generate(User.SObjectType);
        Fake superManagerFakeInstance = new Fake(User.class)
            .setField(User.Id, userSuperManager)
            .setField(User.Email, 'test3@gmail.com');
        Fake managerInstance = new Fake(User.class)
            .setField(User.Id, userManager)
            .setField(User.Email, 'test2@gmail.com')
            .setField(User.ManagerId, userSuperManager)
            .setParent('Manager', superManagerFakeInstance);
        Fake normalUserFakeInstance = new Fake(User.class)
            .setField(User.Id, normalUserId)
            .setField(User.Email, 'test1@gmail.com')
            .setField(User.ManagerId, userManager)
            .setParent('Manager', managerInstance);
        User normalUser = (User) normalUserFakeInstance.toSObject();
        Opportunity newOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.OwnerId, normalUserId)
            .toSObject();

        List<Opportunity> opportunityList = new List<Opportunity>{ newOpportunity };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IUsersSelector mockUsersSelector = (IUsersSelector) mocks.mock(IUsersSelector.class);
        mocks.startStubbing();
        mocks.when(mockUsersSelector.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(mockUsersSelector.selectUsersById(new Set<Id>{ normalUserId }))
            .thenReturn(new List<User>{ normalUser });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.Selector.setMock(mockUsersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            OpportunityTeamMembersService.createOpportunityTeamMembersForManagers(opportunityList);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }
}