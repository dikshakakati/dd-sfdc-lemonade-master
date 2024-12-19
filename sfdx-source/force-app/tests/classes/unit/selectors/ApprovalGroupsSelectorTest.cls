/**
 * @author Deloitte
 * @date 04/20/2024
 * @description This is test class for ApprovalGroupSelector class
 */
@isTest
private class ApprovalGroupsSelectorTest {
    private static final String DEVELOPER_NAME = 'AUS_NZL_Pre_Sales';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_ALL_APPROVAL_DATA = 'Unexpected result: There is a mismatch in approval groups data size.';

    /**
     * @description It is used to check whether the fields returned from the selector are expected
     * or not.
     */
    @isTest
    static void testWhenSObjectFieldsQueriedThenExpectedMetadataFieldsReturned() {
        List<Schema.SObjectField> expectedApprovalGroupFields = new List<Schema.SObjectField>{
            Approval_Group__mdt.Id,
            Approval_Group__mdt.DeveloperName
        };
        List<Schema.SObjectField> actualApprovalGroupFields = ApprovalGroupsSelector.newInstance()
            .getSObjectFieldList();
        System.assertEquals(
            expectedApprovalGroupFields,
            actualApprovalGroupFields,
            ASSERT_MESSAGE_MISMATCH_IN_ALL_APPROVAL_DATA
        );
    }

    /**
     * @description It is used to check whether the approval groups metadata records are retrieved
     * when the method is called.
     */
    @isTest
    private static void testWhenClassInstantiatedThenApprovalGroupsRetrieved() {
        Schema.SObjectType typeOfObject = ApprovalGroupsSelector.newInstance().SObjectType();
        List<Approval_Group__mdt> approvalGroups = ApprovalGroupsSelector.newInstance().selectApprovalGroups();
        System.assertEquals(
            true,
            approvalGroups.size() > 0,
            ASSERT_MESSAGE_MISMATCH_IN_ALL_APPROVAL_DATA
        );
        System.assertEquals(
            Approval_Group__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_ALL_APPROVAL_DATA
        );
    }
}