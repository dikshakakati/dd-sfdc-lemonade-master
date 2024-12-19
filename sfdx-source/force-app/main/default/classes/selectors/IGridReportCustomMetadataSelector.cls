/**
 * @author CriticalRiver
 * @date   Sept, 20 2024
 * @description Interface for fetch Grid Report Metadata
 */
public interface IGridReportCustomMetadataSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is to get Report Master record + its children related to the report name
     * @param  reportName String
     * @return DD_Grid_Report_Master__mdt - Report Master record + its children related to the report name
     */
    DD_Grid_Report_Master__mdt getReportDefinition(String reportName);
}