/**
 * @author BizApps
 * @date 9-April-2024
 * @description Class to get executed when a sandbox refresh is provisioned to set up user profiles and system data.
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class SandboxRefreshPostProcessor implements SandboxPostCopy {
    private static final String SYSTEM_ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String SSO_ENABLED_PS_NAME = 'Enable_SSO';
    private static final String DEV_ADMIN_PSG_NAME = 'Developer_Admin';
    private static final String SFDC_ADMIN_TITLE = 'Salesforce Administrator';
    private static final String SFDC_DEV_TITLE = 'Salesforce Developer';

    private static fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
    private static Boolean skipDml = false; // Bypasses DML in certain test scenarios

    @TestVisible
    private static Id systemAdminProfileId {
        get {
            if (systemAdminProfileId == null) {
                List<Profile> profiles = ProfilesSelector.newInstance()
                    .selectByNames(new Set<String>{ SYSTEM_ADMIN_PROFILE_NAME });
                systemAdminProfileId = (!profiles.isEmpty()) ? profiles[0].Id : null;
            }
            return systemAdminProfileId;
        }
        set;
    }

    // NOTE (25 APRIL 2024):
    // The below is a bit of a crude workaround when it comes to retrieving Users from the "BizApps" org.
    // The reason we need this is, as of now, we do not have a reliable way to denote who is part of the
    // BizApps team. While a distinct Profile is coming in the near future -- and once that's developed, this
    // code should modified to use that as query criterion -- the best and safest way right now to find
    // these users is to use a combination of `Developer_Admin` PSG Assignment OR a job title of "Salesforce
    // Administrator" or "Salesforce Developer". Certain users, like contractors, may not have the job
    // title, and certain users, like BizApps users who were not added to the PSG, may not have Developer_Admin
    // assignment, but doing an either/or check here is the closest thing we have to retrieving everyone.
    private static Set<Id> salesforceTeamIds {
        get {
            if (salesforceTeamIds == null) {
                salesforceTeamIds = new Set<Id>();
                // Retrieve users by `Developer_Admin` Permission Set Group
                for (
                    PermissionSetAssignment psgAssignment : PermissionSetAssignmentsSelector.newInstance()
                        .selectByPermissionSetGroupName(DEV_ADMIN_PSG_NAME)
                ) {
                    salesforceTeamIds.add(psgAssignment.AssigneeId);
                }
                // Look for Users with the right job titles -- this will help anyone who slipped through the
                // cracks in the above PSG query.
                for (
                    User user : UsersSelector.newInstance()
                        .selectActiveUsersByJobTitleFuzzyMatch(
                            new Set<String>{ SFDC_ADMIN_TITLE, SFDC_DEV_TITLE }
                        )
                ) {
                    salesforceTeamIds.add(user.Id);
                }
            }

            // The combination of users from both queries should be our BizApps team and contractors
            return salesforceTeamIds;
        }
        set;
    }

    private static List<User> salesforceTeam {
        get {
            if (salesforceTeam == null) {
                salesforceTeam = UsersSelector.newInstance().selectUsersById(salesforceTeamIds);
            }
            return salesforceTeam;
        }
        set;
    }

    /**
     * @description Method implemented by the SandboxPostCopy interface to be executed whenever a SFDC sandbox is refreshed
     * @param context
     **/
    global void runApexClass(SandboxContext context) {
        skipDml = Test.isRunningTest();
        runRefreshLogic(salesforceTeam);
    }

    /**
     * @description Gets everyone on the Development Team (SFDC Admins & Devs) and changes their profiles to System Administrator
     * @param sandboxUsersToUpdate
     **/
    public static void updateDevTeamUserProfiles(List<User> sandboxUsersToUpdate) {
        for (User thisSalesforceTeamMember : sandboxUsersToUpdate) {
            thisSalesforceTeamMember.ProfileId = systemAdminProfileId;
            thisSalesforceTeamMember.Email = thisSalesforceTeamMember.Email.removeEndIgnoreCase(
                '.invalid'
            );
            unitOfWorkInstance.registerDirty(thisSalesforceTeamMember);
        }
    }

    /**
     * @description Deletes all references to the SSO Enabled permission set for Admin/Dev users
     * @param sandboxUsersToUpdate
     **/
    public static void deleteSSOEnabledPermissionSetAssignmentsFromUsers(
        List<User> sandboxUsersToUpdate
    ) {
        Set<Id> sandboxUserIds = new Map<Id, User>(sandboxUsersToUpdate).keySet();
        List<PermissionSetAssignment> ssoEnabledPermissionSetAssignments = PermissionSetAssignmentsSelector.newInstance()
            .selectByPermissionSetNameAndAssigneeId(
                new Set<String>{ SSO_ENABLED_PS_NAME },
                sandboxUserIds
            );

        // Delete all the "SSO Enabled" PermissionSetAssignment records for every BizApps user
        unitOfWorkInstance.registerDeleted(ssoEnabledPermissionSetAssignments);
    }

    /**
     * @description Deletes all references to the Developer_Admin Permission Set Group for Admin/Dev users
     * @param sandboxUsersToUpdate
     **/
    public static void deleteDeveloperAdminPSGAssignmentsFromUsers(
        List<User> sandboxUsersToUpdate
    ) {
        // Query for PermissionSetGroupAssignment records that match the Permission Set Group and user IDs
        List<PermissionSetAssignment> psgAssignments = PermissionSetAssignmentsSelector.newInstance()
            .selectByPermissionSetGroupNameAndAssigneeId(
                DEV_ADMIN_PSG_NAME,
                new Map<Id, User>(sandboxUsersToUpdate).keySet()
            );

        // Delete the assignments
        unitOfWorkInstance.registerDeleted(psgAssignments);
    }

    /**
     * @description This method allows the class to be invoked for a specific list of users, rather than run for all
     * @param usersToUpdate
     **/
    public static void runForSpecifiedUsers(List<User> usersToUpdate) {
        runRefreshLogic(usersToUpdate);
    }

    /**
     * @description Initialization logic for the resetting users process
     * @param usersToUpdate
     **/
    private static void runRefreshLogic(List<User> usersToUpdate) {
        updateDevTeamUserProfiles(usersToUpdate);
        deleteSSOEnabledPermissionSetAssignmentsFromUsers(usersToUpdate);
        deleteDeveloperAdminPSGAssignmentsFromUsers(usersToUpdate);

        if (!skipDml) {
            unitOfWorkInstance.commitWork();
        }

        // TODO - Add future method to insert configuration data
    }
}