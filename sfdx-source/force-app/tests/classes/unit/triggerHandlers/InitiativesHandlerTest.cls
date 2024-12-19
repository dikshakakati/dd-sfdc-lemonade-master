/**
 * @description Handler Test Class for Initiatives
 * @date 28/04/2022
 * @author Deloitte
 */
@isTest
private class InitiativesHandlerTest {
    private static final String COMPLETE_STATUS = 'Complete';
    private static final String IN_PROGRESS_STATUS = 'In Progress';

    @isTest
    private static void testWhenInitiativeIsInsertedThenTriggerIsCalled() {
        //ARRANGE
        Account parentAccount = new Account(Name = 'Test Account Initiative Parent',Segment__c ='SMB');
        insert parentAccount;

        List<Initiative__c> initiativeRecords = new List<Initiative__c>{
            new Initiative__c(
                Name = 'Test Product 1',
                Account__c = parentAccount.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = 'In Progress',
                Type__c = 'Business Review',
                Response__c = 'Mx Receptive - Implementation required'
            ),
            new Initiative__c(
                Name = 'Test Product 2',
                Account__c = parentAccount.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = 'In Progress',
                Type__c = 'Business Review',
                Response__c = 'Mx Receptive - Implementation required'
            )
        };
        insert initiativeRecords;

        System.assertNotEquals(null, initiativeRecords[0].Id, 'The Record Id is null');
    }

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     *              calls to Domain methods and no updates are directly performed using the
     *              handler method.
     *              The suppress warning used helps bypass the PMD Rule error for mandatory
     *              assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInitiativesTriggerIsFiredThenPopulateUltimateParentIsCalled() {
        //ARRANGE
        Account parentAccount1 = new Account(
            Id = Fake.generateId(Account.class),
            Ultimate_Parent_Account__c = null,
            Segment__c ='SMB'
        );
        Account parentAccount2 = new Account(
            Id = Fake.generateId(Account.class),
            Ultimate_Parent_Account__c = null,
            Segment__c ='SMB'
        );
        Id initiative1 = Fake.generateId(Initiative__c.class);
        Id initiative2 = Fake.generateId(Initiative__c.class);
        Initiative__c[] oldInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount1.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = IN_PROGRESS_STATUS,
                Type__c = 'Business Review',
                Ultimate_Parent_Account__c = parentAccount1.Id,
                Response__c = 'Mx Receptive - Implementation required'
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount1.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = 'In Progress',
                Type__c = 'Business Review',
                Ultimate_Parent_Account__c = parentAccount1.Id,
                Response__c = 'Mx Receptive - Implementation required'
            )
        };
        Initiative__c[] newInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount2.Id,
                Status__c = IN_PROGRESS_STATUS,
                Ultimate_Parent_Account__c = parentAccount1.Id
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount2.Id,
                Status__c = IN_PROGRESS_STATUS,
                Ultimate_Parent_Account__c = parentAccount1.Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Initiatives initiativesMocks = (Initiatives) mocks.mock(Initiatives.class);
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        mocks.startStubbing();
        mocks.when(initiativesMocks.getType()).thenReturn(Schema.Initiative__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(initiativesMocks);
        mocks.stopStubbing();

        Initiatives.setConstructorMock(constructor);
        //ACT
        fflib_SObjectDomain.Test.Database.onUpdate(
            newInitiatives,
            new Map<Id, SObject>(oldInitiatives)
        );
        fflib_SObjectDomain.triggerHandler(InitiativesHandler.class);

        //ASSERT
        ((IInitiatives) mocks.verify(initiativesMocks, 1)).populateUltimateParentAccount();

        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Initiative__c>(newInitiatives));
    }

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     *              calls to Domain methods and no updates are directly performed using the
     *              handler method.
     *              The suppress warning used helps bypass the PMD Rule error for mandatory
     *              assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInitiativesAreInsertedThenApplyDefaultsIsCalled() {
        //ARRANGE
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = new Account(Id = parentAccountId,Segment__c ='SMB');
        Id initiative1 = Fake.generateId(Initiative__c.class);
        Id initiative2 = Fake.generateId(Initiative__c.class);
        Initiative__c[] allInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = 'In Progress',
                Type__c = 'Business Review',
                Response__c = 'Mx Receptive - Implementation required'
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount.Id,
                Start_Date__c = Date.today() + 1,
                Status__c = 'In Progress',
                Type__c = 'Business Review',
                Response__c = 'Mx Receptive - Implementation required'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Initiatives initiativesMocks = (Initiatives) mocks.mock(Initiatives.class);
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );

        mocks.startStubbing();
        mocks.when(initiativesMocks.getType()).thenReturn(Schema.Initiative__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(initiativesMocks);
        mocks.stopStubbing();

        Initiatives.setConstructorMock(constructor);

        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            'Unexpected result: Record are present in database'
        );

        //ACT
        fflib_SObjectDomain.Test.Database.onInsert(allInitiatives);
        fflib_SObjectDomain.triggerHandler(InitiativesHandler.class);

        //ASSERT
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            'Unexpected result: Record are not present in database'
        );
        ((IInitiatives) mocks.verify(initiativesMocks, 1)).populateUltimateParentAccount();
        ((fflib_IDomainConstructor) mocks.verify(constructor, 2))
            .construct(new List<Initiative__c>(allInitiatives));
    }

    /**
     * @description It is used to test if Task Creation is initiated when Mx Touch point
     * status is updated to Complete.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMxTouchPointStatusUpdatedToCompletedThenCreateTaskOnMxTouchPointCalled() {
        //ARRANGE
        Account parentAccount1 = new Account(
            Id = Fake.generateId(Account.class),
            Ultimate_Parent_Account__c = null,
            Segment__c ='SMB'
        );
        Id initiative1 = Fake.generateId(Initiative__c.class);
        Id initiative2 = Fake.generateId(Initiative__c.class);
        Initiative__c[] oldInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false,
                Status__c = IN_PROGRESS_STATUS
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false
            )
        };
        Initiative__c[] newInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false,
                Status__c = COMPLETE_STATUS
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false,
                Status__c = COMPLETE_STATUS
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Initiatives initiativesMocks = (Initiatives) mocks.mock(Initiatives.class);
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        mocks.startStubbing();
        mocks.when(initiativesMocks.getType()).thenReturn(Schema.Initiative__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(initiativesMocks);
        mocks.stopStubbing();
        Initiatives.setConstructorMock(constructor);
        //ACT
        fflib_SObjectDomain.Test.Database.onUpdate(
            newInitiatives,
            new Map<Id, SObject>(oldInitiatives)
        );
        fflib_SObjectDomain.triggerHandler(InitiativesHandler.class);
        //ASSERT
        ((IInitiatives) mocks.verify(initiativesMocks, 1)).createTaskOnCompleteMxTouchpoints();
    }

    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor call
        List<Initiative__c> initiativeList = new List<Initiative__c>();
        InitiativesHandler initiativeHandlerObject = new InitiativesHandler(initiativeList);

        //Inner Class Constructor Call
        InitiativesHandler.Constructor objConstructor = new InitiativesHandler.Constructor();
        objConstructor.construct(initiativeList);
        System.assertNotEquals(
            initiativeHandlerObject,
            objConstructor.construct(initiativeList),
            'The two constructs should not be similar'
        );
    }
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenIsParentAccountMergedFieldChangedThenPopulateUltimateParentIsCalled() {
        //ARRANGE
        Account parentAccount1 = new Account(
            Id = Fake.generateId(Account.class),
            Ultimate_Parent_Account__c = null,
            Segment__c ='SMB'
        );
        Id initiative1 = Fake.generateId(Initiative__c.class);
        Id initiative2 = Fake.generateId(Initiative__c.class);
        Initiative__c[] oldInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false,
                Status__c = IN_PROGRESS_STATUS
            ),
            new Initiative__c(
                Id = initiative2,
                Account__c = parentAccount1.Id,
                Is_Parent_Account_Merged__c = false
            )
        };
        Initiative__c[] newInitiatives = new List<Initiative__c>{
            new Initiative__c(
                Id = initiative1,
                Is_Parent_Account_Merged__c = true,
                Status__c = COMPLETE_STATUS
            ),
            new Initiative__c(Id = initiative2, Is_Parent_Account_Merged__c = true)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Initiatives initiativesMocks = (Initiatives) mocks.mock(Initiatives.class);
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );

        mocks.startStubbing();
        mocks.when(initiativesMocks.getType()).thenReturn(Schema.Initiative__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(initiativesMocks);
        mocks.stopStubbing();

        Initiatives.setConstructorMock(constructor);

        //ACT
        fflib_SObjectDomain.Test.Database.onUpdate(
            newInitiatives,
            new Map<Id, SObject>(oldInitiatives)
        );
        fflib_SObjectDomain.triggerHandler(InitiativesHandler.class);

        //ASSERT
        ((IInitiatives) mocks.verify(initiativesMocks, 1)).populateUltimateParentAccount();
        //Added assert to check whether new method is called on update
        ((IInitiatives) mocks.verify(initiativesMocks, 1))
            .addErrorOnCompleteMxTouchpointsWithoutStakeholders();
        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Initiative__c>(newInitiatives));
    }
}