/**
 * @author Deloitte
 * @date 01/07/2024
 * @description Mx_Onboarding_Link__c object trigger handler.
 */
public class MxOnboardingLinksHandler extends ApplicationDomainHandler {
    private static final String INACTIVE_REASON_SUBMITTED = 'Submitted';
    private static final String RECORD_CREATION_STATUS_SUCCESS = 'Success';
    private static final String OI_DATA_SERVICE = 'OIDataService';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String SOURCE_RESSMO = 'RESSMO';
    /**
     * @description Constructor Method.
     * @param sObjects
     */
    public MxOnboardingLinksHandler(List<Mx_Onboarding_Link__c> sObjects) {
        super(sObjects);
        setContextBypass(Mx_Onboarding_Link__c.SObjectType, MxOnboardingLinksHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable.
         * @param sObjectList - List of SObjects
         * @return MxOnboardingLinksHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MxOnboardingLinksHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after Update processing.
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> recordIds = new Set<Id>();
        List<Mx_Onboarding_Link__c> mxOnboardingLinksWithChangedCreationStatus = new List<Mx_Onboarding_Link__c>(
            (List<Mx_Onboarding_Link__c>) getChangedRecords(
                new Set<SObjectField>{ Mx_Onboarding_Link__c.Record_Creation_Status__c }
            )
        );
        MxOnboardingLinks.newInstance(mxOnboardingLinksWithChangedCreationStatus)
            .initiateWorkOrderCreation();
        MxOnboardingLinks.newInstance(mxOnboardingLinksWithChangedCreationStatus)
            .initiateStoreAgreementCreationAsync();
        for (
            Mx_Onboarding_Link__c eachMxOnboardingLink : (List<Mx_Onboarding_Link__c>) getChangedRecords(
                new Set<SObjectField>{
                    Mx_Onboarding_Link__c.Address_Verification_Status__c,
                    Mx_Onboarding_Link__c.Inactive_Reason__c
                }
            )
        ) {
            if (
                ((eachMxOnboardingLink.Address_Verification_Status__c ==
                ADDRESS_VERIFICATION_STATUS &&
                eachMxOnboardingLink.Inactive_Reason__c == INACTIVE_REASON_SUBMITTED) ||
                ((!String.isEmpty(eachMxOnboardingLink.One_Time_Mx_Link__c) &&
                eachMxOnboardingLink.One_Time_Mx_Link__c != null) &&
                eachMxOnboardingLink.Store_Count__c == 0 &&
                eachMxOnboardingLink.Inactive_Reason__c == INACTIVE_REASON_SUBMITTED))
            ) {
                recordIds.add(eachMxOnboardingLink.Id);
            }
        }
        if (!recordIds.isEmpty()) {
            createInterfaceTransaction(recordIds);
        }
    }

    /**
     * @description Called to perform After Insert processing.
     */
    public override void onAfterInsert() {
        new IntegrationCriteriaEvaluator().evaluateInitialCriteriaForEmailIntegration(this.records);
        Set<Id> recordIds = new Set<Id>();
        for (Mx_Onboarding_Link__c mxLink : (List<Mx_Onboarding_Link__c>) getRecords()) {
            if (mxLink.One_Time_Mx_Link__c == null && mxLink.Source__c != SOURCE_RESSMO) {
                recordIds.add(mxLink.Id);
            }
        }
        if (!recordIds.isEmpty()) {
            createInterfaceTransaction(recordIds);
        }
    }
    private void createInterfaceTransaction(Set<Id> recordIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id mxLink : recordIds) {
            uow.registerNew(
                new Interface_Transaction__c(
                    Payload__c = mxLink,
                    Remaining_Retry_Attempts__c = 3,
                    Interface_Transaction_Configuration_Name__c = OI_DATA_SERVICE,
                    Record_Id__c = mxLink
                )
            );
        }
        uow.commitWork();
    }
}