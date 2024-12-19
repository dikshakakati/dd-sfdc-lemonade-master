/**
 * @author Deloitte
 * @date 07/04/2024
 * @description Service class for onboarding details related logic.
 */
public inherited sharing class OnboardingDetailsService {
    /**
     * @description It collects the related onboarding details based on the passed Store Ids.
     * @JIRA# LEM-16642
     * @param storeIds
     * @return Map<String, String>
     */
    public static Map<String, String> collectOnboardingDetailsBasedOnStoreIds(
        Set<String> storeIds
    ) {
        return service().collectOnboardingDetailsBasedOnStoreIds(storeIds);
    }

    /**
     * @description It creates and returns instance of IOnboardingDetailsService
     * to call methods from OnboardingDetailsServiceImpl.
     * @JIRA# LEM-16642
     * @return IOnboardingDetailsService
     */
    private static IOnboardingDetailsService service() {
        return (IOnboardingDetailsService) Application.SERVICE.newInstance(
            IOnboardingDetailsService.class
        );
    }
}