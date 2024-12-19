/**
 * @description Business Reference Selector interface
 */
public interface IBusinessReferencesSelector extends fflib_ISObjectSelector {
    /**
     * @description get Business References by their unique identifier
     * @param businessReferenceList set of unique idetifiers
     * @return list of business references
     */
    List<Business_Reference__c> selectByBusinessReferenceUniqueIdentifierFields(
        List<Business_Reference__c> businessReferenceList
    );

    /**
     * @description It is used to get the Business References based on Currency ISO Code,
     * Business Verticals, and Brand Names associated to account.
     * @param accountBusinessVerticals
     * @param brandNames
     * @param storeCurrencyIsoCodes
     * @return List<SObject>
     */
    List<Business_Reference__c> selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
        Set<String> accountBusinessVerticals,
        Set<String> brandNames,
        Set<String> storeCurrencyIsoCodes
    );

    /**
    * @description get Matching Business Vertical with MDS and Corporate
    * @author VenkateshDD | 08-05-2024
    * @param bizVerticals
    * @param brandIds
    * @param bizAcountCurrency
    * @param ;
    * @return List<Business_Reference__c>
    **/
    List<Business_Reference__c> selectByBusinessVerticalsBrandIdsAndCurrencyISOCodes(
        Set<Id> bizVerticals,
        Set<Id> brandIds,
        Set<String> bizAcountCurrency
    );

    /**
     * @description get Business References by business vertical
     * @param accountBusinessVerticals
     * @return list of business references
     */
    List<Business_Reference__c> selectByBusinessVerticals(Set<String> accountBusinessVerticals);

    /**
     * @description get Business References by primary verticals
     * @param requestedGraveyardIdSet
     * @return list of business references
     */
    List<Business_Reference__c> selectByGraveyardIds(Set<String> requestedGraveyardIdSet);

    /**
    * @description get Business References by Ids and Integration Status
    * @param businessReferenceIds
    * @param integrationStatus
Í   * @return list of business references
    */
    List<Business_Reference__c> selectBydIdAndIntegrationStatus(
        Set<Id> businessReferenceIds,
        Set<String> integrationStatus
    );

    /**
     * @description get Business References by Ids
     * @param businessReferences
     * @return list of business references
     */
    List<Business_Reference__c> selectByBusRefId(Set<Id> businessReferences);

    /**
     * @description get Business References by Name
     * @param businessReferenceNamesList
     * @return list of business references
     */
    List<Business_Reference__c> selectByBusRefName(List<String> businessReferenceNamesList);

    /**
     * @description It is used for querying businessRef by matching the External Id's
     * @param externalIds
     * @return List<Business_Reference__c>
     */
    List<Business_Reference__c> selectBusRefByExternalId(Set<String> externalIds);

    /**
     * @description It is used for querying businessRef by matching the External Id's & Default Type
     * @param externalIds
     * @param defaultTypes
     * @return List<Business_Reference__c>
     */
    List<Business_Reference__c> selectBusRefByExternalIdAndDefaultType(
        Set<String> externalIds,
        Set<String> defaultTypes
    );

    /**
     * @description get Business References by Name and for specific integration status
     * @param businessReferenceNamesList
     * @param integrationStatus
     * @param defaultTypes
     * @return list of business references
     */
    List<Business_Reference__c> selectByBusRefNameAndIntegrationStatusAndDefaultType(
        Set<String> businessReferenceNamesList,
        Set<String> integrationStatus,
        Set<String> defaultTypes
    );

    /**
     * @description get Business References by SourceId
     * @param sourceIds
     * @return list of business references
     */
    List<Business_Reference__c> selectBySourceIds(List<Id> sourceIds);

    /**
     * @description get Business References by Ids
     * @param businessReferenceIds
     * @return list of business references
     */
    List<Business_Reference__c> selectByIds(Set<Id> businessReferenceIds);

    /**
     * @description get Business References related to Brand with given Default_Type__c and CurrencyIsoCode
     * @param brandId
     * @param defaultTypes
     * @param currencyIsoCodes
     * @return list of business references
     */
    List<Business_Reference__c> selectBizRefsOfGivenBrandDefaultTypesAndCurrencies(
        Id brandId,
        Set<String> defaultTypes,
        Set<String> currencyIsoCodes
    );

    /**
     * @description get Business References by default Type and external Id Source
     * @param businessAccountIds
     * @param defaultType
     * @param externalIDSource
     * @return List<Business_Reference__c>
     */
    List<Business_Reference__c> selectByDefaultTypeAndExternalIdSource(
        Set<String> businessAccountIds,
        Set<String> defaultType,
        Set<String> externalIDSource
    );

    /**
     * @description It is used to get Business reference records by uniqueIdentifiers.
     * @param uniqueIdentifiers
     * @return List<Business_Reference__c>
     */
    List<Business_Reference__c> selectBusinessReferenceByUniqueIdentifiers(
        Set<String> uniqueIdentifiers
    );

    /**
     * @description LEM-14427, get all the Business Group Ids associated with the account.
     * @param accountId
     * @return list of business references
     */
    List<Business_Reference__c> selectBGGroupIdByAccountId(Id accountId);
    /**
     * @description LEM-16079, get all the Business Reference based on BGID and Biz ID.
     * @param externalIdValue
     * @return list of business references
     */
    List<Business_Reference__c> selectByBizId(
        String externalIdValue);

    /**
     * @description get Business References
     * @param businessIDs
     * @return list of business references
     */
    List<Business_Reference__c> selectByBrandOwnerId(Set<Id> businessIDs);

    /**
     * @description It is used for querying Business References with Integration Status as 'Success' by matching businessIds.
     * @param businessIds
     * @return List<Business_Reference__c>
     */
    List<Business_Reference__c> selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
        Set<String> businessIds
    );

    /**
    * @description
    * @jira LEM-17697
    * @param businessVerticals
    * @param brands
    * @param currencyCodes
    * @param ;
    * @return List<Business_Reference__c>
    **/
    List<Business_Reference__c> selectByBusinessVerticalBrandCurrencyExternalIdDefaultType(
        Set<String> businessVerticals,
        Set<String> brands,
        Set<String> currencyCodes);

    /**
     * @description Returns all business reference information in a given account hierarchy.
     * @param accountIds An array of Account IDs for which to retrieve business reference information
     * @return Aggregate[] An list of Aggregate records containing associated business reference information
     * for the given account hierarchy
     */
    Aggregate[] selectAllBusinessIdsInAccountHierarchy( String[] accountIds );
}
