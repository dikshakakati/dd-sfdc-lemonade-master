/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Domain Class for Product Insights
 */
public inherited sharing class ProductInsights extends fflib_SObjects implements IProductInsights {
    static final String OPPORTUNITY_STRING = 'Opportunity';
    static final String INITIATIVE_STRING = 'Initiative';
    static final String LOG_DOMAIN = 'Sales';
    static final String LOG_INTEREST_LEVEL_UPDATE = 'Error in updating the Interest Level';

    /**
     * @description This method is used to return the IProductInsights Interface
     * @param recordList - Product Insights Record List
     * @return IProductInsights - Returns IProductInsights Interface
     */
    public static IProductInsights newInstance(List<Product_Insights__c> recordList) {
        return (IProductInsights) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default Constructor for the class
     * @param sObjectList
     */
    public ProductInsights(List<Product_Insights__c> sObjectList) {
        super(sObjectList, Schema.Product_Insights__c.SObjectType);
    }

    /**
     * @description Holds the mock instance of the constructor inner class
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private Method that allows the domain constructor mock to be set by the test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return ProductInsights - List of Product_Insights__c
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (ProductInsights.constructorMock != null) {
                return (fflib_SObjects) ProductInsights.constructorMock.construct(objectList);
            }
            return new ProductInsights((List<SObject>) objectList);
        }
    }

    /**
     * @description Method to autopopulate Account Lookup on Insights from Opportunity or Initiative
     */
    public void autopopulateAccountOnInsights() {
        Map<Id, Opportunity> parentOpportunities = fetchParentOpportunities();
        Map<Id, Initiative__c> parentInitiatives = fetchParentInitiative();
        for (
            Product_Insights__c insight : (List<Product_Insights__c>) getRecordsWithBlankFieldValues(
                new Set<Schema.SObjectField>{ Product_Insights__c.Account_Name__c }
            )
        ) {
            if (insight.Opportunity__c != null) {
                insight.Account_Name__c = parentOpportunities.get(insight.Opportunity__c).AccountId;
            } else if (insight.Initiative__c != null) {
                insight.Account_Name__c = parentInitiatives.get(insight.Initiative__c).Account__c;
            }
        }
    }

    /**
     * @description Query using InitiativeSelector for all Initiatives that are parents
     *              to Product_Insights__c records under consideration
     * @return Map<Id, Initiative__c>
     */
    public Map<Id, Initiative__c> fetchParentInitiative() {
        return new Map<Id, Initiative__c>(
            InitiativesSelector.newInstance()
                .selectByInsights(
                    (List<Product_Insights__c>) getRecordsWithNotBlankFieldValues(
                        new Set<Schema.SObjectField>{ Product_Insights__c.Initiative__c }
                    )
                )
        );
    }

    /**
     * @description Query using OpportunitySelector for all Opportunities that are parents
     *              to Product_Insights__c records under consideration
     * @return Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> fetchParentOpportunities() {
        return new Map<Id, Opportunity>(
            OpportunitiesSelector.newInstance()
                .selectByInsights(
                    (List<Product_Insights__c>) getRecordsWithNotBlankFieldValues(
                        new Set<Schema.SObjectField>{ Product_Insights__c.Opportunity__c }
                    )
                )
        );
    }

    /**
     * @description This method is used to compare the trigger context records
     *              with the unique combinations of existing records to permit insert
     *              or update of these records
     */
    public void compareRecordsForUniqueCombinations() {
        Map<String, String> uniqueCombinations = fetchAllUniqueCombinations();

        for (
            Product_Insights__c eachInsight : (List<Product_Insights__c>) getRecordsWithNotBlankFieldValues(
                new Set<Schema.SObjectField>{ Product_Insights__c.Product__c }
            )
        ) {
            if (eachInsight.Opportunity__c != null && eachInsight.Product__c != null) {
                uniqueCombinations.remove(eachInsight.Id + OPPORTUNITY_STRING);
                String opportunityProductCombination =
                    eachInsight.Opportunity__c +
                    '-' +
                    eachInsight.Product__c;
                if (uniqueCombinations.values().contains(opportunityProductCombination)) {
                    eachInsight.addError(
                        System.Label.Product_Insight_Not_Unique_On_Opportunity_Error
                    );
                }
                uniqueCombinations.put(
                    eachInsight.Id + OPPORTUNITY_STRING,
                    opportunityProductCombination
                );
            }

            if (eachInsight.Initiative__c != null && eachInsight.Product__c != null) {
                uniqueCombinations.remove(eachInsight.Id + INITIATIVE_STRING);
                String initiativeProductCombination =
                    eachInsight.Initiative__c +
                    '-' +
                    eachInsight.Product__c;
                if (uniqueCombinations.values().contains(initiativeProductCombination)) {
                    eachInsight.addError(
                        System.Label.Product_Insight_Not_Unique_On_Initiative_Error
                    );
                }
                uniqueCombinations.put(
                    eachInsight.Id + INITIATIVE_STRING,
                    initiativeProductCombination
                );
            }
        }
    }

    /**
     * @description Query using ProductInsightsSelector for all Product Insight records
     *              present in the system and prepare a set that would hold a combination
     *              of Opportunity-Product and Initiative-Product on the Insight
     * @return Set<String>
     */
    private Map<String, String> fetchAllUniqueCombinations() {
        //Set<String> uniqueCombinations = new Set<String>();
        Map<String, String> uniqueCombinations = new Map<String, String>();

        //Query using the ProductInsightsSelector
        List<Product_Insights__c> allInsights = ProductInsightsSelector.newInstance()
            .selectAllInsightsWithLookups(fetchAllLookupIdsFromUpdatedRecords());

        if (allInsights != null) {
            for (Product_Insights__c eachInsight : allInsights) {
                if (eachInsight.Opportunity__c != null && eachInsight.Product__c != null) {
                    uniqueCombinations.put(
                        eachInsight.Id + OPPORTUNITY_STRING,
                        eachInsight.Opportunity__c + '-' + eachInsight.Product__c
                    );
                }
                if (eachInsight.Initiative__c != null && eachInsight.Product__c != null) {
                    uniqueCombinations.put(
                        eachInsight.Id + INITIATIVE_STRING,
                        eachInsight.Initiative__c + '-' + eachInsight.Product__c
                    );
                }
            }
        }
        return uniqueCombinations;
    }

    /**
     * @description Return a list of Lookup Ids of Product Insights
     * @return Set<Id>
     */
    private Set<Id> fetchAllLookupIdsFromUpdatedRecords() {
        Set<Id> allLookupIds = new Set<Id>();

        for (
            Product_Insights__c insight : (List<Product_Insights__c>) getRecordsWithNotBlankFieldValues(
                new Set<Schema.SObjectField>{ Product_Insights__c.Product__c }
            )
        ) {
            allLookupIds.add(insight.Product__c);
            if (insight.Opportunity__c != null) {
                allLookupIds.add(insight.Opportunity__c);
            }
            if (insight.Initiative__c != null) {
                allLookupIds.add(insight.Initiative__c);
            }
        }

        return allLookupIds;
    }
}