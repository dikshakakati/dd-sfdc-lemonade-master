/**
* @description This is test class for OrderProtocolMappingsSelector class
* added new field Order_Protocol_Mapping__mdt to the class & test class
*/
@isTest
public with sharing class OrderProtocolMappingsSelectorTest {

    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
	private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be OrderProtocolMapping custom metadata';
    private static final String ASSERT_MESSAGE_COUNT_NOT_MATCHING = 'assert count not matching';

/**
* @description This method used to test OrderProtocolMappingsSelector class
*/
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Order_Protocol_Mapping__mdt.MasterLabel,
                    Order_Protocol_Mapping__mdt.DeveloperName,
                    Order_Protocol_Mapping__mdt.Contains__c,
                    Order_Protocol_Mapping__mdt.Old_Value__c,
                    Order_Protocol_Mapping__mdt.Result__c,
                    Order_Protocol_Mapping__mdt.Active__c,
                	Order_Protocol_Mapping__mdt.Ignore_Values__c
        };

        OrderProtocolMappingsSelector orderProtocolMappingsSelectorInstance = new OrderProtocolMappingsSelector();
        Schema.SObjectType typeOfObject = orderProtocolMappingsSelectorInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = orderProtocolMappingsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Order_Protocol_Mapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

     /**
     * @description To test Order Protocol Mapping selector standard methods.
     */
    @isTest
    private static void testWhenGetActiveOrderProtocolInstanseThenReturnMetatdata() {
        List<Order_Protocol_Mapping__mdt> settingList = getOrderProtocolMapping();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
        fflib_ISObjectUnitOfWork.class
        );
        IOrderProtocolMappingsSelector metaDataMappingSelector =
        (IOrderProtocolMappingsSelector) mocks.mock(OrderProtocolMappingsSelector.class);

        mocks.startStubbing();
        mocks.when(metaDataMappingSelector.SObjectType()).thenReturn(Order_Protocol_Mapping__mdt.SObjectType);
        mocks.when(metaDataMappingSelector.getActiveOrderProtocolMappings()).thenReturn(settingList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(metaDataMappingSelector);
        Application.UnitOfWork.setMock(mockUow);

        List<Order_Protocol_Mapping__mdt> settingResult = OrderProtocolMappingsSelector.newInstance().getActiveOrderProtocolMappings();
            System.assertEquals(1,settingResult.size(),ASSERT_MESSAGE_COUNT_NOT_MATCHING);
    }

    private static List<Order_Protocol_Mapping__mdt> getOrderProtocolMapping(){
        return new List<Order_Protocol_Mapping__mdt>{
            new Order_Protocol_Mapping__mdt(
                MasterLabel = 'Order Protocol Mapping',
                Active__c = true
            )
        };
    }

     @isTest
    private static void testWhenGetActiveOrderProtocolMappingThenReturnMetatdata() {
        OrderProtocolMappingsSelector selector = new OrderProtocolMappingsSelector();
        List<Order_Protocol_Mapping__mdt> orderProtocolMapping = selector.getActiveOrderProtocolMappings();
        Assert.isTrue(!orderProtocolMapping.isEmpty(), 'Order Protocol mappings are not returned as expected');
    }
}