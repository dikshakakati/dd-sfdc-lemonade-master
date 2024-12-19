/**
 * @author Deloitte
 * @date 2024-04-26
 * @description Domain Class for Mx_Tag_Association__c Object
 */
public inherited sharing class MxTagAssociations extends fflib_SObjects implements IMxTagAssociations {
    fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String LOG_UPDATE_SOBJECT_BASED_ON_MX_TAG_ASSOCIATION = 'Failed to create new Mx Tag Association with same attributes on Parent Account.';
    private static final String LOG_DOMAIN = 'Sales';
    static final String STATUS_ACTIVE = 'Active';
    static final String STATUS_INACTIVE = 'Inactive';

    /**
     * @description This method is used to return the IMxTagAssociations interface
     * @param recordList - Orders record list
     * @return IMxTagAssociations - Returns IMxTagAssociations Interface
     */
    public static IMxTagAssociations newInstance(List<Mx_Tag_Association__c> recordList) {
        return (IMxTagAssociations) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public MxTagAssociations(List<Mx_Tag_Association__c> sObjectList) {
        super(sObjectList, Schema.Mx_Tag_Association__c.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of Mx_Tag_Association__c domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of Mx_Tag_Association__c
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (MxTagAssociations.constructorMock != null) {
                return (fflib_ISObjects) MxTagAssociations.constructorMock.construct(objects);
            }
            return new MxTagAssociations((List<Mx_Tag_Association__c>) objects);
        }
    }

    /**
     * @description It updates Start Date and End Date according to Mx Tag Association Status value being 'Active' or 'Inactive'.
     */
    public void updateStartAndEndDate() {
        for (
            Mx_Tag_Association__c eachMxTagAssociation : (List<Mx_Tag_Association__c>) getRecords()
        ) {
            if (eachMxTagAssociation.MxTagAssociation_Status__c == STATUS_ACTIVE) {
                eachMxTagAssociation.Start_Date__c = Date.Today();
                eachMxTagAssociation.End_Date__c = null;
            } else if (eachMxTagAssociation.MxTagAssociation_Status__c == STATUS_INACTIVE) {
                eachMxTagAssociation.End_Date__c = Date.Today();
            }
        }
    }

    /**
     * @description create Mx Tag Association with the same attributes against that store’s Parent Account
     */
    public void createMxTagAssociationsOnParentAccount() {
        List<Mx_Tag_Association__c> mxTagAssociations = (List<Mx_Tag_Association__c>) getRecords();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> storeAccountIdToParentId = new Map<Id, Id>();

        for (Mx_Tag_Association__c mxTagAssociation : mxTagAssociations) {
            if (mxTagAssociation.Account__c != null) {
                accountIds.add(mxTagAssociation.Account__c);
            }
        }
        for (
            Account eachAccount : AccountsSelector.newInstance().selectStoreAccountsById(accountIds)
        ) {
            if (eachAccount.ParentId != null) {
                storeAccountIdToParentId.put(eachAccount.Id, eachAccount.ParentId);
            }
        }
        createNewMxTagAssociation(storeAccountIdToParentId, mxTagAssociations);
    }

    /**
     * @description create new Mx Tag Association
     * @param storeAccountIdToParentId
     * @param mxTagAssociations
     */
    private void createNewMxTagAssociation(
        Map<Id, Id> storeAccountIdToParentId,
        List<Mx_Tag_Association__c> mxTagAssociations
    ) {
        Mx_Tag_Association__c clonedMxTagAssociation;
        for (Mx_Tag_Association__c eachMxTagAssociation : mxTagAssociations) {
            if (storeAccountIdToParentId.keySet().contains(eachMxTagAssociation.Account__c)) {
                clonedMxTagAssociation = eachMxTagAssociation.clone(false, false, false, false);
                clonedMxTagAssociation.Account__c = storeAccountIdToParentId.get(
                    eachMxTagAssociation.Account__c
                );
                uow.registerNew(clonedMxTagAssociation);
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SOBJECT_BASED_ON_MX_TAG_ASSOCIATION,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description Assigning Opportunity on Mx_Tag_Association Insert
     * @JIRA# LEM-14104
     */
    public void assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent() {
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociations = new Map<Id, List<Mx_Tag_Association__c>>();
        for (Mx_Tag_Association__c mxTagAssociation : (List<Mx_Tag_Association__c>) getRecords()) {
            if (
                mxTagAssociation.Account__c != null &&
                mxTagAssociation.MxTagAssociation_Status__c == STATUS_ACTIVE
            ) {
                if (accountIdWithMxTagAssociations.containsKey(mxTagAssociation.Account__c)) {
                    accountIdWithMxTagAssociations.put(
                        mxTagAssociation.Account__c,
                        (List<Mx_Tag_Association__c>) accountIdWithMxTagAssociations.get(
                                mxTagAssociation.Account__c
                            )
                            .add(mxTagAssociation)
                    );
                } else {
                    accountIdWithMxTagAssociations.put(
                        mxTagAssociation.Account__c,
                        new List<Mx_Tag_Association__c>{ mxTagAssociation }
                    );
                }
            }
        }
        createMxTagAssociationsOnOpenOpportunities(accountIdWithMxTagAssociations);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Assigning Opportunity on Mx_Tag_Association Update
     * @JIRA# LEM-14104
     * @param existingRecords
     */
    public void updateOpportunityLookUpOnMxTagAssociationUpdate(Map<Id, SObject> existingRecords) {
        List<Mx_Tag_Association__c> mxTagAssociations = (List<Mx_Tag_Association__c>) getRecords();
        Set<Id> mxTagIds = new Set<Id>();

        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociations = new Map<Id, List<Mx_Tag_Association__c>>();

        for (Mx_Tag_Association__c mxTagAssociation : mxTagAssociations) {
            Mx_Tag_Association__c oldmxTagAssociation = (Mx_Tag_Association__c) existingRecords.get(
                mxTagAssociation.Id
            );
            if (
                mxTagAssociation.Account__c == null ||
                oldmxTagAssociation.Account__c != mxTagAssociation.Account__c
            ) {
                if (accountIdWithMxTagAssociations.containsKey(oldmxTagAssociation.Account__c)) {
                    accountIdWithMxTagAssociations.put(
                        oldmxTagAssociation.Account__c,
                        (List<Mx_Tag_Association__c>) accountIdWithMxTagAssociations.get(
                                oldmxTagAssociation.Account__c
                            )
                            .add(mxTagAssociation)
                    );
                } else {
                    accountIdWithMxTagAssociations.put(
                        oldmxTagAssociation.Account__c,
                        new List<Mx_Tag_Association__c>{ mxTagAssociation }
                    );
                }

                mxTagIds.add(mxTagAssociation.MxTag__c);
            }
        }

        if (!((accountIdWithMxTagAssociations.keySet()).isEmpty())) {
            deleteMxTagAssociations(accountIdWithMxTagAssociations, mxTagIds);
        }
    }

    /**
     * @description remove Opportunity LookUp On AccountChange
     * @param accountIdWithMxTagAssociations
     * @param mxTagIds
     */
    public void deleteMxTagAssociations(
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociations,
        Set<Id> mxTagIds
    ) {
        Set<Id> opportunityIds = new Set<Id>();
        for (
            Opportunity opportunity : OpportunitiesSelector.newInstance()
                .selectOpportunitiesByAccountId(accountIdWithMxTagAssociations.keySet())
        ) {
            if (!opportunity.isClosed) {
                opportunityIds.add(opportunity.Id);
            }
        }
        if (opportunityIds.isEmpty()) {
            return;
        }
        for (
            Mx_Tag_Association__c mxTagAssociation : MxTagAssociationsSelector.newInstance()
                .selectByOpportunityIds(opportunityIds)
        ) {
            if (mxTagIds.contains(mxTagAssociation.MxTag__c)) {
                uow.registerDeleted(mxTagAssociation);
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Assigning Opportunity on Mx_Tag_Association Delete
     */
    public void updateOpportunityLookUpOnMxTagAssociationDelete() {
        List<Mx_Tag_Association__c> mxTagAssociations = (List<Mx_Tag_Association__c>) getRecords();
        Set<Id> mxTagIds = new Set<Id>();
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociations = new Map<Id, List<Mx_Tag_Association__c>>();

        if (mxTagAssociations[0].Account__c == null || mxTagAssociations.isEmpty()) {
            return;
        }
        for (Mx_Tag_Association__c mxTagAssociation : mxTagAssociations) {
            if (accountIdWithMxTagAssociations.containsKey(mxTagAssociation.Account__c)) {
                accountIdWithMxTagAssociations.put(
                    mxTagAssociation.Account__c,
                    (List<Mx_Tag_Association__c>) accountIdWithMxTagAssociations.get(
                            mxTagAssociation.Account__c
                        )
                        .add(mxTagAssociation)
                );
            } else {
                accountIdWithMxTagAssociations.put(
                    mxTagAssociation.Account__c,
                    new List<Mx_Tag_Association__c>{ mxTagAssociation }
                );
            }

            mxTagIds.add(mxTagAssociation.MxTag__c);
        }
        if (!((accountIdWithMxTagAssociations.keySet()).isEmpty())) {
            deleteMxTagAssociations(accountIdWithMxTagAssociations, mxTagIds);
        }
    }

    /**
     * @description It is used to get 'Active' Mx Tag Associations
     * by the passed Business Account Ids.
     * @JIRA# LEM-14041
     * @param businessAccountIds
     * @return Map<Id, Set<String>>
     */
    public Map<Id, Set<String>> getActiveMxTagAssociationsByBusinessAccountIds(
        Set<Id> businessAccountIds
    ) {
        Map<Id, Set<String>> accountIdToMxTagAssociations = new Map<Id, Set<String>>();
        for (
            Mx_Tag_Association__c eachMxTagAssociation : MxTagAssociationsSelector.newInstance()
                .selectByBusinessAccountIds(businessAccountIds)
        ) {
            if (!accountIdToMxTagAssociations.containsKey(eachMxTagAssociation.Account__c)) {
                accountIdToMxTagAssociations.put(
                    eachMxTagAssociation.Account__c,
                    new Set<String>{}
                );
            }
            accountIdToMxTagAssociations.get(eachMxTagAssociation.Account__c)
                .add(eachMxTagAssociation.MxTagName__c);
        }
        return accountIdToMxTagAssociations;
    }

    /**
     * @description It is used to create Mx Tag association records on open Opportunities
     * associated to the Accounts.
     * @JIRA# LEM-14104
     * @param accountIdWithMxTagAssociations
     */
    private void createMxTagAssociationsOnOpenOpportunities(
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociations
    ) {
        Mx_Tag_Association__c newMxTagAssociation = new Mx_Tag_Association__c();
        if ((accountIdWithMxTagAssociations.keySet()).isEmpty()) {
            return;
        }
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectOpportunitiesByAccountId(accountIdWithMxTagAssociations.keySet())
        ) {
            if (
                !eachOpportunity.IsClosed &&
                accountIdWithMxTagAssociations.get(eachOpportunity.accountId) != null
            ) {
                for (
                    Mx_Tag_Association__c eachMxTagAssociation : accountIdWithMxTagAssociations.get(
                        eachOpportunity.accountId
                    )
                ) {
                    newMxTagAssociation = eachMxTagAssociation.clone(false, false, false, false);
                    newMxTagAssociation.Opportunity__c = eachOpportunity.Id;
                    newMxTagAssociation.Account__c = null;
                    uow.registerNew(newMxTagAssociation);
                }
            }
        }
    }
}