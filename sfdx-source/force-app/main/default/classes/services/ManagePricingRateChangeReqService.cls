/**
 * @author Deloitte
 * @date 19/08/2023
 * @description Service class for ManagePricingController related logic.
 */
public inherited sharing class ManagePricingRateChangeReqService {
    /**
     * @description Creates a Rate change request and Subscription rate change records
     * @param managePricingWrapper
     * @return Id
     */
    public static Id createRateChangeRequest(ManagePricingWrapper managePricingWrapper) {
        return service().createRateChangeRequest(managePricingWrapper);
    }

    /**
     * @description It creates instance of ManagePricingRateChangeReqServiceImpl class.
     * @return ManagePricingRateChangeReqServiceImpl - instance of ManagePricingRateChangeReqServiceImpl
     */
    private static IManagePricingRateChangeReqService service() {
        return (IManagePricingRateChangeReqService) Application.Service.newInstance(
            IManagePricingRateChangeReqService.class
        );
    }
}