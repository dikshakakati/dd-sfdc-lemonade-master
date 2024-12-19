/**
 * @author Deloitte
 * @date 05/12/2022
 * @description Interface to add duplicate check service class methods
 */
public interface ICheckDuplicatesService {
    /**
     * @description This method is used to return the duplicate records with original record as key.
     * @param sObjectIds
     * @param duplicateRuleName
     * @return Map<Id, List<SObject>>
     */
    Map<Id, List<SObject>> getMapOfSObjectIdWithDuplicates(
        List<Id> sObjectIds,
        String duplicateRuleName
    );

    /**
     * @description It is used to get the matching SObjects for the given duplicate SObjects.
     * @param sObjects
     * @return List<SObject>
     */
    List<SObject> getMatchingSObjectsByDuplicateSObjects(
        List<SObject> sObjects
    );
}