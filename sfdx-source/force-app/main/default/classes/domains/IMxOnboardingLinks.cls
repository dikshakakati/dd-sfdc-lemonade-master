/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Interface to add domain class methods.
 */
public interface IMxOnboardingLinks extends fflib_ISObjects {
    /**
     * @description It evaluates initaiates the creation of Work Order when Onboarding Input
     * is Submitted.
     * @JIRA# LEM-15321
     */
    void initiateWorkOrderCreation();

    /**
     * @description The method initiates the Store Account Association for New Quotes when Record Creation
     * Status of Mx Onboarding Link is changed as Success.
     * @JIRA #LEM-15219
     */
    void initiateStoreAgreementCreationAsync();

    /**
     * @description The method initiates the Store Account Association for New Quotes when Record Creation
     * Status of Mx Onboarding Link is changed as Success.
     * @JIRA #LEM-15219
     * @param mxOnboardingLinkIds
     */
    void initiateStoreAgreementCreation(Set<Id> mxOnboardingLinkIds);
}