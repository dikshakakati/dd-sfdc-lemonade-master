/**
 * @author ATG
 * @date 10/04/2023
 * @description Brief object Triggerhandler
 */
public class BriefHandler extends ApplicationDomainHandler {
    /**
     * @description constructor method
     * @param sObjectList - Brief record list
     */
    public BriefHandler(List<Brief__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Brief__c.SObjectType, BriefHandler.class);
    }

    /**
     * @description Called to perform after update processing
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Brief__c> updatedBriefs = briefsWithUpdatedFields();
        if(!updatedBriefs.isEmpty()){
            BriefsService.updateOpportunityFromBrief(updatedBriefs);
        }

    }


    /**
     * @description Constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return BriefHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BriefHandler(sObjectList);
        }
    }
    /**
     * @description method to determine if briefs have fields updated that need to sync back to Opp
     * @return List<Brief__c>
     */
    private List<Brief__c> briefsWithUpdatedFields(){
        List<Brief__c> changedBriefs = new List<Brief__c>(
            (List<Brief__c>) getChangedRecords(
                new Set<SObjectField>{
                    Brief__c.Campaign_TLDR__c,
                    Brief__c.Campaign_Program__c,
                    Brief__c.Purchase_Order__c,
                    Brief__c.Campaign_Program_lookup__c
                }
            )
        );
        return changedBriefs;
    }
}