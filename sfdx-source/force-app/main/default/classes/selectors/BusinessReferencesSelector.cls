/**
 * @description Selector class for the Business Reference Object
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class BusinessReferencesSelector extends fflib_SObjectSelector implements IBusinessReferencesSelector {
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final Set<String> NON_COMPLETE_STATUS = new Set<String>{
        'Complete',
        'Dead',
        'Not Workable'
    };
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String CREATED_DATE_FIELD = 'CreatedDate';
    /**
     * @description default constructor for the BusinessReferencesSelector class
     * @return IBusinessReferencesSelector - interface of IBusinessReferencesSelector
     */
    public static IBusinessReferencesSelector newInstance() {
        return (IBusinessReferencesSelector) Application.Selector.newInstance(
            Business_Reference__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Brand object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Business_Reference__c.Id,
            Business_Reference__c.CurrencyISOCode,
            Business_Reference__c.Created_Source_Id__c,
            Business_Reference__c.External_Id_Source__c,
            Business_Reference__c.Business_Name__c,
            Business_Reference__c.Default_Type__c,
            Business_Reference__c.Integration_Status__c,
            Business_Reference__c.Last_Completed_Step__c,
            Business_Reference__c.External_Id__c,
            Business_Reference__c.Menu_UI_Type__c,
            Business_Reference__c.Primary_Vertical__c,
            Business_Reference__c.Business_Vertical__c,
            Business_Reference__c.Brand__c,
            Business_Reference__c.Business_Group_Id__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Business_Reference__c.SObjectType;
    }

    /**
     * @description get Business References by example matching the fields in
     *      BusinessReferences.UNIQUE_IDENTIFIER_FIELDS
     * @param businessReferenceList list of examples
     * @return list of business references
     */
    public List<Business_Reference__c> selectByBusinessReferenceUniqueIdentifierFields(
        List<Business_Reference__c> businessReferenceList
    ) {
        String conditions = '';

        boolean first = true;
        for (Business_Reference__c businessReference : businessReferenceList) {
            if (first == true) {
                first = false;
                conditions += '(';
            } else {
                conditions += ') OR (';
            }

            boolean fieldFirst = true;
            for (SObjectField field : BusinessReferences.UNIQUE_IDENTIFIER_FIELDS) {
                if (fieldFirst == true) {
                    fieldFirst = false;
                } else {
                    conditions += ' AND ';
                }

                if (businessReference.get(field) == null) {
                    conditions += field.getDescribe().getName() + ' = null';
                } else {
                    conditions +=
                        field.getDescribe().getName() +
                        ' = \'' +
                        String.escapeSingleQuotes((String) businessReference.get(field)) +
                        '\'';
                }
            }
        }

        conditions += ')';

        return (List<Business_Reference__c>) Database.query(
            newQueryFactory().setCondition(conditions).toSOQL()
        );
    }

    /**
     * @description It is used to get the Business References based on Currency ISO Code,
     * Business Verticals, and Brand Names associated to account.
     * @JIRA# LEM-15747
     * @param accountBusinessVerticals
     * @param brandNames
     * @param storeCurrencyIsoCodes
     * @return List<SObject>
     */
    public List<Business_Reference__c> selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
        Set<String> accountBusinessVerticals,
        Set<String> brandNames,
        Set<String> storeCurrencyIsoCodes
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Vertical__c')
            .selectField('Business_Name__c')
            .selectField('Brand__r.Name')
            .setCondition(
                'Business_Vertical__c IN :accountBusinessVerticals' +
                ' AND Brand__r.Name = :brandNames' +
                ' AND CurrencyIsoCode = :storeCurrencyIsoCodes'
            );
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Matching Business Vertical with MDS and Corporate
     * @param bizVerticals
     * @param brandIds
     * @param bizAcountCurrency
     * @return List<Business_Reference__c>
     * @author VenkateshDD | 08-05-2024
     **/
    public List<Business_Reference__c> selectByBusinessVerticalsBrandIdsAndCurrencyISOCodes(
        Set<Id> bizVerticals,
        Set<Id> brandIds,
        Set<String> bizAcountCurrency
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Vertical__c')
            .selectField('Business_Name__c')
            .selectField('Brand__r.Name')
            .setCondition(
                'Business_Vertical__c IN :bizVerticals' +
                ' AND Brand__c IN :brandIds' +
                ' AND CurrencyIsoCode = :bizAcountCurrency' +
                '  AND External_Id_Source__c = :EXTERNAL_ID_SOURCE_MDS AND Default_Type__c = :DEFAULT_TYPE_CORPORATE'
            );
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get the Business Reference Objects based on Accounts Business Vertical
     * @JIRA# LEM-11095 Updated method to get to Business Vertical  instead of Primary vertical
     * @param accountBusinessVerticals
     * @return List<SObject>
     */
    public List<Business_Reference__c> selectByBusinessVerticals(
        Set<String> accountBusinessVerticals
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Vertical__c')
            .selectField('Business_Name__c')
            .selectField('Brand__r.Name')
            .setCondition('Business_Vertical__c IN :accountBusinessVerticals');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Graveyard Business References by External Ids
     * @param requestedGraveyardIdSet
     * @return list of business references
     */
    public List<Business_Reference__c> selectByGraveyardIds(Set<String> requestedGraveyardIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('External_Id__c')
            .setCondition(
                'Default_Type__c = :DEFAULT_TYPE_COO_GRAVEYARD AND External_Id__c IN :requestedGraveyardIdSet'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Ids and Integration Status
     * @param businessReferenceIds
     * @param integrationStatus Í   * @return list of business references
     * @return
     */
    public List<Business_Reference__c> selectBydIdAndIntegrationStatus(
        Set<Id> businessReferenceIds,
        Set<String> integrationStatus
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField(Business_Reference__c.Integration_Message__c)
            .selectField(Business_Reference__c.Provisioning_Error_Category__c)
            .setCondition(
                'Id = :businessReferenceIds AND Integration_Status__c IN :integrationStatus'
            );
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Ids and Integration Status
     * @param businessReferenceIds
     * @return list of business references
     */
    public List<Business_Reference__c> selectByBusRefId(Set<Id> businessReferenceIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Id = :businessReferenceIds AND Integration_Status__c NOT IN :NON_COMPLETE_STATUS'
            );

        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Name
     * @param businessReferenceNamesList
     * @return list of business references
     */
    public List<Business_Reference__c> selectByBusRefName(List<String> businessReferenceNamesList) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Default_Type__c = :DEFAULT_TYPE_COO_GRAVEYARD AND Business_Name__c IN :businessReferenceNamesList'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying businessRef by matching the External Id's
     * @param externalIds
     * @return List<Business_Reference__c>
     */
    public List<Business_Reference__c> selectBusRefByExternalId(Set<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_ID__c IN :externalIds');
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying businessRef by matching the External Id's & Default Type
     * @param externalIds
     * @param defaultTypes
     * @return List<Business_Reference__c>
     */
    public List<Business_Reference__c> selectBusRefByExternalIdAndDefaultType(
        Set<String> externalIds,
        Set<String> defaultTypes
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_ID__c IN :externalIds and Default_Type__c IN :defaultTypes');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Name
     * @param businessReferenceNamesList
     * @param integrationStatus
     * @param defaultTypes
     * @return list of business references
     */
    public List<Business_Reference__c> selectByBusRefNameAndIntegrationStatusAndDefaultType(
        Set<String> businessReferenceNamesList,
        Set<String> integrationStatus,
        Set<String> defaultTypes
    ) {
        fflib_QueryFactory query = newQueryFactory()
            //LEM-16588 - Replaced Business_Name__c with Brand__r.Name
            .selectField('Brand__r.Name')
            .setCondition(
                'Brand__r.Name IN :businessReferenceNamesList AND Integration_Status__c IN :integrationStatus AND Default_Type__c IN :defaultTypes'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Record Id
     * @param sourceIds
     * @return list of business references
     */
    public List<Business_Reference__c> selectBySourceIds(List<Id> sourceIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Brand__r.Name')
            .selectField('Business_Group_Id__c')
            .setCondition('Created_Source_Id__c IN :sourceIds');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by Ids
     * @param businessReferenceIds
     * @return list of business references
     */
    public List<Business_Reference__c> selectByIds(Set<Id> businessReferenceIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Brand__r.Name')
            .selectField('External_Id__c')
            .setCondition('Id = :businessReferenceIds');

        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References related to Brand with given Default_Type__c and CurrencyIsoCode
     * @param brandId
     * @param defaultTypes
     * @param currencyIsoCodes
     * @return list of business references
     */
    public List<Business_Reference__c> selectBizRefsOfGivenBrandDefaultTypesAndCurrencies(
        Id brandId,
        Set<String> defaultTypes,
        Set<String> currencyIsoCodes
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Business_Name__c')
            .selectField('Business_Vertical__c')
            .selectField('Business_Vertical__r.Name')
            .selectField('Default_Type__c')
            .selectField('CurrencyIsoCode')
            .selectField('Brand__c')
            .selectField('Brand__r.Name')
            .setCondition(
                'Default_Type__c IN :defaultTypes AND CurrencyIsoCode IN :currencyISOCodes AND Brand__c = :brandId'
            );
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description get Business References by default Type and external Id Source
     * @param businessIDs
     * @param defaultType
     * @param externalIDSource
     * @return list of business references
     */
    public List<Business_Reference__c> selectByDefaultTypeAndExternalIdSource(
        Set<String> businessIDs,
        Set<String> defaultType,
        Set<String> externalIDSource
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('External_Id__c')
            .selectField('Business_Vertical__c')
            .selectField('Brand__c')
            .selectField('Brand__r.Name')
            .selectField('Business_Vertical__r.Name')
            .selectField('Business_Vertical__r.Primary_Vertical__c')
            .setCondition(
                'Default_Type__c IN :defaultType  AND External_Id_Source__c IN :externalIDSource  AND External_Id__c IN :businessIDs'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Business reference records by Unique Identifier.
     * @param uniqueIdentifiers
     * @return List<Business_Reference__c>
     */
    public List<Business_Reference__c> selectBusinessReferenceByUniqueIdentifiers(
        Set<String> uniqueIdentifiers
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Unique_Identifier__c')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description LEM-14427, get all the Business Group Ids associated with the account.
     * @param accountId
     * @return list of business references
     */
    public List<Business_Reference__c> selectBGGroupIdByAccountId(Id accountId) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Group_Id__c')
            .selectField('Brand__c')
            .setCondition(
                'Business_Group_Id__c != NULL AND ' +
                'Brand__c  IN (select Brand_Name__c from Brand_Association__c WHERE Business_Account_Name__c =: accountId )'
            );
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description LEM-16079, get all the Business Reference based on BGID and Biz ID.
     * @param externalIdValue
     * @return list of business references
     */
    public List<Business_Reference__c> selectByBizId(String externalIdValue) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Integration_Message__c')
            .selectField('Integration_Status__c')
            .setCondition('External_ID__c =: externalIdValue');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }
    /**
     * @description get Business References by Realted brands Owner Id
     * @param businessAccountIds
     * @return List<Business_Reference__c>
     */
    public List<Business_Reference__c> selectByBrandOwnerId(Set<Id> businessAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Brand_Owner_Segment__c')
            .selectField('Brand_Owner_Vertical__c')
            .selectField('Mastered_In_Figment__c')
            .setCondition('Brand__r.Brand_Owner__c  IN :businessAccountIds');
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Business References with Integration Status as 'Success' by matching businessIds.
     * @JIRA# LEM-15213
     * @param businessIds
     * @return List<Business_Reference__c>
     */
    public List<Business_Reference__c> selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
        Set<String> businessIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('External_Id__c')
            .selectField('Integration_Status__c')
            .setCondition(
                'External_Id_Source__c = :EXTERNAL_ID_SOURCE_MDS AND Integration_Status__c = :INTEGRATION_STATUS_SUCCESS AND External_Id__c IN :businessIds'
            )
            .setOrdering(CREATED_DATE_FIELD, fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description select Business Reference External Id
     * @jira LEM-17697
     * @param businessVerticals
     * @param brands
     * @param currencyCodes
     * @return Business_Reference__c
     **/
    public List<Business_Reference__c> selectByBusinessVerticalBrandCurrencyExternalIdDefaultType(
        Set<String> businessVerticals,
        Set<String> brands,
        Set<String> currencyCodes
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Business_Vertical__c IN : BusinessVerticals AND Brand__c IN : Brands AND ' +
                'CurrencyIsoCode IN : currencyCodes AND External_Id_Source__c =: EXTERNAL_ID_SOURCE_MDS AND Default_Type__c =: DEFAULT_TYPE_CORPORATE'
            )
            .setLimit(1);
        return (List<Business_Reference__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting all business reference information in a given
     * account hierarchy.  Leverages the Xref__c junction object as the base query object
     * in order to query the business references related to a given set of accounts.
     * Using an aggregate query here to reduce the number of records returned.  Its a marginal reduction (only reduces
     * duplicates on the same store) but will take any reduction we can get to optimize the process.
     * @param accountIds An array of Account IDs for which to retrieve business reference information
     * @return Aggregate[] An list of Aggregate records containing associated business reference information
     * for the given account hierarchy
     */
    public Aggregate[] selectAllBusinessIdsInAccountHierarchy(String[] accountIds) {
        return Aggregate.convertResults(
            [
                SELECT
                    Business_Reference__r.Id BusinessReferenceId,
                    Business_Reference__r.External_Id__c BusinessReferenceExternalId,
                    Business_Reference__r.External_Id_Source__c BusinessReferenceExternalIdSource,
                    Business_Reference__r.Business_Name__c BusinessReferenceBusinessName,
                    Business_Reference__r.Business_Vertical__r.Name BusinessReferenceVerticalName,
                    Salesforce_Account_Name__c AccountId,
                    Salesforce_Account_Name__r.ParentId ParentAccountId1,
                    Salesforce_Account_Name__r.Parent.ParentId ParentAccountId2,
                    Salesforce_Account_Name__r.Parent.Parent.ParentId ParentAccountId3,
                    Salesforce_Account_Name__r.Parent.Parent.Parent.ParentId ParentAccountId4,
                    Salesforce_Account_Name__r.Parent.Parent.Parent.Parent.ParentId ParentAccountId5
                FROM Xref__c
                WHERE
                    Business_Reference__r.External_Id__c != NULL
                    AND (Salesforce_Account_Name__c = :accountIds
                    OR Salesforce_Account_Name__r.ParentId = :accountIds
                    OR Salesforce_Account_Name__r.Parent.ParentId = :accountIds
                    OR Salesforce_Account_Name__r.Parent.Parent.ParentId = :accountIds
                    OR Salesforce_Account_Name__r.Parent.Parent.Parent.ParentId = :accountIds
                    OR Salesforce_Account_Name__r.Parent.Parent.Parent.Parent.ParentId = :accountIds)
                GROUP BY
                    Business_Reference__r.Id,
                    Business_Reference__r.External_Id__c,
                    Business_Reference__r.External_Id_Source__c,
                    Business_Reference__r.Business_Name__c,
                    Business_Reference__r.Business_Vertical__r.Name,
                    Salesforce_Account_Name__c,
                    Salesforce_Account_Name__r.ParentId,
                    Salesforce_Account_Name__r.Parent.ParentId,
                    Salesforce_Account_Name__r.Parent.Parent.ParentId,
                    Salesforce_Account_Name__r.Parent.Parent.Parent.ParentId,
                    Salesforce_Account_Name__r.Parent.Parent.Parent.Parent.ParentId

                LIMIT 50000
            ]
        );
    }
}