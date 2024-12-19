/**
 * @description Agreement__c Object Trigger Handler.
 * @author ATG
 * @date 2022-05-20
 */
public class AgreementsHandler extends ApplicationDomainHandler {
    private static final String ACTIVE = 'Active';
    private static final String AGREED_TO_SERVICES_ALL = 'All';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement';
    private static final String AGREEMENT_TYPE_BUSINESS = 'Business Agreement';
    /**
     * @description Constructor Method
     * @param sObjectList - Contract Record List
     */
    public AgreementsHandler(List<Agreement__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Agreement__c.SObjectType, AgreementsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return AgreementsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AgreementsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Agreements.newInstance(this.records)
            .onAfterInsertHandleRelatedRecords((List<Agreement__c>) getRecords());
        //When Manage Stores button creates the Agreement, Process in a Platform Event
        AgreementsService.publishAgreementActivationEvents(
            AgreementsSelector.newInstance()
                .selectById(getActiveAgreements((List<Agreement__c>) getRecords(), true)),
            false
        );

        //When Nintex Forms create the Agreement record Process right away.
        Set<Id> agreementIds = getActiveAgreements((List<Agreement__c>) getRecords(), false);
        if (!agreementIds.isEmpty()) {
            ActivationOrdersService.createActivationOrdersAndProducts(
                AgreementsSelector.newInstance().selectById(agreementIds),
                false
            );
        }
    }

    /**
     * @description Called to perform after updatet processing
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        Set<Id> agreementIds = getActiveAgreements(
            (List<Agreement__c>) getChangedRecords(new Set<SObjectField>{ Agreement__c.Status__c })
        );
        if (!agreementIds.isEmpty()) {
            ActivationOrdersService.createActivationOrdersAndProducts(
                AgreementsSelector.newInstance().selectById(agreementIds),
                false
            );
        }

        Set<Id> existingAgreementIds = getActiveAgreements(
            (List<Agreement__c>) getChangedRecords(
                new Set<SObjectField>{ Agreement__c.Serialized_Entitlements_Data__c }
            ),
            true
        );
        if (!existingAgreementIds.isEmpty()) {
            AgreementsService.publishAgreementActivationEvents(
                AgreementsSelector.newInstance().selectById(existingAgreementIds),
                true
            );
        }
        //@JIRA #LEM-15980
        AgreementsService.updateMxServicesBasedOnRecordsCount(getDeactivatedAgreements(), false);
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        //@JIRA #LEM-15980
        Agreements.newInstance(this.records)
            .updateDeactivationDateOrStatus(getDeactivatedAgreements());
    }

    /**
     * @description returns all records that have status Active on insert,
     *      otherwise, only changed records with status Active.
     * @param agreements to check
     * @param runAsynch Send Platform event
     * @return active agreements
     */
    private Set<Id> getActiveAgreements(List<Agreement__c> agreements, boolean runAsynch) {
        Set<Id> activeAgreementIds = new Set<Id>();
        for (Agreement__c agreement : agreements) {
            //LEM-4534 run Business Agreements Asynch.
            Boolean ableToRunAsynch = (agreement.Agreed_To_Services__c == AGREED_TO_SERVICES_ALL);
            if (
                (agreement.Status__c == ACTIVE) &&
                (((agreement.Type__c == AGREEMENT_TYPE_BUSINESS) && (runAsynch)) ||
                ((agreement.Type__c == AGREEMENT_TYPE_STORE) && (runAsynch == ableToRunAsynch)))
            ) {
                activeAgreementIds.add(agreement.Id);
            }
        }
        return activeAgreementIds;
    }

    /**
     * @description returns all records that have status Active on insert,
     *      otherwise, only changed records with status Active.
     * @param agreements to check
     * @return active agreements
     */
    private Set<Id> getActiveAgreements(List<Agreement__c> agreements) {
        Set<Id> activeAgreementIds = new Set<Id>();
        for (Agreement__c agreement : agreements) {
            if (
                (agreement.Status__c == ACTIVE) &&
                ((agreement.Type__c == AGREEMENT_TYPE_BUSINESS) ||
                (agreement.Type__c == AGREEMENT_TYPE_STORE))
            ) {
                activeAgreementIds.add(agreement.Id);
            }
        }
        return activeAgreementIds;
    }

    /**
     * @description returns all records that have status cancelled or deactivation date is updated.
     * @JIRA #LEM-15980
     * @return deactivated agreements
     */
    private List<Agreement__c> getDeactivatedAgreements() {
        List<Agreement__c> deactivatedAgreementsList = (List<Agreement__c>) getChangedRecords(
            new Set<SObjectField>{ Agreement__c.Status__c, Agreement__c.Deactivation_Date__c }
        );
        return deactivatedAgreementsList;
    }
}