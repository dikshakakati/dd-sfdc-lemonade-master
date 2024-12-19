/**
 * @author Deloitte
 * @date 08/08/2024
 * @description StagingBulkUploadRequest Selector Class.
 */
public inherited sharing class StagingBulkUploadRequestSelector extends fflib_SObjectSelector implements IStagingBulkUploadRequestSelector {

    /**
     * @description default constructor for the StagingBulkUploadRequest Selector class
     * @return IStagingBulkUploadRequestSelector - interface of IStagingBulkUploadRequestSelector
     */
    public static IStagingBulkUploadRequestSelector newInstance() {
        return (IStagingBulkUploadRequestSelector) Application.Selector.newInstance(
            Staging_Bulk_Upload_Request__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on Staging Bulk Upload Request object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Staging_Bulk_Upload_Request__c.Id,
            Staging_Bulk_Upload_Request__c.Business_ID__c,
            Staging_Bulk_Upload_Request__c.Contact_Id__c,
            Staging_Bulk_Upload_Request__c.Address__City__s,
            Staging_Bulk_Upload_Request__c.Address__CountryCode__s,
            Staging_Bulk_Upload_Request__c.Defective_Printer_IMEI__c,
            Staging_Bulk_Upload_Request__c.Defective_Tablet_IMEI__c,
            Staging_Bulk_Upload_Request__c.Menu_Preview_Link__c,
            Staging_Bulk_Upload_Request__c.Menu_URL__c,
            Staging_Bulk_Upload_Request__c.Order_Protocol__c,
            Staging_Bulk_Upload_Request__c.Photoshoot_Date__c,
            Staging_Bulk_Upload_Request__c.Photoshoot_Date_Time__c,
            Staging_Bulk_Upload_Request__c.Photoshoot_Review_Notes_Tags__c,
            Staging_Bulk_Upload_Request__c.Photoshoot_Time__c,
            Staging_Bulk_Upload_Request__c.Address__PostalCode__s,
            Staging_Bulk_Upload_Request__c.Product_Bundle__c,
            Staging_Bulk_Upload_Request__c.Reason_for_Additional_Photoshoot__c,
            Staging_Bulk_Upload_Request__c.Reason_if_Other__c,
            Staging_Bulk_Upload_Request__c.Replacement_Reason__c,
            Staging_Bulk_Upload_Request__c.Replacement_Reason_if_Other__c,
            Staging_Bulk_Upload_Request__c.Request_Type__c,
            Staging_Bulk_Upload_Request__c.Return_Components__c,
            Staging_Bulk_Upload_Request__c.Shipping_Type__c,
            Staging_Bulk_Upload_Request__c.Address__StateCode__s,
            Staging_Bulk_Upload_Request__c.Address__Street__s,
            Staging_Bulk_Upload_Request__c.Store_ID__c,
            Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c,
            Staging_Bulk_Upload_Request__c.Type__c,
            Staging_Bulk_Upload_Request__c.Vendor__c
        };
    }

    /**
     * @description It is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Staging_Bulk_Upload_Request__c.SObjectType;
    }

    /**
     * @description It is used for getting Staging_Bulk_Upload_Request__c records by referenceIds
     * @param referenceIds
     * @return List<Staging_Bulk_Upload_Request__c>
     */
    public Database.QueryLocator selectStagingRequestsByReferenceIds(Set<String> referenceIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_ID__r.Activated_Centrally_AC__c')
            .selectField('Business_ID__r.Menu_to_be_Completed_By__c')
            .selectField('Business_ID__r.Proposed_Date_of_Activation__c')
            .selectField('Store_ID__r.Activated_Centrally_AC__c')
            .selectField('Store_ID__r.Menu_to_be_Completed_By__c')
            .selectField('Store_ID__r.BillingCountryCode')
            .selectField('Store_ID__r.BillingStateCode')
            .selectField('Store_ID__r.Proposed_Date_of_Activation__c')
            .setCondition('Staging_Upload_Ref__c IN :referenceIds');
        return Database.getQueryLocator(query.toSOQL());
    }
}
