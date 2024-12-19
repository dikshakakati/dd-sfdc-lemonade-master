/**
 * @author DoorDash
 * @date 09/28/2023
 * @description Test class for ApplicationBindingsSelector class
 */
@isTest(seeAllData=false)
public class ApplicationBindingsSelectorTest {
    private static final String DEVELOPER_NAME = 'Domain_Account';
    private static final String MASTER_LABEL = 'Domain Account';
    private static final String APPLICATION_TYPE = 'Domain';
    private static final String BINDING_OBJECT = 'Account';
	private static final String BINDING_OBJECT_API_NAME = 'Account';
    private static final String IMPLEMENTATION_TYPE = 'Accounts.Constructor';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Application Binding .';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_DEVELOPER_NAME = 'Unexpected result: There is a mismatch in developer name.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_APPLICATION_TYPE = 'Unexpected result: There is a mismatch in application type.';
	private static final String ASSERT_MESSAGE_MISMATCH_IN_BINDING_OBJECT = 'Unexpected result: There is a mismatch in binding object.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_ALL_EVENT_DATA = 'Unexpected result: There is a mismatch in all events data size.';
	/**
     * @description To test application binding custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            ApplicationBinding__mdt.Id,
            ApplicationBinding__mdt.MasterLabel,
            ApplicationBinding__mdt.DeveloperName,
            ApplicationBinding__mdt.ApplicationType__c,
            ApplicationBinding__mdt.BindingObject__c,
            ApplicationBinding__mdt.BindingObjectApiName__c,
            ApplicationBinding__mdt.BindingType__c,
            ApplicationBinding__mdt.ImplementationType__c
        };

        Schema.SObjectType typeOfObject = ApplicationBindingsSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = ApplicationBindingsSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            ApplicationBinding__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Notifier Events Binding Metadata'
        );

        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
    /**
     * @description To test application binding metadata get sobject type query when method called.
     */
    @isTest
    private static void testWhenGetSobjectTypeMethodCalledThenCorrespondingObjectTypeReturned() {
        Schema.SObjectType typeOfObject = ApplicationBindingsSelector.newInstance().SObjectType();
        System.assertEquals(
            ApplicationBinding__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }
    /**
     * @description To test application binding metadata query when instance developer name is passed.
     */
    @isTest
    private static void testWhenGetInstanceValueCalledThenCorrespondingCustomMetadataRecordReturned() {
        ApplicationBinding__mdt applicationBindingRecord = ApplicationBindingsSelector.newInstance()
            .getInstance(DEVELOPER_NAME);
        System.assertEquals(
            applicationBindingRecord.ApplicationType__c,
            APPLICATION_TYPE,
            ASSERT_MESSAGE_MISMATCH_IN_APPLICATION_TYPE
        );
        System.assertEquals(
            applicationBindingRecord.DeveloperName,
            DEVELOPER_NAME,
            ASSERT_MESSAGE_MISMATCH_IN_DEVELOPER_NAME
        );
    }
     /**
     * @description To test get all values from application binding metadata.
     */
    @isTest
    private static void testWhenGetAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Map<String, ApplicationBinding__mdt> applicationBindingRecords = ApplicationBindingsSelector.newInstance()
            .getAll();
        System.assertEquals(
            applicationBindingRecords.get(DEVELOPER_NAME).BindingObject__c,
            BINDING_OBJECT,
            ASSERT_MESSAGE_MISMATCH_IN_BINDING_OBJECT
        );
        List<ApplicationBinding__mdt> allEventsData = ApplicationBindingsSelector.newInstance()
            .getAllValues();
        System.assertEquals(
            ApplicationBinding__mdt.getAll().size(),
            allEventsData.size(),
            ASSERT_MESSAGE_MISMATCH_IN_ALL_EVENT_DATA
        );
    }
}