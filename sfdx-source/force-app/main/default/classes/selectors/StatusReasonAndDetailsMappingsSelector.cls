/**
 * @author Deloitte
 * @date 10/13/2023
 * @description Selector class for Status_Reason_And_Details_Mapping__mdt custom metadata.
 */
public inherited sharing class StatusReasonAndDetailsMappingsSelector extends fflib_SObjectSelector implements IStatusReasonAndDetailsMappingsSelector {
    /**
     * @description Default constructor for the class.
     * @return IStatusReasonAndDetailsMappingsSelector
     */
    public static IStatusReasonAndDetailsMappingsSelector newInstance() {
        return (IStatusReasonAndDetailsMappingsSelector) Application.Selector.newInstance(
            Status_Reason_And_Details_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting the object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Status_Reason_And_Details_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields of Status_Reason_And_Details_Mapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
            Status_Reason_And_Details_Mapping__mdt.MasterLabel,
            Status_Reason_And_Details_Mapping__mdt.DeveloperName,
            Status_Reason_And_Details_Mapping__mdt.Status__c,
            Status_Reason_And_Details_Mapping__mdt.Status_Reason__c,
            Status_Reason_And_Details_Mapping__mdt.Type__c,
            Status_Reason_And_Details_Mapping__mdt.Quick_Action_Name__c
        };
    }

    /**
     * @description It is used for getting all records and associated Business Friendly Mapping's
     * details for Status_Reason_And_Details_Mapping__mdt.
     * @JIRA# LEM-9964
     * @return List<Status_Reason_And_Details_Mapping__mdt>
     */
    public List<Status_Reason_And_Details_Mapping__mdt> getAllMappings() {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Friendly_Mapping__r.Message_Category__c')
            .selectField('Business_Friendly_Mapping__r.Business_Friendly_Message__c');
        return (List<Status_Reason_And_Details_Mapping__mdt>) Database.query(query.toSOQL());
    }
}