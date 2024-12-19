/**
 * @author Deloitte
 * @date 04/28/2022
 * @description Test Class for Initiatives Domain class.
 */
@isTest
private class InitiativesTest {
    private static final String AGGREGATE_STAKEHOLDERS_COUNT_ALIAS = 'stakeholdersCount';
    private static final String AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS = 'mxTouchpointId';
    private static final String ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE = 'Unexpected result: mismatch in error message displayed for Mx Touchpoint.';
    private static final String DOMINOS_BUSINESS_ACCOUNT_NAME = 'Test Dominos Business';
    private static final String DOMINOS_MX_TOUCHPOINT_NAME = 'Dominos Touchpoint';
    private static final String KFC_BUSINESS_ACCOUNT_NAME = 'Test KFC Business';
    private static final String KFC_MX_TOUCHPOINT_NAME = 'KFC Touchpoint';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String TOUCHPOINT_NAME = 'Test Touchpoint';
    private static final String TOUCHPOINT_TYPE_BUSINESS_REVIEW = 'Business Review';

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        Account parentAccount = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType));
        Initiative__c[] initiativeList = new List<Initiative__c>{
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount.Id
            ),
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount.Id
            )
        };

        //IProductInsights Instance Creation Call
        Initiatives.newInstance(initiativeList);

        //Default Constructor Call
        Initiatives initiativeObject = new Initiatives(initiativeList);

        //fflib_IDomainConstructor Call
        Initiatives.Constructor constructorObject = new Initiatives.Constructor();

        constructorObject.construct(initiativeList);
        System.assertNotEquals(
            Initiatives.newInstance(initiativeList),
            initiativeObject,
            'These objects should not be similar'
        );
    }

    @isTest
    private static void testWhenInitiativeAccountHasAnUltimateParentThenItIsAddedAsInitiativeUltimateParent() {
        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id
        );

        Initiative__c[] initiativeList = new List<Initiative__c>{
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount.Id
            ),
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount.Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();

        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);

        IInitiatives initiativesDomain = Initiatives.newInstance(initiativeList);

        initiativesDomain.populateUltimateParentAccount();

        System.assertEquals(
            ultimateParentAccount.Id,
            initiativeList[0].Ultimate_Parent_Account__c,
            'The Ultimate Parent did not populate appropriately'
        );
    }

    @isTest
    private static void testWhenUltimateParentAccountIsNullThenParentAccountIsPopulated() {
        Account ultimateParentAccount1 = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );

        Account parentAccount1 = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount1.Id
        );

        Account parentAccount2 = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = null
        );

        Initiative__c[] initiativeList = new List<Initiative__c>{
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount1.Id
            ),
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Account__c = parentAccount2.Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();

        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectById(new Set<Id>{ parentAccount1.Id, parentAccount2.Id })
            )
            .thenReturn(new List<Account>{ parentAccount1, parentAccount2 });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);

        IInitiatives initiativesDomain = Initiatives.newInstance(initiativeList);

        initiativesDomain.populateUltimateParentAccount();
        System.assertEquals(
            ultimateParentAccount1.Id,
            initiativeList[0].Ultimate_Parent_Account__c,
            'The Ultimate Parent did not populate appropriately'
        );
        System.assertEquals(
            parentAccount2.Id,
            initiativeList[1].Ultimate_Parent_Account__c,
            'The Ultimate Parent did not populate appropriately'
        );
    }

    /**
     * @description It is used to test error added when Mx Touchpoints without associated
     * Stakeholders are marked as 'Complete'.
     */
    @isTest
    private static void testWhenMxTouchpointsWithoutStakeholdersCompletedThenThrowError() {
        Id kfcAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id kfcTouchpointId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        Account kfcAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, kfcAccountId)
            .setField(Account.Name, KFC_BUSINESS_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .toSObject();
        Initiative__c kfcMxTouchpoint = (Initiative__c) new Fake(Initiative__c.class)
            .setField(Initiative__c.Id, kfcTouchpointId)
            .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
            .setField(Initiative__c.Name, KFC_MX_TOUCHPOINT_NAME)
            .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
            .setField(Initiative__c.Account__c, kfcAccount.Id)
            .setField(Initiative__c.Status__c, STATUS_COMPLETE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStakeholdersSelector mockStakeholdersSelector = (IStakeholdersSelector) mocks.mock(
            IStakeholdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStakeholdersSelector.sObjectType()).thenReturn(Stakeholder__c.SObjectType);
        mocks.when(
                mockStakeholdersSelector.getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
                    new Set<Id>{ kfcMxTouchpoint.Id }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStakeholdersSelector);
        Test.startTest();
        Initiatives.newInstance(new List<Initiative__c>{ kfcMxTouchpoint })
            .addErrorOnCompleteMxTouchpointsWithoutStakeholders();
        Test.stopTest();
        System.assertEquals(
            System.Label.Error_On_Mx_Touchpoint_wo_Stakeholders,
            kfcMxTouchpoint.getErrors()[0].getMessage(),
            ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE
        );
    }

    /**
     * @description It is used to check when Mx Touchpoints with associated
     * Stakeholders are marked as 'Complete' then no error thrown.
     */
    @isTest
    private static void testWhenMxTouchpointsWithStakeholdersCompletedThenNoErrorThrown() {
        Id dominosAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id dominosTouchpointId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        Account dominosAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, dominosAccountId)
            .setField(Account.Name, DOMINOS_BUSINESS_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .toSObject();
        Initiative__c dominosMxTouchpoint = (Initiative__c) new Fake(Initiative__c.class)
            .setField(Initiative__c.Id, dominosTouchpointId)
            .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
            .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
            .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
            .setField(Initiative__c.Account__c, dominosAccount.Id)
            .setField(Initiative__c.Status__c, STATUS_COMPLETE)
            .toSObject();
        List<Aggregate> stakeholdersAggregateCountByMxTouchpoints = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS, dominosMxTouchpoint.Id)
                .put(AGGREGATE_STAKEHOLDERS_COUNT_ALIAS, 3)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStakeholdersSelector mockStakeholdersSelector = (IStakeholdersSelector) mocks.mock(
            IStakeholdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStakeholdersSelector.sObjectType()).thenReturn(Stakeholder__c.SObjectType);
        mocks.when(
                mockStakeholdersSelector.getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
                    new Set<Id>{ dominosMxTouchpoint.Id }
                )
            )
            .thenReturn(stakeholdersAggregateCountByMxTouchpoints);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStakeholdersSelector);
        Test.startTest();
        Initiatives.newInstance(new List<Initiative__c>{ dominosMxTouchpoint })
            .addErrorOnCompleteMxTouchpointsWithoutStakeholders();
        Test.stopTest();
        System.assertEquals(
            true,
            dominosMxTouchpoint.getErrors().isEmpty(),
            ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE
        );
    }

    /**
     * @description To test if a task is created when Mx Touchpoint is updated to Complete Status.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTouchpointsWithStakeholdersinCompleteStatusThenCreateTask() {
        Id dominosAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id dominosTouchpointId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        Id stakeHolderId1 = fflib_IDGenerator.generate(Stakeholder__c.SObjectType);
        Id stakeHolderId2 = fflib_IDGenerator.generate(Stakeholder__c.SObjectType);
        Id stakeHolderId3 = fflib_IDGenerator.generate(Stakeholder__c.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Account dominosAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, dominosAccountId)
            .setField(Account.Name, DOMINOS_BUSINESS_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .toSObject();
        Initiative__c dominosMxTouchpoint = (Initiative__c) new Fake(Initiative__c.class)
            .setField(Initiative__c.Id, dominosTouchpointId)
            .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
            .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
            .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
            .setField(Initiative__c.Account__c, dominosAccount.Id)
            .setField(Initiative__c.Account_Segment__c, SEGMENT_SMB)
            .setField(Initiative__c.Status__c, STATUS_COMPLETE)
            .setField(Initiative__c.OwnerId, ownerId)
            .toSObject();
        Stakeholder__c stakeHolder1 = (Stakeholder__c) new Fake(Stakeholder__c.class)
            .setField(Stakeholder__c.Id, stakeHolderId1)
            .setField(Stakeholder__c.Initiative__c, TOUCHPOINT_NAME)
            .setField(Stakeholder__c.Contact__c, contactId)
            .setParent(
                'Initiative__r',
                new Fake(Initiative__c.class)
                    .setField(Initiative__c.Id, dominosTouchpointId)
                    .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
                    .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
                    .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
                    .setField(Initiative__c.End_Date__c, System.today().addDays(10))
                    .setField(Initiative__c.Account__c, dominosAccount.Id)
                    .setField(Initiative__c.Account_Segment__c, SEGMENT_SMB)
                    .setField(Initiative__c.Status__c, STATUS_COMPLETE)
                    .setField(Initiative__c.Interaction_Type__c, 'In Person')
                    .setField(Initiative__c.OwnerId, fflib_IDGenerator.generate(User.SObjectType))
            )
            .toSObject();
        Stakeholder__c stakeHolder2 = (Stakeholder__c) new Fake(Stakeholder__c.class)
            .setField(Stakeholder__c.Id, stakeHolderId2)
            .setField(Stakeholder__c.Initiative__c, TOUCHPOINT_NAME)
            .setField(Stakeholder__c.Contact__c, contactId)
            .setParent(
                'Initiative__r',
                new Fake(Initiative__c.class)
                    .setField(Initiative__c.Id, dominosTouchpointId)
                    .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
                    .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
                    .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
                    .setField(Initiative__c.End_Date__c, System.today().addDays(10))
                    .setField(Initiative__c.Account__c, dominosAccount.Id)
                    .setField(Initiative__c.Account_Segment__c, SEGMENT_SMB)
                    .setField(Initiative__c.Status__c, STATUS_COMPLETE)
                    .setField(Initiative__c.Interaction_Type__c, 'In Person')
                    .setField(Initiative__c.OwnerId, fflib_IDGenerator.generate(User.SObjectType))
            )
            .toSObject();
        Stakeholder__c stakeHolder3 = (Stakeholder__c) new Fake(Stakeholder__c.class)
            .setField(Stakeholder__c.Id, stakeHolderId3)
            .setField(Stakeholder__c.Initiative__c, TOUCHPOINT_NAME)
            .setField(Stakeholder__c.User__c, userId)
            .setParent(
                'Initiative__r',
                new Fake(Initiative__c.class)
                    .setField(Initiative__c.Id, dominosTouchpointId)
                    .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
                    .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
                    .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
                    .setField(Initiative__c.End_Date__c, System.today().addDays(10))
                    .setField(Initiative__c.Account__c, dominosAccount.Id)
                    .setField(Initiative__c.Account_Segment__c, SEGMENT_SMB)
                    .setField(Initiative__c.Status__c, STATUS_COMPLETE)
                    .setField(Initiative__c.Interaction_Type__c, 'In Person')
                    .setField(Initiative__c.OwnerId, ownerId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStakeholdersSelector mockStakeholdersSelector = (IStakeholdersSelector) mocks.mock(
            IStakeholdersSelector.class
        );
        ITasks tasksMock = Tasks.newInstance(new List<Task>{});
        tasksMock.createTaskByPassedMxTouchpointAndStakeholder(dominosMxTouchpoint, stakeHolder2);
        mocks.startStubbing();
        mocks.when(mockStakeholdersSelector.sObjectType()).thenReturn(Stakeholder__c.SObjectType);
        mocks.when(
                mockStakeholdersSelector.getStakeholderContactsByMxTouchPointIds(
                    new Set<Id>{ dominosMxTouchpoint.Id }
                )
            )
            .thenReturn(new List<Stakeholder__c>{ stakeHolder1, stakeHolder2 });
        mocks.when(
                mockStakeholdersSelector.getStakeholderUsersByMxTouchPointIds(
                    new Set<Id>{ dominosMxTouchpoint.Id }
                )
            )
            .thenReturn(new List<Stakeholder__c>{ stakeHolder3 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStakeholdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.DOMAIN.setMock(tasksMock);
        Test.startTest();
        Initiatives.newInstance(new List<Initiative__c>{ dominosMxTouchpoint })
            .createTaskOnCompleteMxTouchpoints();
        Test.stopTest();
        ((ITasks) mocks.verify(tasksMock, 1))
            .createTaskByPassedMxTouchpointAndStakeholder(dominosMxTouchpoint, stakeHolder2);
        ((ITasks) mocks.verify(tasksMock, 1))
            .createTaskByPassedMxTouchpointAndStakeholder(dominosMxTouchpoint, stakeHolder3);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test whether error thrown in task creation when Mx Touchpoint
     * is updated to Completed Status and has no related Stakeholders.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTouchpointsWithoutStakeholdersCompletedThenErrorThrown() {
        Id dominosAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id dominosTouchpointId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        Account dominosAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, dominosAccountId)
            .setField(Account.Name, DOMINOS_BUSINESS_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .toSObject();
        Initiative__c dominosMxTouchpoint = (Initiative__c) new Fake(Initiative__c.class)
            .setField(Initiative__c.Id, dominosTouchpointId)
            .setField(Initiative__c.Type__c, TOUCHPOINT_TYPE_BUSINESS_REVIEW)
            .setField(Initiative__c.Name, DOMINOS_MX_TOUCHPOINT_NAME)
            .setField(Initiative__c.Start_Date__c, System.today().addDays(3))
            .setField(Initiative__c.Account__c, dominosAccount.Id)
            .setField(Initiative__c.Status__c, STATUS_COMPLETE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        IStakeholdersSelector mockStakeholdersSelector = (IStakeholdersSelector) mocks.mock(
            IStakeholdersSelector.class
        );
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(mockStakeholdersSelector.sObjectType()).thenReturn(Stakeholder__c.SObjectType);
        mocks.when(
                mockStakeholdersSelector.getStakeholderContactsByMxTouchPointIds(
                    new Set<Id>{ dominosMxTouchpoint.Id }
                )
            )
            .thenReturn(new List<Stakeholder__c>());
        mocks.when(
                mockStakeholdersSelector.getStakeholderUsersByMxTouchPointIds(
                    new Set<Id>{ dominosMxTouchpoint.Id }
                )
            )
            .thenReturn(new List<Stakeholder__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStakeholdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.DOMAIN.setMock(tasksMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        Test.startTest();
        Initiatives.newInstance(new List<Initiative__c>{ dominosMxTouchpoint })
            .createTaskOnCompleteMxTouchpoints();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Task.WhoId => dominosMxTouchpoint.Id }
                )
            );
    }
}