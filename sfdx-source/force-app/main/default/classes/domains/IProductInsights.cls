/**
 * @description Interface for Product Insights Domain class
 * @author Deloitte
 */
public interface IProductInsights extends fflib_ISObjects {
    /**
     * @description Method to autopopulate Account Lookup on Insights from Opportunity or Initiative
     */
    void autopopulateAccountOnInsights();

    /**
     * @description This method is used to compare the trigger context records
     *              with the unique combinations of existing records to permit insert
     *              or update of these records
     */
    void compareRecordsForUniqueCombinations();
}