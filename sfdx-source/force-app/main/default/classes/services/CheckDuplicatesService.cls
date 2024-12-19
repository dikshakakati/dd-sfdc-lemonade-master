/**
 * @author Deloitte
 * @date   05/12/2022
 * @description This is the service class to check duplicate records
 */
public inherited sharing class CheckDuplicatesService {
    /**
     * @description This method is used to return the duplicate records with original record as key.
     * @param sObjectIds
     * @param duplicateRuleName
     * @return Map<Id, List<SObject>>
     */
    public static Map<Id, List<SObject>> getMapOfSObjectIdWithDuplicates(
        List<Id> sObjectIds,
        String duplicateRuleName
    ) {
        return service().getMapOfSObjectIdWithDuplicates(sObjectIds, duplicateRuleName);
    }

    /**
     * @description It is used to get the matching SObjects for the given duplicate SObjects.
     * @param sObjects
     * @return List<SObject>
     */
    public static List<SObject> getMatchingSObjectsByDuplicateSObjects(List<SObject> sObjects) {
        return service().getMatchingSObjectsByDuplicateSObjects(sObjects);
    }

    private static ICheckDuplicatesService service() {
        return (ICheckDuplicatesService) Application.Service.newInstance(
            ICheckDuplicatesService.class
        );
    }
}