/**
 * @author Deloitte
 * @date 25/05/2022
 * @description Account Relationship Object Trigger Handler
 */
public class AccountRelationshipsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate List of Account Relationships
     * @param sObjectList - Account Relationship Record List
     */
    public AccountRelationshipsHandler(List<Account_Relationship__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Account_Relationship__c.SobjectType, AccountRelationshipsHandler.class);
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return AccountRelationshipsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountRelationshipsHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform Default operations on the Account Relationship
     */
    public override void onApplyDefaults() {
        AccountRelationships.newInstance((List<Account_Relationship__c>) getRecords())
            .defaultOperationsOnInsertion();
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        AccountRelationships.newInstance((List<Account_Relationship__c>) getRecords())
            .generateReciprocalRelationship();
    }

    /**
     * @description Called to perform Before Update Processing
     * @param existing
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<Account_Relationship__c> changedRelationships = new List<Account_Relationship__c>(
            (List<Account_Relationship__c>) getChangedRecords(
                new Set<SObjectField>{
                    Account_Relationship__c.Relationship_Type__c,
                    Account_Relationship__c.Inverse_Relationship_Type__c
                }
            )
        );
        AccountRelationships.newInstance(changedRelationships).defaultOperationsOnInsertion();
    }

    /**
     * @description Called to perform after update processing
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Account_Relationship__c> changedRelationships = new List<Account_Relationship__c>(
            (List<Account_Relationship__c>) getChangedRecords(
                new Set<SObjectField>{
                    Account_Relationship__c.Start_Date__c,
                    Account_Relationship__c.End_Date__c,
                    Account_Relationship__c.Relationship_Type__c,
                    Account_Relationship__c.Inverse_Relationship_Type__c,
                    Account_Relationship__c.Relationship_Status__c
                }
            )
        );
        if (changedRelationships.size() == 0) {
            changedRelationships = null;
        }
        if (changedRelationships != null) {
            AccountRelationships.newInstance(changedRelationships)
                .updateReciprocalRelationships((Map<Id, Account_Relationship__c>) existing);
        }
    }

    /**
     * @description Called to perform after delete processing
     */
    public override void onAfterDelete() {
        AccountRelationships.newInstance(existingRecords.values()).deleteReciprocalRelationships();
    }
}