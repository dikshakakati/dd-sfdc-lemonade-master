/**
 * @author Venkatesh Rimmalapudi (Git: VenkateshDD)
 * @date 03/07/2024
 * @description Service Implementation of Opportunity_Brand_Relationship related logic
 */
public inherited sharing class OpportunityBrandRelationshipsServiceImpl implements IOpportunityBrandRelationshipsService{
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';
    private static final String SERVICE_CREATE_OPPORTUNITY_BRAND_RELATION = 'Brand And BizRef Automation - createOpportunityBrandRelationShip';
    private static final String SERVICE_CREATE_OPPORTUNITY_BRAND_RELATIONS = 'Brand And BizRef Automation - createOpportunityBrandRelationShips';



    /**
     * @description Creates a new Opportunity_Brand_Relationship__c record and associates it with the specified Opportunity and Brand.
     * @param opportunityId The Id of the Opportunity to associate with the new record.
     * @param brandAsscId The Id of the Brand to associate with the new record.
     * @return The newly created Opportunity_Brand_Relationship__c record.
     */
    public static Opportunity_Brand_Relationship__c createOpportunityBrandRelationShip(Id opportunityId, Id brandAsscId){
        try {

            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            Opportunity_Brand_Relationship__c obr = (new
            		Opportunity_Brand_Relationship__c(
                			Brand__c= brandAsscId,
                          	Opportunity__c = opportunityId)
            );

            uow.registerNew(obr);
            uow.commitWork();
            return obr;

        } catch (Exception createOpportunityBrandRelationShipException) {
            GenericLoggerService.publish( GenericLoggerService.createGenericLog(SERVICE_CREATE_OPPORTUNITY_BRAND_RELATION,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException(createOpportunityBrandRelationShipException));

        }
        return NULL;
    }

    /**
     * @description Creates Opportunity Brand Relationships for a given Opportunity and a set of Brand Association IDs.
     * @param opportunityId The ID of the Opportunity for which the Brand Relationships are to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Opportunity.
     * @return A list of Opportunity_Brand_Relationship__c records representing the created relationships.
     */
    public static List<Opportunity_Brand_Relationship__c> createOpportunityBrandRelationShips(Id opportunityId, Set<Id> brandAsscIds){
        try {

            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            List<Opportunity_Brand_Relationship__c> obrs = new List<Opportunity_Brand_Relationship__c>();
            for(Id brandAsscId : brandAsscIds){
                obrs.add(new
                   	Opportunity_Brand_Relationship__c(
                    	Brand__c= brandAsscId,
                    	Opportunity__c = opportunityId)
                  	);
            }
            uow.registerNew(obrs);
            uow.commitWork();
            return obrs;

        } catch (Exception createOpportunityBrandRelationShipsException) {
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(SERVICE_CREATE_OPPORTUNITY_BRAND_RELATIONS, LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException(createOpportunityBrandRelationShipsException));
        }
        return NULL;
    }

}