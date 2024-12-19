/**
 * @author CriticalRiver
 * @date Sep 2024
 * @description Wrapper for Grid Report Filters. Depending on the type (definition.Type__c), value can be Boolean/Array of various other wrappers (multiselect / date / number)
 */
public without sharing class GridReportFilterWrapper {
	/**
     * @description Get and set the report Name
     * @return String : String value of Report
     */
	public String name {get;set;}

	/**
     * @description Get and set the report Name
     * @return DD_Grid_Report_Filter__mdt : Custom Metadta Report
     */
	public DD_Grid_Report_Filter__mdt definition {get;set;}

	/**
     * @description Get and set the report Name
     * @return Object : Object value of Report
     */
	public Object value {get;set;}
}