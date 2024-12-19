/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service class for Pricing Programs related logic.
 */
public inherited sharing class PricingProgramsService {
    /**
     * @description It is used to compare pricingprograms with merchant services.
     * @param merchantServices
     * @param pricingPrograms
     * @return Boolean
     */
    public static Boolean getServiceToPricingProgramMapping(
        List<Merchant_Service__c> merchantServices,
        List<ActivationChecklistWrapper.GetPricingPrograms> pricingPrograms
    ) {
        return service().getServiceToPricingProgramMapping(merchantServices, pricingPrograms);
    }

    private static IPricingProgramsService service() {
        return (IPricingProgramsService) Application.SERVICE.newInstance(
            IPricingProgramsService.class
        );
    }
}