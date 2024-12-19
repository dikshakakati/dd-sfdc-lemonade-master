/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Brand Object Trigger Handler
 */
public class BrandsHandler extends ApplicationDomainHandler {
    /**
     * @description constructor method
     * @param sObjectList - Brand record list
     */
    public BrandsHandler(List<Brand__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Brand__c.SObjectType, BrandsHandler.class);
    }

    /**
     * @description Called to perform after update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        Brands.newInstance(
                new List<Brand__c>(
                    (List<Brand__c>) getChangedRecords(
                        new Set<SObjectField>{ Brand__c.Brand_Owner__c }
                    )
                )
            )
            .initiateUpdateOnBusinessReferenceOnBrandOwnerChange();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        Brands.newInstance((List<Brand__c>) existing.values())
            .removeOldBrandAssociations(brandWithUpdatedBrandOwner());
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onAfterInsert() {
        Brands.newInstance(this.records).createBrandAssociationsBasedOnBrandOwner();
    }

    /**
     * @description To get changed records
     * @return List<Brand__c>
     */
    private List<Brand__c> brandWithUpdatedBrandOwner() {
        return new List<Brand__c>(
            (List<Brand__c>) getChangedRecords(new Set<SObjectField>{ Brand__c.Brand_Owner__c })
        );
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return BrandsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BrandsHandler(sObjectList);
        }
    }
}