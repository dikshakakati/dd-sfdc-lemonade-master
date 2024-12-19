/**
 * @author Deloitte
 * @date  08/09/2024
 * @description Service implementation class for Store Detail roll up related logic.
 */
public inherited sharing class StoreDetailRollUpServiceImpl implements IStoreDetailRollUpService {
    private static final String ADDRESS_VERIFICATION_STATUS = 'Address Verification Status';
    private static final String VERIFIED = 'Verified';
    private static final String REJECTED = 'Rejected';
    private static final String UNVERIFIED = 'Unverified';
    private static final String NOT_APPLICABLE = 'Not Applicable';
    /**
     * @description To publish roll up event for Address Verification Status.
     * @param storeDetailsToRollUp
     */
    public void publishAddressVerificationRollUpEvents(
      List<Store_Detail__c> storeDetailsToRollUp
    ) {
      if (storeDetailsToRollUp.isEmpty()) {
        return;
      }
      RollUpEvent__e evt;
      fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
      for (Store_Detail__c eachStoreDetail : storeDetailsToRollUp) {
        evt = new RollUpEvent__e();
        evt.RecordId__c = eachStoreDetail.Mx_Onboarding_Link__c;
        evt.Type__c = ADDRESS_VERIFICATION_STATUS;
        uow.registerPublishAfterSuccessTransaction(evt);
      }
      commitWork(uow);
    }

    /**
     * @description To check if the set of Ids are empty or null.
     * @param setIds
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Set<Id> setIds) {
      return setIds == null || setIds.isEmpty();
    }

    /**
     * @description To perform roll up calculation on Address Verification Status.
     * @param mxOnboardingLinkIds
     */
    public void rollUpAddressVerificationStatus(Set<Id> mxOnboardingLinkIds) {
      if (isEmptyOrNull(mxOnboardingLinkIds)) {
        return;
      }
      fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
      for (
        Mx_Onboarding_Link__c eachMxOnboardingLink : MxOnboardingLinksSelector.newInstance()
          .selectByMxOnboardingLinkIds(mxOnboardingLinkIds)
      ) {
        eachMxOnboardingLink.Address_Verification_Status__c = UNVERIFIED;
        for (
          Store_Detail__c eachStoreDetail : eachMxOnboardingLink.Store_Details__r
        ) {
          if (eachStoreDetail.Address_Verification_Status__c != NOT_APPLICABLE) {
            if (
              eachStoreDetail.Address_Verification_Status__c == REJECTED ||
              eachStoreDetail.Address_Verification_Status__c == VERIFIED
            ) {
              eachMxOnboardingLink.Address_Verification_Status__c = VERIFIED;
              continue;
            }
            if (eachStoreDetail.Address_Verification_Status__c == UNVERIFIED) {
              eachMxOnboardingLink.Address_Verification_Status__c = UNVERIFIED;
              break;
            }
          }
        }
        uow.registerDirty(eachMxOnboardingLink);
      }
      commitWork(uow);
    }

    /**
     * @description It is a common method to commit unit of work.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
      try {
        uow.commitWork();
      } catch (Exception ex) {
        Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        throw ex;
      }
    }
  }
