/**
 * @author Deloitte
 * @date   05/12/2022
 * @description This is the service implementation class to check duplicate records
 */
public inherited sharing class CheckDuplicatesServiceImpl implements ICheckDuplicatesService {
    /**
     * @description This method is used to return the duplicate records with original record as key.
     * @param sObjectIds
     * @param duplicateRuleName
     * @return Map<Id, List<SObject>>
     */
    public Map<Id, List<SObject>> getMapOfSObjectIdWithDuplicates(
        List<Id> sObjectIds,
        String duplicateRuleName
    ) {
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(
            sObjectIds
        );
        Integer i = 0;
        Map<Id, List<SObject>> sObjectIdWithDuplicates = new Map<Id, List<SObject>>();
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            sObjectIdWithDuplicates.put(sObjectIds[i], new List<SObject>());
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                if (dupeResult.getDuplicateRule() == duplicateRuleName) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            if (sObjectIdWithDuplicates.containsKey(sObjectIds[i])) {
                                sObjectIdWithDuplicates.get(sObjectIds[i])
                                    .add((SObject) matchRecord.getRecord());
                            }
                        }
                    }
                }
            }
            i++;
        }
        return sObjectIdWithDuplicates;
    }

    /**
     * @description It is used to get the matching SObjects for the given duplicate SObjects.
     * #JIRA LEM-10205
     * @param sObjects
     * @return List<SObject>
     */
    public List<SObject> getMatchingSObjectsByDuplicateSObjects(List<SObject> sObjects) {
        List<SObject> matchRecords = new List<SObject>();
        for (Datacloud.FindDuplicatesResult findDuplicateResult : Datacloud.FindDuplicates.findDuplicates(sObjects)) {
            for (Datacloud.DuplicateResult eachDuplicateResult : findDuplicateResult.getDuplicateResults()) {
                for (Datacloud.MatchResult eachMatchResult : eachDuplicateResult.getMatchResults()) {
                    for (Datacloud.MatchRecord eachMatchRecord : eachMatchResult.getMatchRecords()) {
                        matchRecords.add((SObject) eachMatchRecord.getRecord());
                    }
                }
            }
        }
        return matchRecords;
    }
}