/**
 * @author Deloitte
 * @date 07/04/2024
 * @description Interface of service class for Onboarding details related logic.
 */
public interface IOnboardingDetailsService {
    /**
     * @description It collects the related onboarding details based on the passed Store Ids.
     * @param storeIds
     * @return Map<String, String>
     */
    Map<String, String> collectOnboardingDetailsBasedOnStoreIds(Set<String> storeIds);
}