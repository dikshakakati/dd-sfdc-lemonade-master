/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Interface for Levers Service.
 **/
public interface ILeversService {
    /**
     * @description Update interest level on Levers.
     * @param productInsights
     */
    void updateInterestLevel(List<Product_Insights__c> productInsights);
}