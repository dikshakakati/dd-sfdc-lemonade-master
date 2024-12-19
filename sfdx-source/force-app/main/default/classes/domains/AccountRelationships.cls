/**
 * @author Deloitte
 * @date 27/05/2022
 * @description Domain Class for Account Relationships Object
 */
public inherited sharing class AccountRelationships extends fflib_SObjects implements IAccountRelationships {
    /**
     * @description This method is used to return the IAccountsRelationship interface
     * @param recordList - Account Relationship record list
     * @return IAccountRelationships - Returns IAccountRelationships Interface
     */
    public static IAccountRelationships newInstance(List<Account_Relationship__c> recordList) {
        return (IAccountRelationships) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public AccountRelationships(List<Account_Relationship__c> sObjectList) {
        super(sObjectList, Schema.Account_Relationship__c.SObjectType);
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
     * @description To create instance of Account Relationship domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Construct
         * @param objects List<Object>
         * @return instance of Account Relationships
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (AccountRelationships.constructorMock != null) {
                return (fflib_ISObjects) AccountRelationships.constructorMock.construct(objects);
            }
            return new AccountRelationships((List<Account_Relationship__c>) objects);
        }
    }

    /**
     * @description Performs all operations that needs to occur by default when a new record is inserted
     */
    public void defaultOperationsOnInsertion() {
        for (Account_Relationship__c eachNewRelationship : getRelationships()) {
            eachNewRelationship.External_Id__c = prepareExternalId(eachNewRelationship);
        }
    }

    /**
     * @description Fetches all the records in the current instance
     * @return List<Account_Relationship__c>
     */
    private List<Account_Relationship__c> getRelationships() {
        return (List<Account_Relationship__c>) getRecords();
    }

    /**
     * @description Map External Ids to Account Relationship Records
     * @param relationshipsWithExternalIds
     * @return Map<String, Account_Relationship__c>
     */
    private Map<String, Account_Relationship__c> externalIdsToRelationships(
        List<Account_Relationship__c> relationshipsWithExternalIds
    ) {
        Map<String, Account_Relationship__c> externalIdsToAccountRelations = new Map<String, Account_Relationship__c>();
        for (Account_Relationship__c eachRelationship : relationshipsWithExternalIds) {
            externalIdsToAccountRelations.put(eachRelationship.External_Id__c, eachRelationship);
        }
        return externalIdsToAccountRelations;
    }

    /**
     * @description This method is used to generate externalIDs from the given list of Relationships
     * @param accountRelationships
     * @return Set<String> externalIds
     */
    private Set<String> generateExternalIdsOfRelationships(
        List<Account_Relationship__c> accountRelationships
    ) {
        Set<String> externalIds = new Set<String>();
        for (Account_Relationship__c eachRelationship : accountRelationships) {
            externalIds.add(prepareReciprocalExternalId(eachRelationship));
        }
        return externalIds;
    }

    /**
     * @description This method generates the reciprocal External Id of the Account Relationship
     * @param relationshipRecord
     * @return String
     */
    private String prepareReciprocalExternalId(Account_Relationship__c relationshipRecord) {
        return relationshipRecord.Related_Account__c +
            relationshipRecord.Relationship_Type__c +
            relationshipRecord.Account__c +
            relationshipRecord.Inverse_Relationship_Type__c;
    }

    /**
     * @description This method generates the External Id of the Account Relationship
     * @param relationshipRecord
     * @return String
     */
    private String prepareExternalId(Account_Relationship__c relationshipRecord) {
        return relationshipRecord.Account__c +
            relationshipRecord.Inverse_Relationship_Type__c +
            relationshipRecord.Related_Account__c +
            relationshipRecord.Relationship_Type__c;
    }

    /**
     * @description Maps the field values of Account Relationships to their reciprocals
     * @param sourceRelationship
     * @param relationshipToBeUpdated
     */
    private void mapFieldValuesOfAccountRelationships(
        Account_Relationship__c sourceRelationship,
        Account_Relationship__c relationshipToBeUpdated
    ) {
        relationshipToBeUpdated.Account__c = sourceRelationship.Related_Account__c;
        relationshipToBeUpdated.Related_Account__c = sourceRelationship.Account__c;
        relationshipToBeUpdated.Relationship_Type__c = sourceRelationship.Inverse_Relationship_Type__c;
        relationshipToBeUpdated.Inverse_Relationship_Type__c = sourceRelationship.Relationship_Type__c;
        relationshipToBeUpdated.Relationship_Status__c = sourceRelationship.Relationship_Status__c;
        relationshipToBeUpdated.Start_Date__c = sourceRelationship.Start_Date__c;
        relationshipToBeUpdated.End_Date__c = sourceRelationship.End_Date__c;
        relationshipToBeUpdated.External_Id__c = prepareReciprocalExternalId(sourceRelationship);
    }

    /**
     * @description Generate Account Relationship Records with Reciprocal Relationships
     */
    public void generateReciprocalRelationship() {
        Set<String> externalIds = generateExternalIdsOfRelationships(getRelationships());
        Map<String, Account_Relationship__c> externalIdsToAccountRelations = new Map<String, Account_Relationship__c>();
        Map<String, Account_Relationship__c> reciprocalRelationships = new Map<String, Account_Relationship__c>();
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();

        for (Account_Relationship__c eachGeneratedRelationship : getRelationships()) {
            String externalIdOfNewReciprocalRelation = prepareReciprocalExternalId(
                eachGeneratedRelationship
            );
            Account_Relationship__c reciprocalRelation = new Account_Relationship__c();
            mapFieldValuesOfAccountRelationships(eachGeneratedRelationship, reciprocalRelation);
            reciprocalRelationships.put(externalIdOfNewReciprocalRelation, reciprocalRelation);
        }
        externalIdsToAccountRelations = externalIdsToRelationships(
            new AccountRelationshipsSelector().selectRelationshipsWithExternalIds(externalIds)
        );
        externalIds.removeAll(externalIdsToAccountRelations.keySet());

        for (String eachExtId : externalIds) {
            relationshipUnitOfWork.registerNew(reciprocalRelationships.get(eachExtId));
        }
        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description Delete Reciprocal Relationships of deleted Account Relationships
     */
    public void deleteReciprocalRelationships() {
        Set<String> externalIds = generateExternalIdsOfRelationships(getRelationships());
        List<Account_Relationship__c> reciprocalRelationshipsToBeDeleted = new AccountRelationshipsSelector()
            .selectRelationshipsWithExternalIds(externalIds);
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();

        relationshipUnitOfWork.registerDeleted(reciprocalRelationshipsToBeDeleted);

        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description Update Reciprocal Relationships of Account Relationships that have been updated
     * @param existingRelationships
     */
    public void updateReciprocalRelationships(
        Map<Id, Account_Relationship__c> existingRelationships
    ) {
        //Generate the externalIds of the reciprocal relationships of older versions of the updated relationships
        Set<String> externalIds = generateExternalIdsOfRelationships(
            existingRelationships.values()
        );
        //Query all reciprocal relationships
        List<Account_Relationship__c> reciprocalRelationshipsToBeUpdated = new AccountRelationshipsSelector()
            .selectRelationshipsWithExternalIds(externalIds);
        //Map External Id -> Account Relationship
        Map<String, Account_Relationship__c> reciprocalRelationships = externalIdsToRelationships(
            reciprocalRelationshipsToBeUpdated
        );
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();

        for (Account_Relationship__c eachUpdatedRelationship : getRelationships()) {
            Account_Relationship__c oldVersionOfUpdatedRelationship = existingRelationships.get(
                eachUpdatedRelationship.Id
            );
            Account_Relationship__c eachReciprocalRelationship = reciprocalRelationships.get(
                prepareReciprocalExternalId(oldVersionOfUpdatedRelationship)
            );
            if (eachReciprocalRelationship != null) {
                mapFieldValuesOfAccountRelationships(
                    eachUpdatedRelationship,
                    eachReciprocalRelationship
                );
                reciprocalRelationships.remove(
                    prepareReciprocalExternalId(eachUpdatedRelationship)
                );
                reciprocalRelationships.put(
                    eachReciprocalRelationship.External_Id__c,
                    eachReciprocalRelationship
                );
            }
        }
        relationshipUnitOfWork.registerDirty(reciprocalRelationships.values());

        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted
     * @param relationshipUnitOfWork
     */
    private void commitUnitOfWork(fflib_ISObjectUnitOfWork relationshipUnitOfWork) {
        try {
            relationshipUnitOfWork.commitWork();
        } catch (Exception relationshipUnitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    relationshipUnitOfWorkException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }
}