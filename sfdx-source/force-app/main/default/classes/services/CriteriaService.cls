/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Service class for Criteria related logic.
 */
public inherited sharing class CriteriaService {
    /**
     * @description It collects decision maker contact details based on passed SObject Ids.
     * @JIRA# LEM-13778
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public static Map<Id, List<SObject>> collectDecisionMakerContactDetails(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        return service().collectDecisionMakerContactDetails(sObjects, sObjectFields);
    }

    /**
     * @description It collects Xref details based on passed SObject Ids.
     * @JIRA# LEM-15574
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public static Map<Id, List<SObject>> collectXrefDetails(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        return service().collectXrefDetails(sObjects, sObjectFields);
    }

    /**
     * @description It collects dependee Work Step details based on passed SObject Ids.
     * @JIRA# LEM-15573
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public static Map<Id, List<SObject>> collectDependeeWorkSteps(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        return service().collectDependeeWorkSteps(sObjects, sObjectFields);
    }

    /**
     * @description It collects child Merchant Order details based on passed Work Steps and Fields.
     * @JIRA# LEM-15573
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public static Map<Id, List<SObject>> collectMxOrders(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        return service().collectMxOrders(sObjects, sObjectFields);
    }

    /**
     * @description - returns instance of ICriteriaService.
     * @JIRA# LEM-13778
     * @return ICriteriaService
     */
    private static ICriteriaService service() {
        return (ICriteriaService) Application.SERVICE.newInstance(ICriteriaService.class);
    }
}