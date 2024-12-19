/**
 * @author CriticalRiver
 * @date   Sept, 20 2024
 * @description Class for fetch Grid Report Metadata
*/
//Supressing CRUD validations because we are doing updates to Custom Settings, not the database.
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class GridReportCustomMetadataSelector extends fflib_SObjectSelector implements IGridReportCustomMetadataSelector {
    /**
	* @description default constructor for the Grid Report Metadata seleector
	* @return  - interface of IGridReportCustomMetadataSelector
	*/
	public static IGridReportCustomMetadataSelector newInstance() {
		return (IGridReportCustomMetadataSelector) Application.Selector.newInstance(DD_Grid_Report_Master__mdt.SObjectType);
	}

	/**
	* @description This method is for getting the fields on this object
	* @return List of Schema.SObjectField
	*/
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>{
				DD_Grid_Report_Master__mdt.Id
		};
	}

	/**
	* @description This method is used for getting Object type
	* @return Schema.SObjectType
	*/
	public Schema.SObjectType getSObjectType() {
		return DD_Grid_Report_Master__mdt.SObjectType;
	}

	/**
	 * @description This method is to get Report Master record + its children related to the report name
	 * @param reportName String
	 * @return DD_Grid_Report_Master__mdt - Report Master record + its children related to the report name
	 */
	public DD_Grid_Report_Master__mdt getReportDefinition(String reportName) {
		List<DD_Grid_Report_Master__mdt> reports =
			[SELECT Id, Label, Apex_Class__c, DeveloperName,
				(SELECT Id,
						DeveloperName,
						Type__c,
						MultiSelect_Ref__c,
						MultiSelect_Ref__r.DeveloperName,
						MultiSelect_Ref__r.Field_Label__c,
						Query_Field_API_Names__c,
						Label__c,
						Sequence__c,
						isExpanded__c,
						Toggle_Default__c,
						MultiSelect_Query_Operator__c,
						Toggle_Filter_Required__c,
						Number_Date_Has_IS_BLANK_IS_NOT_BLANK__c
					FROM DD_Grid_Report_Filters__r
					WHERE isActive__c = true
				ORDER BY Sequence__c asc),
				(SELECT Id,
						API_Name__c,
						Cell_Attributes_JSON__c,
						Default_Sort__c,
						Default_Sort_Direction__c,
						Field_Name__c,
						Initial_Width__c,
						isActive__c,
						Label__c,
						Sequence__c,
						Sortable__c,
						Type__c,
						Type_Attributes_JSON__c,
						Sort_Nulls_Config__c
					FROM DD_Grid_Report_Fields__r
					WHERE isActive__c = true
				ORDER BY Sequence__c asc)
			 FROM DD_Grid_Report_Master__mdt
			WHERE DeveloperName = :reportName];
		return reports.isEmpty() ? null : reports[0];
	}
}