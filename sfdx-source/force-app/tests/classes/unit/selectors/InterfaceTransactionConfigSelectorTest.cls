/**
 * @author Deloitte
 * @date 04/25/2024
 * @description This is test class for InterfaceTransactionConfigSelector class
 */
@isTest
public class InterfaceTransactionConfigSelectorTest {
    private static final String ASSERT_MESSAGE_FIELD_LIST = 'Unexpected Error: Mismatch in field list';
    private static final String ASSERT_MESSAGE_METADATA_RECORDS_NOT_RETRIEVED = 'Unexpected Error: Records not retrieved';
    private static final String ASSERT_MESSAGE_METADATA_TYPE = 'Unexpected Error: The object type must be Interface Transaction Configuration Metadata';
    private static final String TABLET_INTEGRATION = 'Tablet_Integration';

    /**
     * @description To test Metadata instance is returned with expected details
     * when developer name is received.
     */
    @isTest
    private static void testWhenDeveloperNameSendThenMetadataInstanceReturned() {
        List<Interface_Transaction_Configuration__mdt> interfaceTransactionConfiguration = new List<Interface_Transaction_Configuration__mdt>{
            new Interface_Transaction_Configuration__mdt(
                DeveloperName = TABLET_INTEGRATION,
                Label = TABLET_INTEGRATION,
                Interface_Transaction_Name__c = TABLET_INTEGRATION
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Interface_Transaction_Configuration__mdt.DeveloperName,
            Interface_Transaction_Configuration__mdt.Enable_Logging__c,
            Interface_Transaction_Configuration__mdt.Enable_Retry__c,
            Interface_Transaction_Configuration__mdt.Interface_Transaction_Name__c,
            Interface_Transaction_Configuration__mdt.Is_Active__c,
            Interface_Transaction_Configuration__mdt.Label,
            Interface_Transaction_Configuration__mdt.Retry_Limit__c,
            Interface_Transaction_Configuration__mdt.Service_Class_Name__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        InterfaceTransactionConfigSelector mockInterfaceTransactionConfig = (InterfaceTransactionConfigSelector) mocks.mock(
            InterfaceTransactionConfigSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionConfig.getSObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(mockInterfaceTransactionConfig.getInstanceValue(TABLET_INTEGRATION))
            .thenReturn(interfaceTransactionConfiguration);
        mocks.when(mockInterfaceTransactionConfig.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfig);
        Schema.SObjectType typeOfObject = InterfaceTransactionConfigSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = new InterfaceTransactionConfigSelector()
            .getSObjectFieldList();
        InterfaceTransactionConfigSelector.newInstance().getInstanceValue(TABLET_INTEGRATION);
        InterfaceTransactionConfigSelector.newInstance()
            .selectByInterfaceTransactionNames(new Set<String>{ TABLET_INTEGRATION });
        System.assertEquals(
            Interface_Transaction_Configuration__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_METADATA_TYPE
        );
        System.assertEquals(sObjectFieldsMock, sObjectFields, ASSERT_MESSAGE_FIELD_LIST);
    }

    /**
     * @description To test SObject type and field lists are retrieved as expected
     * when class instantiates.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        InterfaceTransactionConfigSelector interfaceTransactionSelectorInstance = new InterfaceTransactionConfigSelector();

        Schema.SObjectType typeOfObj = interfaceTransactionSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = interfaceTransactionSelectorInstance.getSObjectFieldList();

        InterfaceTransactionConfigSelector.newInstance();

        System.assertEquals(
            Schema.Interface_Transaction_Configuration__mdt.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_METADATA_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Interface_Transaction_Configuration__mdt.DeveloperName,
                Interface_Transaction_Configuration__mdt.Enable_Logging__c,
                Interface_Transaction_Configuration__mdt.Enable_Retry__c,
                Interface_Transaction_Configuration__mdt.Interface_Transaction_Name__c,
                Interface_Transaction_Configuration__mdt.Is_Active__c,
                Interface_Transaction_Configuration__mdt.Label,
                Interface_Transaction_Configuration__mdt.Retry_Limit__c,
                Interface_Transaction_Configuration__mdt.Service_Class_Name__c
            },
            fieldList,
            ASSERT_MESSAGE_FIELD_LIST
        );
    }

    /**
     * @description To test all active Metadata record are retrieved.
     */
    @isTest
    private static void testWhenSelectAllActiveInterfaceTransactionCongisCalledThenReturnAllActiveMetadataDetails() {
        List<Interface_Transaction_Configuration__mdt> interfaceTransactionConfiguration = new List<Interface_Transaction_Configuration__mdt>{
            new Interface_Transaction_Configuration__mdt(
                DeveloperName = TABLET_INTEGRATION,
                Label = TABLET_INTEGRATION,
                Interface_Transaction_Name__c = TABLET_INTEGRATION
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        InterfaceTransactionConfigSelector mockInterfaceTransactionConfig = (InterfaceTransactionConfigSelector) mocks.mock(
            InterfaceTransactionConfigSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionConfig.getSObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(mockInterfaceTransactionConfig.selectAllActiveInterfaceTransactionCongis())
            .thenReturn(interfaceTransactionConfiguration);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfig);
        List<Interface_Transaction_Configuration__mdt> queryResult = InterfaceTransactionConfigSelector.newInstance()
            .selectAllActiveInterfaceTransactionCongis();
        System.assertEquals(
            true,
            queryResult.size() > 0,
            ASSERT_MESSAGE_METADATA_RECORDS_NOT_RETRIEVED
        );
    }
}