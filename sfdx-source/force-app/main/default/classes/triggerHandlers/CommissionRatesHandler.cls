/**
 * @author Deloitte
 * @date 24/04/2024
 * @description Commission_Rate__c Object Trigger Handler.
 */
public with sharing class CommissionRatesHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method for CommissionRatesHandler class
     * @param sObjects - Commission_Rate__c Records List 
     */
    public CommissionRatesHandler(List <Commission_Rate__c> sObjects) {
        super(sObjects);
        setContextBypass(Commission_Rate__c.SObjectType, CommissionRatesHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - List of SObjects
         * @return CommissionRatesHandler
         */
        public fflib_SObjectDomain construct(List <SObject> sObjects) {
            return new CommissionRatesHandler(sObjects);
        }
    }
    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        CommissionRates.newInstance(this.records).generateSearchKey();
    }
    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map <Id,SObject> existing) {
        CommissionRates.newInstance(this.records).generateSearchKey();
    }

}