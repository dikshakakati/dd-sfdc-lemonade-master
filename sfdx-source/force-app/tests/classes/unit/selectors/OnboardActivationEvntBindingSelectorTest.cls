/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Test class for OnboardingActivationEventBindingsSelector class
 */
@isTest(seeAllData=false)
public class OnboardActivationEvntBindingSelectorTest {
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST';

    /**
     * @description To test Onboarding Activation event binding custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Onboarding_Events_Binding__mdt.Topic__c,
            Onboarding_Events_Binding__mdt.Class_Name__c,
            Onboarding_Events_Binding__mdt.Scope_Size__c
        };

        Schema.SObjectType typeOfObject = OnboardingActivationEventBindingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = OnboardingActivationEventBindingSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Onboarding_Events_Binding__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Onboarding Activation Events Binding Metadata'
        );

        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description To test get all values from Onboarding Activation event metadata.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Onboarding_Events_Binding__mdt[] bindings = new List<Onboarding_Events_Binding__mdt>{
            new Onboarding_Events_Binding__mdt(
                Class_Name__c = 'ActivationChecklistService',
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OnboardingActivationEventBindingSelector selectorMock = (OnboardingActivationEventBindingSelector) mocks.mock(
            OnboardingActivationEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        List<Onboarding_Events_Binding__mdt> allEventsData = OnboardingActivationEventBindingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Onboarding_Events_Binding__mdt.getAll().values(),
            allEventsData,
            'Unexpected Error: Mismatch in list of Onboarding Activation Event Binding Metadata'
        );
    }
}