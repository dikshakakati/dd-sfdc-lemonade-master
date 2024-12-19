/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Test class for Guided flow controller.
 */
@isTest(seeAllData=false)
public class UserPermissionSetFlowControllerTest {
    private static final String PERMISSION_QUERY = 'SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id= :userId LIMIT 1'; 
    private static final String SPLIT_KEY = '~';
    private static final String ASSERT_FAILURE_MESSAGE = 'Query should return permission details';
    /**
     * @description It is used to test User permission for the selected Query
     * are received.
     */
	@isTest
    private static void testWhenUserPermissionQueryReceivedThenGetThePermissionResult() {
        List<List<sObject>> permissionSetResult=new List<List<sObject>>();
        List<String> userPermission = new List<String>{
            PERMISSION_QUERY+SPLIT_KEY+UserInfo.getUserId()
        };
    	Test.startTest();
        	permissionSetResult = UserPermissionSetFlowController.getPermissionDetails(userPermission);
        Test.stopTest();
        System.assertEquals(false, permissionSetResult.isEmpty(),ASSERT_FAILURE_MESSAGE);
    }
}