/**
 * @author Deloitte
 * @date 04/14/2022
 * @description Test class for NotifierEventBindingsSelector class
 */
@isTest(seeAllData=false)
public class NotifierEventBindingsSelectorTest {
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER = 'UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER';

    /**
     * @description To test Notifier event binding custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Notifier_Event_Binding__mdt.Topic__c,
            Notifier_Event_Binding__mdt.Class_Name__c,
            Notifier_Event_Binding__mdt.Scope_Size__c
        };

        Schema.SObjectType typeOfObject = NotifierEventBindingsSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = NotifierEventBindingsSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Notifier_Event_Binding__mdt.SObjectType,
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
     * @description To test get all values from notifier event metadata.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'AccountsService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        NotifierEventBindingsSelector selectorMock = (NotifierEventBindingsSelector) mocks.mock(
            NotifierEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        List<Notifier_Event_Binding__mdt> allEventsData = NotifierEventBindingsSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Notifier_Event_Binding__mdt.getAll().values(),
            allEventsData,
            'Unexpected Error: Mismatch in list of Notifier Event Binding Metadata'
        );
    }
}