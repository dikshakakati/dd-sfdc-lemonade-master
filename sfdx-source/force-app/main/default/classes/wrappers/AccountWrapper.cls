/**
 * @author Deloitte
 * @date 27/04/2022
 * @description AccountWrapper for storesOnWorkPlan
 * and addStoresOnWorkOrder lightning web component.
 */
public class AccountWrapper {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public String activationStatus;
    @AuraEnabled
    public String address;
    @AuraEnabled
    public String addressVerificationStatus;
    @AuraEnabled
    public Id businessAccountId;
    @AuraEnabled
    public String externalIds;
    @AuraEnabled
    public Id opportunityId;
    @AuraEnabled
    public Id parentWorkOrderId;
    @AuraEnabled
    public Id workOrderContractId;
    @AuraEnabled
    public Id workOrderId;
    @AuraEnabled
    public String workOrderType;
    @AuraEnabled
    public Id workPlanId;
    @AuraEnabled
    public String workPlanType;

    /**
     * @description Parameterized constructor to set wrapper class variables
     * for storesOnWorkPlan lightning web component.
     * @param accountId
     * @param accountName
     * @param opportunityId
     * @param workOrderId
     */
    public AccountWrapper(
        String accountId,
        String accountName,
        String opportunityId,
        String workOrderId
    ) {
        this.accountId = accountId;
        this.accountName = accountName;
        this.opportunityId = opportunityId;
        this.workOrderId = workOrderId;
    }

    /**
     * @description Parameterized constructor to set wrapper class variables
     * for addStoresOnWorkOrder lightning web component.
     * @param accountId
     * @param accountName
     * @param activationStatus
     * @param address
     * @param externalIds
     */
    public AccountWrapper(
        String accountId,
        String accountName,
        String activationStatus,
        String address,
        String externalIds
    ) {
        this.accountId = accountId;
        this.accountName = accountName;
        this.activationStatus = activationStatus;
        this.address = address;
        this.externalIds = externalIds;
    }
}