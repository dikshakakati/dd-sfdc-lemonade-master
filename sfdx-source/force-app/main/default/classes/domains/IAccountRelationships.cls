/**
 * @author Deloitte
 * @date 23/05/2022
 * @description Interface to add domain class methods for Account Relationships
 */
public interface IAccountRelationships extends fflib_ISObjects {
    /**
     * @description Performs all operations that need occur by default when a new record is inserted
     */
    void defaultOperationsOnInsertion();

    /**
     * @description Generate Mirror Records with Opposite Relationships
     */
    void generateReciprocalRelationship();

    /**
     * @description Update Reciprocal Relationships of Account Relationships that have been updated
     * @param existingRelationships
     */
    void updateReciprocalRelationships(Map<Id, Account_Relationship__c> existingRelationships);

    /**
     * @description Delete Reciprocal Relationships of deleted Account Relationships
     */
    void deleteReciprocalRelationships();
}