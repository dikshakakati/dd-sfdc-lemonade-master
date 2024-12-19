/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Selector class for Opportunity_Status_PDOA_Mapping__mdt custom metadata.
 */
public inherited sharing class OpportunityStatusPDOAMappingsSelector extends fflib_SObjectSelector implements IOpportunityStatusPDOAMappingsSelector {
    /**
     * @description Default constructor for OpportunityStatusPDOAMappingsSelector class.
     * @return IOpportunityStatusPDOAMappingsSelector
     */
    public static IOpportunityStatusPDOAMappingsSelector newInstance() {
        return (IOpportunityStatusPDOAMappingsSelector) Application.Selector.newInstance(
            Opportunity_Status_PDOA_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Opportunity_Status_PDOA_Mapping__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Status_PDOA_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Opportunity_Status_PDOA_Mapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c,
            Opportunity_Status_PDOA_Mapping__mdt.Field_To_Refer__c,
            Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
            Opportunity_Status_PDOA_Mapping__mdt.Object_To_Refer__c,
            Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
            Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Compare__c,
            Opportunity_Status_PDOA_Mapping__mdt.Operator__c,
            Opportunity_Status_PDOA_Mapping__mdt.Opportunity_Status__c,
            Opportunity_Status_PDOA_Mapping__mdt.Order_Number__c,
            Opportunity_Status_PDOA_Mapping__mdt.Override_Offset_To_Apply__c,
            Opportunity_Status_PDOA_Mapping__mdt.Sub_Type_To_Override__c,
            Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply__c,
            Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply_Type__c,
            Opportunity_Status_PDOA_Mapping__mdt.Value_To_Compare__c
        };
    }

    /**
     * @description It is used to fetch all "Opportunity Status to PDOA Mappings"
     * custom metadata records for the passed Nintex Use Case mapping developer names.
     * @param nintexUseCaseDeveloperNames
     * @return List<Opportunity_Status_PDOA_Mapping__mdt>
     */
    public List<Opportunity_Status_PDOA_Mapping__mdt> selectByNintexUseCaseMappings(
        Set<String> nintexUseCaseDeveloperNames
    ) {
        fflib_QueryFactory opportunityStatusToPDOAMappings = newQueryFactory()
            .selectField('Nintex_Mapping__r.DeveloperName')
            .selectField('Nintex_Mapping__r.Nintex_Use_Case__c')
            .setCondition(
                'Nintex_Mapping__c != null AND' +
                ' Nintex_Mapping__r.DeveloperName IN :nintexUseCaseDeveloperNames'
            )
            .setOrdering('Order_Number__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Opportunity_Status_PDOA_Mapping__mdt>) Database.query(
            opportunityStatusToPDOAMappings.toSOQL()
        );
    }
}