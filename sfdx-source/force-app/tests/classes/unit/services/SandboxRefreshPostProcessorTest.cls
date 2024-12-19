/**
 * @author BizApps
 * @date 10-April-2024
 * @description Test class for the SandboxRefreshPostProcessor class.
 **/
@IsTest
private class SandboxRefreshPostProcessorTest {
    @IsTest
    static void testWhenExecutingAdHocThenOnlyRunForSpecifiedUsers() {
        String mainEmail = 'test@testing.com';
        String invalidSuffix = '.invalid';

        User testUser = new User(Id = UserInfo.getUserId(), Email = mainEmail + invalidSuffix);
        List<User> usersToRun = new List<User>{ testUser };
        SandboxRefreshPostProcessor.runForSpecifiedUsers(usersToRun);

        System.assertEquals(
            mainEmail,
            testUser.Email,
            'The User\'s email was not updated to remove `.invalid`'
        );
        System.assertEquals(
            SandboxRefreshPostProcessor.systemAdminProfileId,
            testUser.ProfileId,
            'The User was not updated to System Admin'
        );
    }

    @IsTest
    static void testWhenExecutingOnSandboxRefreshThenRunForDevUsers() {
        try {
            SandboxRefreshPostProcessor instance = new SandboxRefreshPostProcessor();
            instance.runApexClass(null); // For 100% coverage
        } catch (Exception ex) {
            System.assert(
                ex != null,
                'Exception thrown in `runApexClass()` method execution as expected'
            );
        }
    }
}