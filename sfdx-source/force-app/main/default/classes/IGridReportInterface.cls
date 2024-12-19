/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description Interface to implement to send data to the UI
 */
public interface IGridReportInterface extends fflib_ISObjects {

    /**
     * @description  Gets upto 50K records which match the query
     * @param filterList - JSON of filters
     * @param sortConfig - Sort Field and Sort Direction
     * @return  GridReportHelper.GridReportRecordIdWrapper Wrapper of list of Ids the UI can store and use lazy loading to render
     */
    GridReportHelper.GridReportRecordIdWrapper getRecordIds(List<GridReportFilterWrapper> filterList,GridReportSortWrapper sortConfig);

    /**
     * @description  Gets the data for the recordIds
     * @param recordIds - List of ids for which data needs to be retrieved
     * @return String data - JSON form of the data to be returned
     */
    String getData(List<Id> recordIds);
}