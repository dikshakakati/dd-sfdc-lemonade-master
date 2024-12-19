/**
 * @author Deloitte
 * @date 28/11/2022
 * @description This is test class for CronTriggersSelector class.
 */
@isTest(seeAllData=false)
public class CronTriggersSelectorTest {
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        CronTriggersSelector cronInstance = new CronTriggersSelector();
        Schema.SObjectType typeOfObj = cronInstance.getSObjectType();
        System.assertEquals(
            Schema.CronTrigger.SObjectType,
            typeOfObj,
            'The object type must be CronTrigger'
        );

        List<Schema.SObjectField> fieldList = cronInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{ CronTrigger.Id },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenSelectByIdCalledThenReturnRecords() {
        Id cronJob1 = Fake.generateId(CronTrigger.getSObjectType());
        Id cronJob2 = Fake.generateId(CronTrigger.getSObjectType());

        List<CronTrigger> cronJobRecords = CronTriggersSelector.newInstance()
            .selectById(new Set<Id>{ cronJob1, cronJob2 });

        System.assert(cronJobRecords.isEmpty(), 'The list was not empty');
    }

    @isTest
    private static void testWhenSelectCronJobNameThenReturnCronRecords() {
        List<CronTrigger> cronJobRecords = CronTriggersSelector.newInstance()
            .selectCronTriggerJobByName('MockClass');

        System.assert(cronJobRecords.isEmpty(), 'The list was not empty');
    }
}