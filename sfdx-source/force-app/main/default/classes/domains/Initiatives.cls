/**
 * @description Domain Class for Initiatives Object
 * @author Deloitte
 * @date 27/04/2022
 */
public inherited sharing class Initiatives extends fflib_SObjects implements IInitiatives {
    private static final String AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS = 'mxTouchpointId';
    private static final String BLANK_SPACE = ' ';
    private static final String COMPLETE_STATUS = 'Complete';
    private static final String INTERACTION_TYPE_MEETING = 'Meeting';
    private static final String INTERACTION_TYPE_PHONE_CALL = 'Phone Call';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_TASK_CREATION_ERROR = 'Error in creation of Tasks on complete Mx Touchpoints';
    private static final String TASK_COMMENT = 'This task was created automatically from Mx Touchpoint';
    private static final String TASK_STATUS_COMPLETED = 'Completed';
    private static final String TASK_SUBJECT = 'Mx Touchpoint: ';
    private static final String SEGMENT_SMB = 'SMB';

    /**
     * @description This method is used to return the IInitiatives Interface
     * @param recordList - Initiatives Record List
     * @return IInitiatives - Returns IInitiatives Interface
     */
    public static IInitiatives newInstance(List<Initiative__c> recordList) {
        return (IInitiatives) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default Constructor for the class
     * @param sObjectList
     */
    public Initiatives(List<Initiative__c> sObjectList) {
        super(sObjectList, Schema.Initiative__c.SObjectType);
    }

    /**
     * @description Holds the mock instance of the constructor inner class
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private Method that allows the domain constructor mock to be set by the test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Initiatives - List of Initiative__c
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Initiatives.constructorMock != null) {
                return (fflib_SObjects) Initiatives.constructorMock.construct(objectList);
            }
            return new Initiatives((List<SObject>) objectList);
        }
    }

    /**
     * @description It restricts status update on Mx Touchpoint records if there are no
     * Stakeholder contacts associated.
     * @JIRA# LEM-14667
     */
    public void addErrorOnCompleteMxTouchpointsWithoutStakeholders() {
        Map<Id, Initiative__c> completeMxTouchpointIdToMxTouchpoints = new Map<Id, Initiative__c>();
        for (Initiative__c eachMxTouchpoint : (List<Initiative__c>) getRecords()) {
            if (eachMxTouchpoint.Status__c == COMPLETE_STATUS) {
                completeMxTouchpointIdToMxTouchpoints.put(eachMxTouchpoint.Id, eachMxTouchpoint);
            }
        }
        if (completeMxTouchpointIdToMxTouchpoints.isEmpty()) {
            return;
        }
        for (
            Aggregate eachAggregate : StakeholdersSelector.newInstance()
                .getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
                    completeMxTouchpointIdToMxTouchpoints.keySet()
                )
        ) {
            completeMxTouchpointIdToMxTouchpoints.remove(
                (Id) eachAggregate.get(AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS)
            );
        }
        for (Id eachMxTouchpointId : completeMxTouchpointIdToMxTouchpoints.keySet()) {
            completeMxTouchpointIdToMxTouchpoints.get(eachMxTouchpointId)
                .addError(System.Label.Error_On_Mx_Touchpoint_wo_Stakeholders);
        }
    }

    /**
     * @description Fetches the Ultimate Parent on the Parent Account of
     *              each Initiative and updates the lookup on the current
     *              Initiative Record
     */
    public void populateUltimateParentAccount() {
        List<Initiative__c> recordsWithParentAccounts = (List<Initiative__c>) getRecordsWithNotBlankFieldValues(
            new Set<Schema.SObjectField>{ Initiative__c.Account__c }
        );
        Map<Id, Id> parentAccounts = fetchParentAccounts(recordsWithParentAccounts);
        for (Initiative__c eachInitiative : recordsWithParentAccounts) {
            if (parentAccounts.containsKey(eachInitiative.Account__c)) {
                eachInitiative.Ultimate_Parent_Account__c = parentAccounts.get(
                    eachInitiative.Account__c
                );
            }
            eachInitiative.Is_Parent_Account_Merged__c = false;
        }
    }

    /**
     * @description It creates the Tasks for the 'Complete' Mx Touchpoint records.
     */
    public void createTaskOnCompleteMxTouchpoints() {
        Set<Id> mxTouchpointIds = new Set<Id>();
        Stakeholder__c relatedStakeholder;
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        mxTouchpointIds = new Map<Id, Initiative__c>((List<Initiative__c>) getRecords()).keySet();
        List<Stakeholder__c> stakeholdersWithContacts = StakeholdersSelector.newInstance()
            .getStakeholderContactsByMxTouchPointIds(mxTouchpointIds);
        if (stakeholdersWithContacts != null && !stakeholdersWithContacts.isEmpty()) {
            relatedStakeholder = stakeholdersWithContacts[0];
        }
        for (Initiative__c eachMxTouchpoint : (List<Initiative__c>) getRecords()) {
            if (
                eachMxTouchpoint.Status__c == COMPLETE_STATUS &&
                eachMxTouchpoint.Account_Segment__c == SEGMENT_SMB
            ) {
                unitOfWork.registerNew(
                    Tasks.newInstance(new List<Task>())
                        .createTaskByPassedMxTouchpointAndStakeholder(
                            eachMxTouchpoint,
                            relatedStakeholder
                        )
                );
            }
        }
        unitOfWork.registerNew(createTaskOnStakeholderUsersOfMxTouchPoints(mxTouchpointIds));
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_TASK_CREATION_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }
    /**
     * @description Fetches All the Parent Accounts of the updated Intiatives
     * @param recordsWithParentAccounts
     * @return Map<Id, Account>
     */
    private Map<Id, Id> fetchParentAccounts(List<Initiative__c> recordsWithParentAccounts) {
        Map<Id, Id> ultimateParentIdsByAccountId = new Map<Id, Id>();
        Set<Id> parentAccountIds = new Set<Id>();

        for (Initiative__c eachInitiative : recordsWithParentAccounts) {
            parentAccountIds.add(eachInitiative.Account__c);
        }

        for (Account objAccount : AccountsSelector.newInstance().selectById(parentAccountIds)) {
            if (objAccount.Ultimate_Parent_Account__c != null) {
                ultimateParentIdsByAccountId.put(
                    objAccount.Id,
                    objAccount.Ultimate_Parent_Account__c
                );
            } else {
                ultimateParentIdsByAccountId.put(objAccount.Id, objAccount.Id);
            }
        }
        return ultimateParentIdsByAccountId;
    }
    /**
     * @description It creates the Tasks for the 'Complete' Mx Touchpoint records.
     * @param mxTouchpointIds
     * @return List<Task>
     */
    private List<Task> createTaskOnStakeholderUsersOfMxTouchPoints(Set<id> mxTouchpointIds) {
        List<Task> tasksToBeCreatedForStakeholderUsers = new List<Task>();
        List<Stakeholder__c> stakeholdersWithUsers = StakeholdersSelector.newInstance()
            .getStakeholderUsersByMxTouchPointIds(mxTouchpointIds);
        for (Stakeholder__c eachstakeholder : stakeholdersWithUsers) {
            if (
                eachstakeholder.Initiative__r.Status__c == COMPLETE_STATUS &&
                eachstakeholder.Initiative__r.Account_Segment__c == SEGMENT_SMB
            ) {
                tasksToBeCreatedForStakeholderUsers.add(
                    Tasks.newInstance(new List<Task>())
                        .createTaskByPassedMxTouchpointAndStakeholder(
                            eachstakeholder.Initiative__r,
                            eachstakeholder
                        )
                );
            }
        }
        return tasksToBeCreatedForStakeholderUsers;
    }
}