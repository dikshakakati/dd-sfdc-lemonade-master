/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Interface to add Opportunity Selector class methods
 */
public interface IOpportunitiesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Opportunities based on ID
     * @param setIds Set of Ids
     * @return list of Opportunity records
     */
    List<Opportunity> selectById(Set<Id> setIds);

    /**
     * @description This method querying Opportunities by AccountId.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesByAccountId(Set<Id> accountIds);

    /**
     * @description This method is used to get the List of Opportunity based
     * 				on child Product_Insights__c Id
     * @param childInsights
     * @return List<Opportunity> selectByInsights(List<Product_Insights__c> childInsights)
     */
    List<Opportunity> selectByInsights(List<Product_Insights__c> childInsights);

    /**
     * @description This method is to get the list of opportunities in Stalled Stage and not updated
     * in the last passed number of days.
     * @param numberOfDays
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectInactiveOpportunityInStalledStage(Integer numberOfDays);

    /**
     * @description This method is used for querying all open Opportunities without related quotes associated with provided set of account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpenOpportunitiesByAccountIds(Set<Id> accountIds);

    /**
     * @description This method is used for querying all  Opportunities  related quotes associated with provided set of Opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesWithQuotes(Set<Id> opportunityIds);

    /**
     * @description This method is being used to get the query the Opportunities record which associated contract and quotes which are created from Nintex when called from a batch class.
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectOpportunitiesWithNintexUseCaseQueryLocator();

    /**
     * @description This method is being used to get the query the Opportunities record which associated contract and quotes which are created from Nintex when called from a Change Event class.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesWithNintexUseCase(Set<Id> opportunityIds);

    /**
     * @description It is used to get all Opportunities having Nintex Id populated
     * using the passed Opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesWithNintexIdById(Set<Id> opportunityIds);
    /**
     * @description select opps to write back to from the brief
     * @JIRA LEM-9264
     * @param oppIds
     * @return List<Opportunity>
     */
    List<Opportunity> getOpportunitiesToSyncFromBriefs(Set<Id> oppIds);

    /**
     * @description It is used for selecting the opportunities and related quotes when
     * accountIds are passed.
     * @JIRA LEM-13473
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesAndQuotesByAccountIds(Set<Id> accountIds);

    /**
     * @description This method used for querying Opportunities by ContractId.
     * @param contractId
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesByContractId(Id contractId);

    /**
     * @description It is used to select opportunities by the passed unique identifiers.
     * @param uniqueIdentifiers
     * @return List<Opportunity>
     */
    List<Opportunity> getOpportunitiesbyUniqueIdentifiers(Set<String> uniqueIdentifiers);

    /**
     * @description It is used for selecting the opportunities and related OpportunityContactRoles by
     * passing opportunity ids and contact ids.
     * @param opportunityIds
     * @param contactIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunitiesAndOpportunityContactRolesByIds(
        Set<Id> opportunityIds,
        List<Id> contactIds
    );

    /**
     * @description It is used to select opportunities by the passed Account Plan Ids.
     * @JIRA LEM-15227
     * @param accountPlanIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpenOpportunitiesByAccountPlanIds(Set<Id> accountPlanIds);

    /**
     * @description It is used for selecting the opportunities and related quotes by
     * the passed Account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(Set<Id> accountIds);

    /**
     * @description It is used for selecting the Open or Closed Won opportunities by
     * passed Account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectNewStoreExpansionOpportunitiesByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used to Query opportunities with associated Opportunity Team Member
     * by passing opportunity ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(
        Set<Id> opportunityIds
    );

    /**
    * @description It is used for selecting the opportunities by Id and related OpportunityContactRoles with condition
    * @author SamikshaDD | 08-01-2024
    * @param opportunityId
    * @param objectToSobjectsFields
    * @return Opportunity
    **/
    Opportunity selectOpportunityContactRoleByOpportunityId(Id opportunityId, Map<String,Set<String>> objectToSobjectsFields);

    /**
     * @description It is used for selecting the opportunities and related quotes by
     * passed Account Ids for non Ads and Promos sub type.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectExistingNonAdsAndPromosOpportunities(Set<Id> accountIds);

    /**
     * @description It is used to select Opportunities by Sub Type and AccountIds where Sub Type
     * is NSE and Stage is not closed.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectBySubTypeAndAccount(Set<Id> accountIds);

    /**
     * @description This is used to select Open Opportunities by AccountId.
     * @param accountIds
     * @return List<Opportunity>
     */
    List<Opportunity> selectAllOpenOpportunitiesByAccountIds(Set<Id> accountIds);
}