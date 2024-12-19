/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Selector Class for Lead Object
 */
public inherited sharing class LeadsSelector extends fflib_SObjectSelector implements ILeadsSelector {
    /**
     * @description default constructor for the Leads Selector class
     * @return ILeadsSelector - interface of ILeadsSelector
     */
    public static ILeadsSelector newInstance() {
        return (ILeadsSelector) Application.Selector.newInstance(Lead.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Brief object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> leadFields = new List<Schema.SObjectField>{
            Lead.Id,
            Lead.Street,
            Lead.Company,
            Lead.Time_Zone_Backend__c,
            Lead.Address,
            Lead.Count_of_Emails_Sent__c,
            Lead.Count_of_Calls_Outbound_Inbound__c,
            Lead.Store_Id__c,
            Lead.SSMO_UUID__c,
            Lead.Business_ID__c,
            Lead.ConvertedAccountId,
            Lead.IsConverted,
            Lead.Inbound_Ingestion_Log__c,
            Lead.Lead_Conversion_Type__c,
            Lead.Unique_Id__c,
            Lead.Phone,
            Lead.MobilePhone,
            Lead.FirstName,
            Lead.LastName,
            Lead.Email,
            Lead.PreferredLanguage__c,
            Lead.Business_Id__c,
            Lead.City,
            Lead.State,
            Lead.Statecode,
            Lead.Country,
            Lead.CountryCode,
            Lead.PostalCode,
            Lead.Address_Verification_Status__c,
            Lead.Rejected_Reason__c,
            Lead.Address_Verification_Date__c,
            Lead.PrimaryVertical__c,
            Lead.Starting_Point__c,
            Lead.Starting_Point_Id__c,
            Lead.Alcohol_Eligibility__c,
            Lead.Order_Protocol_Phone__c,
            Lead.Order_Protocol__c,
            Lead.Order_Protocol_Email__c,
            Lead.Menu_URL__c,
            Lead.HoursOfOperation__c,
            Lead.Provider_Type__c,
            Lead.Coverage__c,
            Lead.Last_Coverage_Check_Time__c,
            Lead.Self_Serve_Step__c,
            Lead.Coverage_Start_Date__c,
            Lead.EmailVerificationStatus__c,
            Lead.Meeting_Set__c,
            Lead.First_Qualified_Activity__c,
            Lead.Submarket__c
        };
        return leadFields;
    }

    /**
     * @description This method is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id.
     * @param idSet
     * @return List<Lead>
     */
    public List<Lead> selectById(Set<Id> idSet) {
        return (List<Lead>) selectSObjectsById(idSet);
    }

    /**
     * @description It is used to get Leads with matching
     * email address, company and address.
     * @JIRA# 13420
     * @param emailAddress
     * @param companyName
     * @return List<Lead>
     */
    public List<Lead> selectLeadsByEmailAndCompany(String emailAddress, String companyName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Email = :emailAddress AND ' + 'Company = :companyName');
        return (List<Lead>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Leads by passed matching unique identifiers.
     * @param uniqueIdentifiers
     * @return List<Lead>
     */
    public List<Lead> selectByUniqueIdentifiers(Set<String> uniqueIdentifiers) {
        fflib_QueryFactory query =  newQueryFactory()
            .selectField('Id')
            .selectField('Inbound_Ingestion_Log__c')
            .selectField('IsConverted')
            .selectField('Lead_Conversion_Type__c')
            .selectField('SSMO_UUID__c')
            .selectField('Unique_Id__c')
            .setCondition('SSMO_UUID__c IN :uniqueIdentifiers');
        return (List<Lead>) Database.query(query.toSOQL());
    }
}