/**
 * @author Deloitte
 * @date 02/25/2022
 * @description Service implementation class to implement bypass logic using custom metadata.
 */
public without sharing class BypassLogicModelImpl implements IBypassLogicModel {
    private List<Bypass_Trigger_Setting__mdt> allBypassTriggerSettings;
    private String currentUserProfileName;
    private Map<String, Bypass_Trigger_Setting__mdt> customPermissionNameToBypassTriggerSettings;
    private List<Bypass_Trigger_Setting__mdt> matchingBypassTriggerSettings;
    private enum PermissionTypes {
        APEXCLASS,
        CUSTOMPERMISSION,
        PROFILE
    }
    private static String parentCallingClassName = '';
    private static final Map<String, PermissionTypes> PERMISSIONNAMETOPERMISSIONTYPES = new Map<String, PermissionTypes>{
        'Apex Class' => PermissionTypes.APEXCLASS,
        'Custom Permission' => PermissionTypes.CUSTOMPERMISSION,
        'Profile' => PermissionTypes.PROFILE
    };
    private static Map<Id, String> profileIdToName = new Map<Id, String>();

    /**
     * @description Static block to instantiate static variables.
     */
    static {
        getCurrentUserProfileName();
    }

    /**
     * @description Default constructor to instantiate variables.
     */
    public BypassLogicModelImpl() {
        BypassTriggerSettingsSelector selector = (BypassTriggerSettingsSelector) Application.SELECTOR.newInstance(
            Bypass_Trigger_Setting__mdt.SObjectType
        );
        this.allBypassTriggerSettings = selector.getAllValues();
        this.customPermissionNameToBypassTriggerSettings = new Map<String, Bypass_Trigger_Setting__mdt>();
        this.matchingBypassTriggerSettings = new List<Bypass_Trigger_Setting__mdt>();
        if (!profileIdToName.containsKey(UserInfo.getProfileId())) {
            getCurrentUserProfileName();
        }
        this.currentUserProfileName = profileIdToName.get(UserInfo.getProfileId());
    }

    /**
     * @description It checks whether trigger context is bypassed.
     * @param sObjectName
     * @param triggerContext
     * @return Boolean - returns true when trigger is bypassed, else returns false
     */
    public Boolean isTriggerBypassed(String sObjectName, System.TriggerOperation triggerContext) {
        Boolean isTriggerByPassed = false;
        this.customPermissionNameToBypassTriggerSettings.clear();
        this.matchingBypassTriggerSettings.clear();
        if (this.allBypassTriggerSettings.isEmpty()) {
            return isTriggerByPassed;
        }
        collectPermissionNames(sObjectName);
        getMatchingPermissionsBypassTriggerSetting();
        isTriggerByPassed = isTriggerContextBypassed(triggerContext);
        return isTriggerByPassed;
    }

    /**
     * @description It sets parentCallingClassName for further transactions.
     * @param className
     * @return String
     */
    public String setParentCallingClassName(String className) {
        if (String.isBlank(parentCallingClassName)) {
            parentCallingClassName = className;
        }
        return parentCallingClassName;
    }

    /**
     * @description It prepare map of Profiles/CustomPermission and related custom metadata records
     * associated with the object name.
     * Consideration: one custom metadata record per object per custom permission/profile.
     * @param sObjectName
     */
    private void collectPermissionNames(String sObjectName) {
        for (Bypass_Trigger_Setting__mdt eachBypassTriggerSetting : allBypassTriggerSettings) {
            if (eachBypassTriggerSetting.Object_Name__c != sObjectName) {
                continue;
            }
            switch on
                PERMISSIONNAMETOPERMISSIONTYPES.get(eachBypassTriggerSetting.Permission_Type__c) {
                when CUSTOMPERMISSION {
                    customPermissionNameToBypassTriggerSettings.put(
                        eachBypassTriggerSetting.Permission_Name__c,
                        eachBypassTriggerSetting
                    );
                }
                when PROFILE {
                    if (eachBypassTriggerSetting.Permission_Name__c != currentUserProfileName) {
                        continue;
                    }
                    matchingBypassTriggerSettings.add(eachBypassTriggerSetting);
                }
                when APEXCLASS {
                    if (
                        String.isBlank(parentCallingClassName) ||
                        eachBypassTriggerSetting.Permission_Name__c != parentCallingClassName
                    ) {
                        continue;
                    }
                    matchingBypassTriggerSettings.add(eachBypassTriggerSetting);
                }
            }
        }
    }

    /**
     * @description It collects current user's Profile details and stores it in the static map of
     * Profile Id to Profile Name.
     */
    private static void getCurrentUserProfileName() {
        for (
            Profile eachProfile : ProfilesSelector.newInstance()
                .selectByID(new Set<Id>{ UserInfo.getProfileId() })
        ) {
            profileIdToName.put(eachProfile.Id, eachProfile.Name);
        }
    }

    /**
     * @description It checks whether custom permissions collected from custom metadata records are
     * applicable for the current user.
     */
    private void getMatchingPermissionsBypassTriggerSetting() {
        if (customPermissionNameToBypassTriggerSettings.isEmpty()) {
            return;
        }
        for (String eachCustomPermission : customPermissionNameToBypassTriggerSettings.keySet()) {
            if (FeatureManagementService.newInstance().checkPermission(eachCustomPermission)) {
                matchingBypassTriggerSettings.add(
                    customPermissionNameToBypassTriggerSettings.get(eachCustomPermission)
                );
            }
        }
    }

    /**
     * @description It checks whether the passed trigger context is bypassed
     * through Bypass Trigger Settings applicable to the current user.
     * @param triggerContext
     * @return Boolean - returns true when trigger context is bypassed, else returns false
     */
    private Boolean isTriggerContextBypassed(System.TriggerOperation triggerContext) {
        Boolean isTriggerContextBypassed = false;
        if (matchingBypassTriggerSettings.isEmpty()) {
            return isTriggerContextBypassed;
        }
        for (Bypass_Trigger_Setting__mdt eachBypassTriggerSetting : matchingBypassTriggerSettings) {
            switch on triggerContext {
                when BEFORE_INSERT {
                    isTriggerContextBypassed = eachBypassTriggerSetting.Before_Insert__c;
                }
                when AFTER_INSERT {
                    isTriggerContextBypassed = eachBypassTriggerSetting.After_Insert__c;
                }
                when BEFORE_UPDATE {
                    isTriggerContextBypassed = eachBypassTriggerSetting.Before_Update__c;
                }
                when AFTER_UPDATE {
                    isTriggerContextBypassed = eachBypassTriggerSetting.After_Update__c;
                }
                when BEFORE_DELETE {
                    isTriggerContextBypassed = eachBypassTriggerSetting.Before_Delete__c;
                }
                when AFTER_DELETE {
                    isTriggerContextBypassed = eachBypassTriggerSetting.After_Delete__c;
                }
                when AFTER_UNDELETE {
                    isTriggerContextBypassed = eachBypassTriggerSetting.After_Undelete__c;
                }
            }
            if (isTriggerContextBypassed) {
                break;
            }
        }
        return isTriggerContextBypassed;
    }
}