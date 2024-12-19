/**
 * @author Deloitte
 * @date 06/26/2024
 * @description Selector class for OIPackageProductMapping__mdt custom metadata.
 */
public inherited sharing class OIPackageProductMappingsSelector extends fflib_SObjectSelector implements IOIPackageProductMappingsSelector {
    /**
     * @description Default constructor for the class.
     * @return IOIPackageProductMappingsSelector
     */
    public static IOIPackageProductMappingsSelector newInstance() {
        return (IOIPackageProductMappingsSelector) Application.Selector.newInstance(
            OIPackageProductMapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting the object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OIPackageProductMapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields of OIPackageProductMapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OIPackageProductMapping__mdt.DeveloperName,
            OIPackageProductMapping__mdt.MasterLabel,
            OIPackageProductMapping__mdt.Package__c,
            OIPackageProductMapping__mdt.Product_Category__c
        };
    }

    /**
     * @description It is used for getting all package and product mapping for
     * OIPackageProductMapping__mdt.
     * @JIRA# LEM-15355
     * @return List<OIPackageProductMapping__mdt>
     */
    public List<OIPackageProductMapping__mdt> getAllMappings() {
        fflib_QueryFactory query = newQueryFactory();
        return (List<OIPackageProductMapping__mdt>) Database.query(query.toSOQL());
    }
}