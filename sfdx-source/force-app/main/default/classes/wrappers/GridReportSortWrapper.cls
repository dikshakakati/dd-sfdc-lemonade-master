/**
 * @author: CriticalRiver
 * @date : Sep 2024
 * @description Wrapper for Grid Report Sort Info.
 */
public class GridReportSortWrapper {
 	/**
     * @description Return Sort Order
     * @return String : sort order for the field
     */
    @AuraEnabled public String sortedBy {get;set;}

    /**
     * @description Return sort Direction
     * @return String : Sort Direction of the field
     */
    @AuraEnabled public String sortDirection {get;set;}

    /**
     * @description return sort nulss
     * @return String
     */
    @AuraEnabled public String sortNulls {get;set;}
}