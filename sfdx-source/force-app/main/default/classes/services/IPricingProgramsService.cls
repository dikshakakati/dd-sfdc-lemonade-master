/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface to add PricingProgramsService class methods.
 */
public interface IPricingProgramsService {
    /**
     * @description It is used to compare pricingprograms with merchant services.
     * @param merchantServices
     * @param pricingPrograms
     * @return Boolean
     */
    Boolean getServiceToPricingProgramMapping(
        List<Merchant_Service__c> merchantServices,
        List<ActivationChecklistWrapper.GetPricingPrograms> pricingPrograms
    );
}