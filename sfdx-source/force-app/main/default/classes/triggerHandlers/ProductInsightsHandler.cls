/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Handler Class for Product Insights
 */
public class ProductInsightsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate a List of Product Insights
     * @param sObjectList
     */
    public ProductInsightsHandler(List<Product_Insights__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Product_Insights__c.SObjectType, ProductInsightsHandler.class);
    }

    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return ProductInsightsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ProductInsightsHandler(sObjectList);
        }
    }

    //Override to apply default logic to records. This is invoked by the handleBeforeInsert method
    public override void onApplyDefaults() {
        ProductInsights.newInstance(getProductInsights()).autopopulateAccountOnInsights();
    }

    //Override to perform Before Insert Validations
    public override void onBeforeInsert() {
        ProductInsights.newInstance(getProductInsights()).compareRecordsForUniqueCombinations();
    }

    //description Override to perform After Update processing.
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        LeversService.updateInterestLevel(getProductInsightsWithUpdatedInterestLevel());
    }

    /**
     * @description Before Update Trigger processing
     * @param existingRecords - The map of old Product_Insights__c records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        ProductInsights.newInstance(getProductInsightsWithUpdatedProductRelationships())
            .compareRecordsForUniqueCombinations();
        ProductInsights.newInstance(getProductInsightsWithUpdatedAccountRelationships())
            .autopopulateAccountOnInsights();
    }

    /**
     * @description Fetch All Records present in the Trigger Context
     * @return List<Product_Insights>
     */
    private List<Product_Insights__c> getProductInsights() {
        return (List<Product_Insights__c>) getRecords();
    }

    /**
     * @description This method is used to call the domain method for
     *              checking if the Opportunity-Product and Initiative-
     *              Product combinations are unique for all Insights.
     * @return List<Product_Insights__c>
     */
    private List<Product_Insights__c> getProductInsightsWithUpdatedProductRelationships() {
        return new List<Product_Insights__c>(
            (List<Product_Insights__c>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Product_Insights__c.Product__c,
                    Product_Insights__c.Opportunity__c,
                    Product_Insights__c.Initiative__c
                }
            )
        );
    }

    /**
     * @description This method is used to call the domain method for
     *              autopopulating blank Account_Name__c field on
     *              Product_Insights__c records.
     * @return List<Product_Insights__c>
     */
    private List<Product_Insights__c> getProductInsightsWithUpdatedAccountRelationships() {
        return new List<Product_Insights__c>(
            (List<Product_Insights__c>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Product_Insights__c.Account_Name__c,
                    Product_Insights__c.Opportunity__c,
                    Product_Insights__c.Initiative__c
                }
            )
        );
    }

    /**
     * @description This method is used to get the Product Insight records with updated Interest Level.
     * @return List<Product_Insights__c>
     */
    private List<Product_Insights__c> getProductInsightsWithUpdatedInterestLevel() {
        return new List<Product_Insights__c>(
            (List<Product_Insights__c>) getChangedRecords(
                new Set<Schema.SObjectField>{ Product_Insights__c.Interest_Level__c }
            )
        );
    }
}