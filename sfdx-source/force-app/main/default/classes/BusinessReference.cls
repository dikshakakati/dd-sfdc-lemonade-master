/**
 * @description An Apex Defined Type to represent the Business_Reference__c object
 * Use cases include returning Business_Reference__c records to a flow where we're creating records
 * from aggregate results.
 * Suppressing the property naming convention PMD rule so the Apex Defined Type can mirror the
 * same property look/feel as a standard SObject record since that's what it is reflecting. (SObject properties
 * start with capital letters)
 * Suppressing the EmptyStatementBlock PMD rule since Salesforce requires a no property constructor for Apex Defined
 * Types.
 */
@SuppressWarnings('PMD.PropertyNamingConventions, PMD.EmptyStatementBlock')
public class BusinessReference {
    /**
     * @description Business_Reference__c.Id
     */
    @AuraEnabled public String Id {get; set;}

    /**
     * @description Business_Reference__c.External_Id__c
     */
    @AuraEnabled public String ExternalId {get; set;}

    /**
     * @description Business_Reference__c.External_Id_Source__c
     */
    @AuraEnabled public String ExternalIdSource {get; set;}

    /**
     * @description Business_Reference__c.Business_Name__c
     */
    @AuraEnabled public String BusinessName {get; set;}

    /**
     * @description Business_Reference__c.Business_Vertical_Name__c
     */
    @AuraEnabled public String BusinessVerticalName {get; set;}

    /**
     * @description Constructor
     * Required by Salesforce for Apex Defined Types.
     * Trips the PMD EmtpyStatementBlock rule, so requires a rule suppression
     */
    public BusinessReference() {}

    /**
     * @description Constructor
     * @param record Source Business_Reference__c record
     */
    public BusinessReference(Business_Reference__c record) {
        this.Id = record?.Id;
        this.ExternalId = record?.External_Id__c;
        this.ExternalIdSource = record?.External_Id_Source__c;
        this.BusinessName = record?.Business_Name__c;
        this.BusinessVerticalName = record?.Business_Vertical_Name__c;
    }
}
