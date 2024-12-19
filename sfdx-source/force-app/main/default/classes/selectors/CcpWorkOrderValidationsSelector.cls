/**
 * @author Deloitte
 * @date 31/01/2024
 * @description Selector class for CCP_Workorder_Validation__mdt custom metadata.
 */
public inherited sharing class CcpWorkOrderValidationsSelector extends fflib_SObjectSelector implements ICcpWorkOrderValidationsSelector {
    /**
     * @description Default constructor for the CcpWorkOrderValidationsSelector class.
     * @return ICcpWorkOrderValidationsSelector - interface of ICcpWorkOrderValidationsSelector
     */
    public static ICcpWorkOrderValidationsSelector newInstance() {
        return (ICcpWorkOrderValidationsSelector) Application.Selector.newInstance(
            CCP_Workorder_Validation__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting CCP_Workorder_Validation__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CCP_Workorder_Validation__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on CCP_Workorder_Validation__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CCP_Workorder_Validation__mdt.Name__c,
            CCP_Workorder_Validation__mdt.isBusinessAccount__c,
            CCP_Workorder_Validation__mdt.isDrivePackage__c,
            CCP_Workorder_Validation__mdt.isProcessingExistingAccounts__c,
            CCP_Workorder_Validation__mdt.Package_Name__c,
            CCP_Workorder_Validation__mdt.Work_Order_Type__c,
            CCP_Workorder_Validation__mdt.Work_Order_SubType__c
        };
    }

    /**
     * @description It is used for getting all active CCP_Workorder_Validation__mdt records
     * having service class and method name fields populated.
     * @return List<CCP_Workorder_Validation__mdt>
     */
    public List<CCP_Workorder_Validation__mdt> selectAllWorkOrderValidationRules() {
        fflib_QueryFactory query = newQueryFactory();
        return (List<CCP_Workorder_Validation__mdt>) Database.query(query.toSOQL());
    }
}