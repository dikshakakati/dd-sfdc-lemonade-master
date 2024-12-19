/**
 * @author Deloitte
 * @date 30/08/2022
 * @description Parent wrapper for ManagePricing lightning web component.
 */
public with sharing class ManagePricingWrapper {
    @AuraEnabled
    public List<SubscriptionWrapper> subscriptionWrappers = new List<SubscriptionWrapper>();
    /**
     * @description getter/setter for ManagePricingWrapper variable
     */
    @AuraEnabled
    public Id soSupportCaseId { get; set; }
    /**
     * @description getter/setter for ManagePricingWrapper variable
     */
    @AuraEnabled
    public Date effectiveDate { get; set; }
    /**
     * @description getter/setter for ManagePricingWrapper variable
     */
    @AuraEnabled
    public Id contractId { get; set; }
    /**
     * @description getter/setter for ManagePricingWrapper variable
     */
    @AuraEnabled
    public String existingAccountsToUpdate { get; set; }

    /**
     * @description Parameterized constructor to assign value to the variables.
     * @param subscriptionWrappers
     * @param soSupportCaseId
     * @param effectiveDate
     * @param contractId
     * @param existingAccountsToUpdate
     */
    public ManagePricingWrapper(
        List<SubscriptionWrapper> subscriptionWrappers,
        Id soSupportCaseId,
        Date effectiveDate,
        Id contractId,
        String existingAccountsToUpdate
    ) {
        this.subscriptionWrappers = subscriptionWrappers;
        this.soSupportCaseId = soSupportCaseId;
        this.effectiveDate = effectiveDate;
        this.contractId = contractId;
        this.existingAccountsToUpdate = existingAccountsToUpdate;
    }

    /**
     * @description Inner Class for the subscription wrapper.
     */
    public class SubscriptionWrapper {
        /**
         * @description getter/setter for SubscriptionWrapper variable
         */
        @AuraEnabled
        public Id subscriptionId { get; set; }
        /**
         * @description getter/setter for SubscriptionWrapper variable
         */
        @AuraEnabled
        public Decimal updatedActiveFee { get; set; }
        /**
         * @description getter/setter for SubscriptionWrapper variable
         */
        @AuraEnabled
        public Decimal updatedActiveCommission { get; set; }

        /**
         * @description Parameterized constructor to assign value to the variables.
         * @param subscriptionId
         * @param updatedActiveFee
         * @param updatedActiveCommission
         */
        public SubscriptionWrapper(
            Id subscriptionId,
            Decimal updatedActiveFee,
            Decimal updatedActiveCommission
        ) {
            this.subscriptionId = subscriptionId;
            this.updatedActiveFee = updatedActiveFee;
            this.updatedActiveCommission = updatedActiveCommission;
        }
    }
}