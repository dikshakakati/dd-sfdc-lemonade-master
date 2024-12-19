@isTest(SeeAllData=false)
private class BypassLogicModelImplTest {
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String CONTACT_OBJECT = 'Contact';
    private static final String PROFILE_PERMISSION_TYPE = 'Profile';
    private static final String PROFILE_NAME = 'System Administrator';

    @isTest
    private static void testWhenTriggerIsBypassedUsingProfileThenReturnTrue() {
        Profile profileName = new Profile(Id = UserInfo.getProfileId(), Name = PROFILE_NAME);
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Account_Admin_Bypass',
                DeveloperName = 'Account_Admin_Bypass',
                Object_Name__c = ACCOUNT_OBJECT,
                Permission_Type__c = PROFILE_PERMISSION_TYPE,
                Permission_Name__c = PROFILE_NAME,
                Before_Insert__c = true,
                After_Insert__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        ProfilesSelector mockProfileSelector = (ProfilesSelector) mocks.mock(
            ProfilesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProfileSelector.sObjectType()).thenReturn(Profile.SObjectType);
        mocks.when(mockProfileSelector.selectByID(new Set<Id>{ UserInfo.getProfileId() }))
            .thenReturn(new List<Profile>{ profileName });
        mocks.when(mockBypassTriggerSettings.sObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockProfileSelector);
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        Test.startTest();
        Boolean isBeforeInsertBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.BEFORE_INSERT
        );
        Boolean isAfterInsertBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.AFTER_INSERT
        );
        Test.stopTest();
        System.assertEquals(
            true,
            isBeforeInsertBypassed,
            'Unexpected Error: Before Insert trigger not bypassed'
        );
        System.assertEquals(
            true,
            isAfterInsertBypassed,
            'Unexpected Error: After Insert trigger not bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
    }

    @isTest
    private static void testWhenTriggerIsBypassedUsingApexClassThenReturnTrue() {
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Account_AccountsHandler_Bypass',
                DeveloperName = 'Account_AccountsHandler_Bypass',
                Object_Name__c = ACCOUNT_OBJECT,
                Permission_Type__c = 'Apex Class',
                Permission_Name__c = 'AccountsHandler',
                Before_Update__c = true,
                After_Update__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBypassTriggerSettings.sObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        Test.startTest();
        BypassLogicModel.setParentCallingClassName('AccountsHandler');
        Boolean isBeforeUpdateBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.BEFORE_UPDATE
        );
        Boolean isAfterUpdateBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.AFTER_UPDATE
        );
        Test.stopTest();
        System.assertEquals(
            true,
            isBeforeUpdateBypassed,
            'Unexpected Error: Before Update trigger not bypassed'
        );
        System.assertEquals(
            true,
            isAfterUpdateBypassed,
            'Unexpected Error: After Update trigger not bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );

        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
    }

    @isTest
    private static void testWhenMetadataHasMultipleRecordsWithBypassUsingProfileThenReturnAsPerMetadataRecordValue() {
        Profile profileName = new Profile(Id = UserInfo.getProfileId(), Name = PROFILE_NAME);
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Account_Admin_Bypass',
                DeveloperName = 'Account_Admin_Bypass',
                Object_Name__c = ACCOUNT_OBJECT,
                Permission_Type__c = PROFILE_PERMISSION_TYPE,
                Permission_Name__c = PROFILE_NAME,
                Before_Delete__c = true,
                After_Delete__c = true
            ),
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Contact_Admin_Bypass',
                DeveloperName = 'Contact_Admin_Bypass',
                Object_Name__c = CONTACT_OBJECT,
                Permission_Type__c = PROFILE_PERMISSION_TYPE,
                Permission_Name__c = PROFILE_NAME,
                Before_Delete__c = false,
                After_Delete__c = true,
                Before_Insert__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        ProfilesSelector mockProfileSelector = (ProfilesSelector) mocks.mock(
            ProfilesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProfileSelector.sObjectType()).thenReturn(Profile.SObjectType);
        mocks.when(mockProfileSelector.selectByID(new Set<Id>{ UserInfo.getProfileId() }))
            .thenReturn(new List<Profile>{ profileName });
        mocks.when(mockBypassTriggerSettings.sObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockProfileSelector);
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        Boolean isAccountBeforeDeleteBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.BEFORE_DELETE
        );
        Boolean isAccountAfterDeleteBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.AFTER_DELETE
        );
        Boolean isContactBeforeDeleteBypassed = BypassLogicModel.isTriggerBypassed(
            CONTACT_OBJECT,
            System.TriggerOperation.BEFORE_DELETE
        );
        Boolean isContactAfterDeleteBypassed = BypassLogicModel.isTriggerBypassed(
            CONTACT_OBJECT,
            System.TriggerOperation.AFTER_DELETE
        );
        Boolean isContactBeforeInsertBypassed = BypassLogicModel.isTriggerBypassed(
            CONTACT_OBJECT,
            System.TriggerOperation.BEFORE_INSERT
        );
        System.assertEquals(
            true,
            isAccountBeforeDeleteBypassed,
            'Unexpected Error: Account Before Delete trigger not bypassed'
        );
        System.assertEquals(
            false,
            isContactBeforeDeleteBypassed,
            'Unexpected Error: Contact Before Delete trigger bypassed'
        );
        System.assertEquals(
            true,
            isAccountAfterDeleteBypassed,
            'Unexpected Error: Account After Delete trigger not bypassed'
        );
        System.assertEquals(
            true,
            isContactAfterDeleteBypassed,
            'Unexpected Error: Contact After Delete trigger not bypassed'
        );
        System.assertEquals(
            true,
            isContactBeforeInsertBypassed,
            'Unexpected Error: Contact Before Insert trigger not bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
    }

    @isTest
    private static void testWhenTriggerIsNotBypassedWithNoMetadataRecordsThenReturnFalse() {
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt()
        };
        //Create an instance of fflib_ApexMocks class part of apex mock framework.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBypassTriggerSettings.sObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
    }

    @isTest
    private static void testWhenTriggerIsBypassedUsingCustomPermissionThenReturnTrue() {
        String customPermissionName = 'Bypass_Trigger';
        List<Bypass_Trigger_Setting__mdt> customMetadataMocks = new List<Bypass_Trigger_Setting__mdt>{
            new Bypass_Trigger_Setting__mdt(
                MasterLabel = 'Account_CustomPermission_Bypass',
                DeveloperName = 'Account_CustomPermission_Bypass',
                Object_Name__c = ACCOUNT_OBJECT,
                Permission_Type__c = 'Custom Permission',
                Permission_Name__c = 'Bypass_Trigger',
                After_Undelete__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassTriggerSettingsSelector mockBypassTriggerSettings = (BypassTriggerSettingsSelector) mocks.mock(
            BypassTriggerSettingsSelector.class
        );
        FeatureManagementService mockFeatureManagementService = (FeatureManagementService) mocks.mock(
            FeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(mockBypassTriggerSettings.sObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(mockBypassTriggerSettings.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockFeatureManagementService.checkPermission(customPermissionName))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockBypassTriggerSettings);
        Boolean isAfterUndeleteBypassed = BypassLogicModel.isTriggerBypassed(
            ACCOUNT_OBJECT,
            System.TriggerOperation.AFTER_UNDELETE
        );
        System.assertEquals(
            true,
            isAfterUndeleteBypassed,
            'Unexpected Error: After Undelete trigger not bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                ACCOUNT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );

        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_INSERT
            ),
            'Unexpected Error: Before Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_INSERT
            ),
            'Unexpected Error: After Insert trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_UPDATE
            ),
            'Unexpected Error: Before Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UPDATE
            ),
            'Unexpected Error: After Update trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.BEFORE_DELETE
            ),
            'Unexpected Error: Before Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_DELETE
            ),
            'Unexpected Error: After Delete trigger unexpectedly bypassed'
        );
        System.assertEquals(
            false,
            BypassLogicModel.isTriggerBypassed(
                CONTACT_OBJECT,
                System.TriggerOperation.AFTER_UNDELETE
            ),
            'Unexpected Error: After Undelete trigger unexpectedly bypassed'
        );
    }
}