/**
 * @author Deloitte
 * @date 08/18/2023
 * @description Service implementation class for Rate Change Request creation related logic.
 */
public inherited sharing class ManagePricingRateChangeReqServiceImpl implements IManagePricingRateChangeReqService {
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String APPROVED = 'Approved';
    @TestVisible
    Rate_Change_Request__c rateChangeReq;

    /**
     * @description Constructor for initializing rate change request
     */
    public ManagePricingRateChangeReqServiceImpl() {
        this.rateChangeReq = new Rate_Change_Request__c();
    }

    /**
     * @description Creates a Rate change request and Subscription rate change records
     * @param managePricingWrapper
     * @return Id
     */
    public Id createRateChangeRequest(ManagePricingWrapper managePricingWrapper) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        rateChangeReq = createRateChangeRequestOnContracts(
            managePricingWrapper.contractId,
            managePricingWrapper.soSupportCaseId,
            managePricingWrapper.effectiveDate,
            uow
        );

        for (
            ManagePricingWrapper.SubscriptionWrapper eachSubscription : managePricingWrapper.subscriptionWrappers
        ) {
            createSubscriptionRateChanges(eachSubscription, rateChangeReq, uow);
        }

        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
        return rateChangeReq.Id;
    }

    private Rate_Change_Request__c createRateChangeRequestOnContracts(
        Id arpAppliedContractId,
        Id soSupportCaseId,
        Date effectiveDate,
        fflib_ISObjectUnitOfWork uow
    ) {
        Rate_Change_Request__c rateChangeRequestInstance = new Rate_Change_Request__c(
            Contract__c = arpAppliedContractId,
            Effective_Date__c = effectiveDate,
            S_O_Support_Request_Link__c = soSupportCaseId,
            Activation_Status__c = NEW_RATE_CHANGE,
            Status__c = APPROVED
        );

        uow.registerNew(rateChangeRequestInstance);
        return rateChangeRequestInstance;
    }

    private void createSubscriptionRateChanges(
        ManagePricingWrapper.SubscriptionWrapper updatedSubscription,
        Rate_Change_Request__c rateChangeReq,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (
            updatedSubscription.updatedActiveFee != null ||
            updatedSubscription.updatedActiveCommission != null
        ) {
            Subscription_Rate_Change__c subscriptionRateChangeInstance = new Subscription_Rate_Change__c(
                Rate_Change_Request__c = rateChangeReq.Id,
                Subscription__c = updatedSubscription.subscriptionId,
                Update_complete__c = false,
                Updated_Active_Commission__c = (updatedSubscription.updatedActiveCommission != null)
                    ? updatedSubscription.updatedActiveCommission
                    : null,
                Updated_Active_Fee__c = (updatedSubscription.updatedActiveFee != null)
                    ? updatedSubscription.updatedActiveFee
                    : null
            );

            uow.registerNew(
                subscriptionRateChangeInstance,
                Subscription_Rate_Change__c.Rate_Change_Request__c,
                rateChangeReq
            );
        }
    }
}