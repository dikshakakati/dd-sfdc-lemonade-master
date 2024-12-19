/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Test class for PermissionSetAssignmentsSelector class.
 */
@isTest(SeeAllData=false)
private class PermissionSetAssignmentsSelectorTest {
    private static final String PERMISSIONSET_STRATEGYANDOPERATIONS = 'Strategy_and_Operations';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Schema.SObjectType typeOfObject = PermissionSetAssignmentsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> permissionSetAssignmentFieldsMock = new List<Schema.SObjectField>{
            PermissionSetAssignment.Id,
            PermissionSetAssignment.AssigneeId,
            PermissionSetAssignment.PermissionSetId,
            PermissionSetAssignment.PermissionSetGroupId
        };

        List<Schema.SObjectField> sObjectFields = PermissionSetAssignmentsSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            PermissionSetAssignment.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be PermissionSetAssignment'
        );
        System.assertEquals(
            permissionSetAssignmentFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description This method is used for getting permission set assignment records when assignee id is passed.
     */
    @isTest
    private static void testWhenSelectByAssigneeIdThenReturnPermissionSetAssignments() {
        User userWithPermissionSet = TestDataFactory.createUser(true);
        PermissionSet customPermisionSet = new PermissionSet(
            Name = 'Doordash_Test_PS',
            Label = 'Doordash_Test_PS'
        );
        insert customPermisionSet;

        PermissionSetGroup customPermisionSetGroup = new PermissionSetGroup(
            DeveloperName = 'Doordash_Test_PG',
            MasterLabel = 'Doordash_Test_PG'
        );
        insert customPermisionSetGroup;

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(
                AssigneeId = userWithPermissionSet.Id,
                PermissionSetId = customPermisionSet.Id
            ),
            new PermissionSetAssignment(
                AssigneeId = userWithPermissionSet.Id,
                PermissionSetGroupId = customPermisionSetGroup.Id
            )
        };
        insert permissionSetAssignments;
        Set<Id> assigneeIds = new Set<Id>{ userWithPermissionSet.Id };
        List<PermissionSetAssignment> permissionSetAssignmentsReturned = PermissionSetAssignmentsSelector.newInstance()
            .selectByAssigneeIds(assigneeIds);

        List<PermissionSetAssignment> strategyAndOperationsAssignments = PermissionSetAssignmentsSelector.newInstance()
            .selectByStrategyandOperationsAndAssigneeIds(assigneeIds);

        List<PermissionSetAssignment> setsByNamesAndAssignees = PermissionSetAssignmentsSelector.newInstance()
            .selectByPermissionSetNameAndAssigneeId(
                new Set<String>{ 'Doordash_Test_PS' },
                assigneeIds
            );

        List<PermissionSetAssignment> groupsByNames = PermissionSetAssignmentsSelector.newInstance()
            .selectByPermissionSetGroupName('Doordash_Test_PG');

        List<PermissionSetAssignment> groupsByNamesAndAssignees = PermissionSetAssignmentsSelector.newInstance()
            .selectByPermissionSetGroupNameAndAssigneeId('Doordash_Test_PG', assigneeIds);

        List<PermissionSetAssignment> expectedStrategyAndOperationsAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE
                PermissionSet.Name = :PERMISSIONSET_STRATEGYANDOPERATIONS
                AND AssigneeId IN :assigneeIds
        ];

        System.assertEquals(
            permissionSetAssignmentsReturned[0].Id,
            permissionSetAssignments[0].Id,
            'Mismatch in PermissionSetAssignment'
        );
        System.assertEquals(
            permissionSetAssignmentsReturned[1].Id,
            permissionSetAssignments[1].Id,
            'Mismatch in PermissionSetAssignment'
        );
        System.assertEquals(
            permissionSetAssignmentsReturned.size(),
            2,
            'Mismatch in PermissionSetAssignment size'
        );
        System.assertEquals(
            expectedStrategyAndOperationsAssignments.size(),
            strategyAndOperationsAssignments.size(),
            'Mismatch in PermissionSetAssignment size'
        );
        System.assertEquals(1, setsByNamesAndAssignees.size(), 'Incorrect number of PSAs returned');
        System.assertEquals(
            1,
            groupsByNames.size(),
            'Incorrect number of PSAs returned when querying by Name'
        );
        System.assertEquals(
            1,
            groupsByNamesAndAssignees.size(),
            'Incorrect number of Group PSAs returned'
        );
    }
}