/**
 * @author Deloitte
 * @date 10/10/2024
 * @description This is the test class for ApproversSelector class.
 */
@isTest(SeeAllData=false)
private class ApproversSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Approvers.';
    private static final String LIST_SIZE_ERROR_MESSAGE = 'Lists size does not match.';

    /**
     * @description It is used to test the constructor of ApproversSelector class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ApproversSelector approvers = new ApproversSelector();
        Schema.SObjectType typeOfObj = approvers.getSObjectType();
        List<Schema.SObjectField> fieldList = approvers.getSObjectFieldList();
        Test.startTest();
        ApproversSelector.newInstance();
        Test.stopTest();
        System.assertEquals(
            Schema.sbaa__Approver__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ sbaa__Approver__c.Id, sbaa__Approver__c.sbaa__User__c },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description It is used  to check whether Approvers are returned by the passed user ids.
     */
    @isTest
    private static void testWhenUserIdsPassedThenApproversReturned() {
        User redliningUser = TestDataFactory.createUser(true);
        sbaa__Approver__c redliningApprover = new sbaa__Approver__c(
            sbaa__User__c = redliningUser.Id
        );
        insert redliningApprover;
        Test.startTest();
        List<sbaa__Approver__c> approvers = new ApproversSelector()
            .selectByUserIds(new Set<Id>{ redliningUser.Id });
        Test.stopTest();
        System.assertEquals(1, approvers.size(), LIST_SIZE_ERROR_MESSAGE);
    }

    /**
     * @description It is used to check that Approvers are not returned when the passed user ids are
     * not associated with any Approvers.
     */
    @isTest
    private static void testWhenNonAssociatedUserIdsPassedThenNoApproversReturned() {
        User redliningUser = TestDataFactory.createUser(true);
        User nonRedliningUser = TestDataFactory.createUser(true);
        sbaa__Approver__c redliningApprover = new sbaa__Approver__c(
            sbaa__User__c = redliningUser.Id
        );
        insert redliningApprover;
        Test.startTest();
        List<sbaa__Approver__c> approvers = new ApproversSelector()
            .selectByUserIds(new Set<Id>{ nonRedliningUser.Id });
        Test.stopTest();
        System.assertEquals(0, approvers.size(), LIST_SIZE_ERROR_MESSAGE);
    }
}