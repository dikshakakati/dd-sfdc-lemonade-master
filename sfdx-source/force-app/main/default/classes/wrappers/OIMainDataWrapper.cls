/**
 * @author Deloitte
 * @date 06/07/2024
 * @description OIMainDataWrapper for OIUserForm lightning web component.
 */
public class OIMainDataWrapper {
    @AuraEnabled
    public Id businessAccountId;
    @AuraEnabled
    public List<OIFieldWrapper> businessInfoWrappers;
    @AuraEnabled
    public Id contractId;
    @AuraEnabled
    public String onboardingScenario;
    @AuraEnabled
    public OIFormPayloadWrapper payload;
    @AuraEnabled
    public String repCollectingOnMxBehalf;
    @AuraEnabled
    public List<StoreDataWrapper> storeDataWrappers;
    @AuraEnabled
    public boolean isMxInputRequired;
    @AuraEnabled
    public String emailRecipient;
    @AuraEnabled
    public Id opportunityId;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param businessAccountId
     * @param contractId
     */
    public OIMainDataWrapper(Id businessAccountId, Id contractId) {
        this.businessAccountId = businessAccountId;
        this.contractId = contractId;
    }
}