/**
 * @author Deloitte
 * @date 2/03/2022
 * @description This is test class for InterfaceSelector class
 */
@isTest(seeAllData=false)
public class InterfaceSelectorTest {
    @testSetup
    static void setup() {
        List<Interface__c> interfaceList = new List<Interface__c>{
            new Interface__c(Class_Interface_Name__c = 'Test 1', Enable_Retry__c = true),
            new Interface__c(Class_Interface_Name__c = 'Test 2', Enable_Retry__c = false),
            new Interface__c(Class_Interface_Name__c = 'Test 3', Enable_Retry__c = false)
        };
        insert interfaceList;
    }

    @isTest
    private static void testWhenInterfaceInsertThenCallSelectById() {
        Test.startTest();
        List<Interface__c> insertedRecord = [
            SELECT Id, Name, Class_Interface_Name__c
            FROM Interface__c
            WHERE Class_Interface_Name__c = 'Test 2'
        ];
        List<Interface__c> interfaces = InterfaceSelector.newInstance()
            .selectById(new Set<Id>{ insertedRecord[0].Id });
        Test.stopTest();
        System.assertEquals(1, interfaces.size(), 'Return Record Count Mismatch');
        system.assertEquals(insertedRecord[0].Id, interfaces[0].Id, 'Return Record Mismatch');
    }

    @isTest
    private static void testWhenInterfaceInsertThenCallCSelectByClassName() {
        Test.startTest();
        List<Interface__c> interfaces = InterfaceSelector.newInstance()
            .selectByClassName(new List<String>{ 'Test 1' });
        Test.stopTest();
        System.assertEquals(1, interfaces.size(), 'Return Record Count Mismatch');
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        InterfaceSelector interfaceInstance = new InterfaceSelector();
        Schema.SObjectType typeOfObj = interfaceInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = interfaceInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Interface__c.SObjectType,
            typeOfObj,
            'The object type must be Interface__c'
        );
        System.assertEquals(5, fieldList.size(), 'Total field count is not matching');
    }
}