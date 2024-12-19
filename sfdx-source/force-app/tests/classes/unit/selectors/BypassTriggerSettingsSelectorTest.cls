/**
 * @author Deloitte
 * @date 01/03/2022
 * @description Test class for BypassTriggerSettingsSelector class.
 */
@isTest(SeeAllData=false)
private class BypassTriggerSettingsSelectorTest {
    /**
     * @description To test BypassTriggerSettings' selector methods.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Account_Admin_Bypass',
                DeveloperName = 'Account_Admin_Bypass',
                Object_Name__c = 'Account',
                Permission_Type__c = 'Profile',
                Permission_Name__c = 'System Administrator',
                Before_Insert__c = true,
                After_Insert__c = true
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Bypass_Trigger_Setting__mdt.Object_Name__c,
            Bypass_Trigger_Setting__mdt.Before_Insert__c,
            Bypass_Trigger_Setting__mdt.Before_Delete__c,
            Bypass_Trigger_Setting__mdt.Before_Update__c,
            Bypass_Trigger_Setting__mdt.After_Insert__c,
            Bypass_Trigger_Setting__mdt.After_Delete__c,
            Bypass_Trigger_Setting__mdt.After_Update__c,
            Bypass_Trigger_Setting__mdt.After_Undelete__c,
            Bypass_Trigger_Setting__mdt.Permission_Name__c,
            Bypass_Trigger_Setting__mdt.Permission_Type__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBypassTriggerSettings.getSObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockBypassTriggerSettings.getSObjectFieldList()).thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        BypassTriggerSettingsSelector selectorInstance = new BypassTriggerSettingsSelector();
        Schema.SObjectType typeOfObject = selectorInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = selectorInstance.getSObjectFieldList();
        List<Bypass_Trigger_Setting__mdt> allBypassTriggerSettings = BypassTriggerSettingsSelector.newInstance()
            .getAllValues();
        System.assertEquals(
            Bypass_Trigger_Setting__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Bypass Trigger Setting Metadata'
        );
        System.assertEquals(
            Bypass_Trigger_Setting__mdt.getAll().values(),
            allBypassTriggerSettings,
            'Unexpected Error: Mismatch in list of Bypass Trigger Settings Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
}