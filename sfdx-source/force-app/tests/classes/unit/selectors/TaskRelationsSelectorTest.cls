/**
 * @author Deloitte
 * @date 30/04/2024
 * @description This is test class for TaskRelationselector class
 */
@isTest(seeAllData=false)
public class TaskRelationsSelectorTest {
    /**
     * @description This test method to query related TaskRelation of Task.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPassingTaskIdsThenGettingTaskRelations() {
		Lead objLead = new Lead( LastName = 'Test', Company = 'Example', Email = 'abc@abc.com',Phone = '1234567890' );        
        insert objLead;               
        
        List<Task> tasks = New List<Task>();
        tasks.add(new Task(SUBJECT = 'Call' , STATUS = 'Completed'));     
        insert tasks; 
        Set<Id> taskIds = New Set<Id>();
        taskIds.add(tasks[0].Id);
        
        TaskRelation taskRelationWithLead = new TaskRelation(); 
        taskRelationWithLead.taskId = tasks[0].Id; 
        taskRelationWithLead.relationId = objLead.Id; 
        insert taskRelationWithLead;
        
        TaskRelationsSelector taskRelationsInstance = new TaskRelationsSelector();
        List<TaskRelation> taskIdTaskRelations = taskRelationsInstance.selectByTaskIds(
            taskIds
        );
        System.assertEquals(1, taskIdTaskRelations.size(), 'The list size will match');
        
	}
}
