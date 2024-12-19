/**
 * @author Deloitte
 * @date 11/11/2023
 * @description Business Vertical Object Trigger Handler
 */
public class BusinessVerticalsHandler extends ApplicationDomainHandler {

    /**
     * @description Constructor to instantiate List of Business Verticals
     * @param sObjectList - Business Vertical Record List
     */
    public BusinessVerticalsHandler(List<Business_Vertical__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Business_Vertical__c.SobjectType, BusinessVerticalsHandler.class);
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return BusinessVerticalsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BusinessVerticalsHandler(sObjectList);
        }
    }

    //Override to apply defaults to the records, this is called by the handleBeforeInsert method
    public override void onApplyDefaults() {
        IBusinessVerticals businessVerticalsInstance = BusinessVerticals.newInstance(
            (List<Business_Vertical__c>) getRecords()
        );
        businessVerticalsInstance.assignNameOnInsertOrNameUpdate();

    }

    /**
     * @description Called to perform before update processing
     * @param existingRecords - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
      BusinessVerticals.newInstance(businessVerticalsWithUpdatedVerticalIdOrVerticalName()).assignNameOnInsertOrNameUpdate();
    }

    /**
     * @description This method is used to update Business Vertical Name based on changes to
     * Business Vertical Id or Vertical Name field.
     * @return List<Business_Vertical__c>
     */
    private List<Business_Vertical__c> businessVerticalsWithUpdatedVerticalIdOrVerticalName() {
        return new List<Business_Vertical__c>(
            (List<Business_Vertical__c>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Business_Vertical__c.Business_Vertical_ID__c,
                    Business_Vertical__c.Vertical_Name__c,
                    Business_Vertical__c.Name
                }
            )
        );
    }
}