/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Interface for Integration Templates selector class methods.
 */
public interface IIntegrationTemplatesSelector extends fflib_ISObjectSelector {
    /**
     * @description It returns Integration templates based on passed Ids.
     * @param integrationTemplateIds
     * @return List<Integration_Template__c>
     */
    List<Integration_Template__c> selectByIds(Set<Id> integrationTemplateIds);

    /**
     * @description It queries Work Orders associated with the passed Account Ids.
     * @param sObjectTypes
     * @return List<Integration_Template__c>
     */
    List<Integration_Template__c> selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
        Set<String> sObjectTypes
    );

    /**
     * @description It returns SObject details based on passed fields and record Id.
     * @JIRA LEM-13778
     * @param fields
     * @param recordIds
     * @param sObjectType
     * @return List<SObject>
     */
    List<SObject> selectSObjectDetailsWithPassedFieldsByIds(
        Set<String> fields,
        Set<Id> recordIds,
        String sObjectType
    );
}