/**
 * @author CriticlRiver
 * @date Sept 2024
 * @description Test class for the GridReportCustomMetadataSelector
 */

@isTest
public without sharing class GridReportCustomMetadataSelectorTest {

    @IsTest
    static void testWhenGetDDGridReportSavedSearchThenForReportByUser(){
        DD_Grid_Report_Master__mdt master = GridReportCustomMetadataSelector.newInstance().getReportDefinition('Figment_Support_Report');
        Assert.isNotNull(master, 'There Should be some custom metadat');
        Assert.areEqual('Figment_Support_Report', master.DeveloperName ,'Report Should Exist with same name');

        GridReportCustomMetadataSelector incCodeCoverage = new GridReportCustomMetadataSelector();
        incCodeCoverage.getSObjectFieldList();
        incCodeCoverage.getSObjectType();
    }
}