/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Service class for Levers related logic.
 **/
public inherited sharing class LeversService {
    /**
     * @description Update interest level on Levers.
     * @param productInsights
     */
    public static void updateInterestLevel(List<Product_Insights__c> productInsights) {
        service().updateInterestLevel(productInsights);
    }

    /**
     * @description - It creates instance of LeversServiceImpl class.
     * @return ILeversService
     */
    private static ILeversService service() {
        return (ILeversService) Application.SERVICE.newInstance(ILeversService.class);
    }
}