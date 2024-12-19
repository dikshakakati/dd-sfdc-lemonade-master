/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Interface to add Brand domain class methods
 */
public interface IBrands extends fflib_ISObjects {
    /**
     * @description This method used to create brand Association records based on Brand owner.
     */
    void createBrandAssociationsBasedOnBrandOwner();

    /**
     * @description This method used to remove old brand Association records based on Brand owner.
     * @param updatedBrands
     */
    void removeOldBrandAssociations(List<Brand__c> updatedBrands);

    /**
     * @description It is used to create Brand and Brand Association records for SMB Accounts.
     * @param accountIdsFromConvertedLeads
     */
    void createBrandAndBrandAssociation(Set<Id> accountIdsFromConvertedLeads);

    /**
     * @description It updates Mastered In Figment on Business Reference when Brand Owner is updated on Brand.
     */
    void initiateUpdateOnBusinessReferenceOnBrandOwnerChange();
}