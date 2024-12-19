/**
 * @author Deloitte
 * @date 2/03/2022
 * @description This is test class for InterfaceTransactionSelector class
 */
@isTest(seeAllData=false)
public class InterfaceTransactionSelectorTest {
    private static final String ASSERT_MESSAGE_RETURN_FIELD_LIST_MISMATCH = 'Field List Mismatch';
    private static final String ASSERT_MESSAGE_RETURN_OBJECT_TYPE_MISMATCH = 'The object type must be Interface_Transaction__c';
    private static final String ASSERT_MESSAGE_RETURN_RECORD_MISMATCH = 'Return Record Mismatch';
    private static final String CLASS_INTERFACE_NAME_MOCK = 'InterfaceTransactionSelectorTest';
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String INTEGRATION_TEMPLATE_NAME = 'Opportunity_Closed_Won';
    private static final String SOBJECT_TYPE_OPPORTUNITY = 'Opportunity';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD = 'Mx_Fraud_Document_Integration';
    private static final Set<String> INTERFACE_TRANSACTION_CONFIG_NAMES_TO_SKIP_RETRY = new Set<String>{
        INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
    };

    @testSetup
    static void setup() {
        List<Interface__c> interfaceList = new List<Interface__c>{
            new Interface__c(
                Class_Interface_Name__c = CLASS_INTERFACE_NAME_MOCK,
                Enable_Retry__c = true
            )
        };
        insert interfaceList;
        List<Interface_Transaction__c> interfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Status__c = STATUS_FAILURE,
                Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                Remaining_Retry_Attempts__c = 3,
                Interface__c = interfaceList[0].id
            ),
            new Interface_Transaction__c(
                Status__c = STATUS_FAILURE,
                Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                Remaining_Retry_Attempts__c = 0,
                Interface__c = interfaceList[0].id
            ),
            new Interface_Transaction__c(
                Status__c = STATUS_SUCCESS,
                Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                Remaining_Retry_Attempts__c = 3,
                Interface__c = interfaceList[0].id
            ),
            new Interface_Transaction__c(
                Status__c = STATUS_SUCCESS,
                Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                Remaining_Retry_Attempts__c = 0,
                Interface__c = interfaceList[0].id
            )
        };
        insert interfaceTransaction;
    }

    @isTest
    private static void testWhenInterfaceTransactionInsertThenCallselectById() {
        Test.startTest();
        List<Interface_Transaction__c> insertedRecord = [
            SELECT Id, Name
            FROM Interface_Transaction__c
            WHERE Remaining_Retry_Attempts__c = 0 AND Status__c = :STATUS_FAILURE
        ];
        List<Interface_Transaction__c> interfaceTransactions = InterfaceTransactionSelector.newInstance()
            .selectById(new Set<Id>{ insertedRecord[0].Id });
        Test.stopTest();
        System.assertEquals(
            interfaceTransactions[0].Id,
            insertedRecord[0].Id,
            ASSERT_MESSAGE_RETURN_RECORD_MISMATCH
        );
    }
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        InterfaceTransactionSelector interfaceInstance = new InterfaceTransactionSelector();
        Schema.SObjectType typeOfObj = interfaceInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = interfaceInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Interface_Transaction__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_RETURN_OBJECT_TYPE_MISMATCH
        );
        System.assertEquals(9, fieldList.size(), ASSERT_MESSAGE_RETURN_FIELD_LIST_MISMATCH);
    }
    @isTest
    private static void testWhenInterfaceTransactionInsertThenCallSelectByInterface() {
        Test.startTest();
        List<Interface__c> insertedRecord = [SELECT Id, Name FROM Interface__c];
        List<Interface_Transaction__c> interfaceTransactions = InterfaceTransactionSelector.newInstance()
            .selectByInterface(String.valueOf(insertedRecord[0].id));

        Test.stopTest();
        System.assertEquals(4, interfaceTransactions.size(), ASSERT_MESSAGE_RETURN_RECORD_MISMATCH);
        System.assertEquals(
            STATUS_FAILURE,
            interfaceTransactions[0].Status__c,
            ASSERT_MESSAGE_RETURN_RECORD_MISMATCH
        );
    }

    /**
     * @description To test SObject type and field lists are retrieved as expected
     * when class instantiates.
     */
    @isTest
    private static void testWhenCallqueryLocatorThenReturnInterfaceTransactionsForRetry() {
        Integration_Template__c newIntegrationTemplate = new Integration_Template__c(
            Immediate_Communication__c = false,
            Is_Active__c = true,
            Name = INTEGRATION_TEMPLATE_NAME,
            SObject_Type__c = SOBJECT_TYPE_OPPORTUNITY
        );
        insert newIntegrationTemplate;
        Interface_Transaction__c newInterfaceTransaction = new Interface_Transaction__c(
            Integration_Template__c = newIntegrationTemplate.Id,
            Interface_Transaction_Configuration_Name__c = EMAIL_OUTBOUND_CONFIG_NAME,
            Remaining_Retry_Attempts__c = 2,
            Status__c = STATUS_NEW
        );
        insert newInterfaceTransaction;
        Database.QueryLocator queryData = InterfaceTransactionSelector.newInstance()
            .queryLocatorReadyToRetry();
        List<Interface_Transaction__c> interfaceTransaction = Database.query(queryData.getQuery());
        System.assertEquals(1, interfaceTransaction.size(), ASSERT_MESSAGE_RETURN_RECORD_MISMATCH);
    }
}