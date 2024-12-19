/**
 * @author CriticalRiver
 * @date Sep 2024
 * @description Helper methods for the Grid Report Logic - supports parsing various filters to formulate where clause.
 */
public without sharing class GridReportHelper {

    /**
	* @author: Sanidhya Jain
	* @date : Sep 2024
	* @description Wrapper which returns record Ids back to the UI. Send total count back to the UI (via a select count query)
	*               so that UI can show that not all records were returned in case of limits issue
	*/
	public class GridReportRecordIdWrapper {
		/**
		 * @description Number of record
		 * @return Integer : Count of records
		 */
		@AuraEnabled public Integer count {get;set;}

		/**
		 * @description List of Record Id's to fetch
		 * @return List<Id> : Record Id's
		 */
		@AuraEnabled public List<Id> recordIds {get;set;}
		private List<SObject> data;

		/**
		* @author: Sanidhya Jain
		* @date : Sep 2024
		* @description GridReportRecordIdWrapper set the value with genric controller
		*/
		public GridReportRecordIdWrapper() {
			this.count = 0;
			this.recordIds = new List<Id>();
		}

		/**
		* @author: Sanidhya Jain
		* @date : Sep 2024
		* @description Set the values with the custom controller
		* @param count Integer round of Record
		* @param data Data of the selected records
		*/
		public GridReportRecordIdWrapper(Integer count,List<SObject> data) {
			this.count = count;
			this.data = data;

			this.recordIds = new List<Id>();
			for (SObject obj : this.data) {
				this.recordIds.add((Id)obj.get('Id'));
			}
		}
	}
	/*****************************************************************************************************************************
	 *
	 * Constants Variables
	 *
	 *****************************************************************************************************************************/
	public static final String EQUALS = 'Equals';
	public static final String DOES_NOT_EQUAL = 'Does Not Equal';
	public static final String IS_NULL = ' = null ';
	public static final String IS_NOT_NULL = ' != null ';
	public static final String QUERY_IN = 'In';
	public static final String QUERY_AND = ' AND ';
	public static final String QUERY_OR = ' OR ';
	public static final String OPEN_PARENTHESIS = ' ( ';
	public static final String CLOSE_PARENTHESIS = ' ) ';

	public static final String OP_EQUALS = '=';
	public static final String OP_GREATER_OR_EQUALS = '>=';
	public static final String OP_LESS_OR_EQUALS = '<=';
	public static final String OP_GREATER = '>';
	public static final String OP_LESS = '<';
	public static final String OP_BETWEEN = 'BETWEEN';
	public static final String OP_IS_BLANK = 'IS BLANK';
	public static final String OP_IS_NOT_BLANK = 'IS NOT BLANK';

	public static final String OP_EQUALS_SPACE = ' = ';
	public static final String OP_GREATER_OR_EQUALS_SPACE = ' >= ';
	public static final String OP_LESS_OR_EQUALS_SPACE = ' <= ';
	public static final String OP_GREATER_SPACE = ' > ';
	public static final String OP_LESS_SPACE = ' < ';

	public static final String QUERY_ORDER_BY = ' ORDER BY ';
	public static final String ORDER_ASCENDING = ' asc ';
	public static final String ORDER_DESCENDING = ' desc ';
	public static final String QUERY_LIMIT = ' LIMIT ';
	public static final String QUERY_LIMIT_50K = ' LIMIT 50000';

	private static final String DATE_FORMATTER = 'yyyy-MM-dd';
}