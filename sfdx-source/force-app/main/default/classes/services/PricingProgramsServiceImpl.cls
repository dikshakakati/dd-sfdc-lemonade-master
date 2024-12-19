/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service Implementation to map pricing programs to merchant services.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public inherited sharing class PricingProgramsServiceImpl implements IPricingProgramsService {
    private static final String DASHPASS_PRODUCT = 'DASHPASS';
    private static final String EXPERIENCE_CAVIAR = 'CAVIAR';
    private static final String SUBSCRIBER_AUDIENCE = 'SUBSCRIBER';
    private static final String COMMISSION_FEE_TYPE = 'COMMISSION';
    private static final String FEE_TYPE = 'FEE';
    private static final String UNDERSCORE = '_';
    private static final String YES_ACTIVE = 'Yes';
    private static final String MARKETPLACE_BUNDLE = 'Marketplace';
    /**
     * @description It is used to compare pricingprograms with merchant services.
     * @param merchantServices
     * @param pricingPrograms
     * @return Boolean
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public Boolean getServiceToPricingProgramMapping(
        List<Merchant_Service__c> merchantServices,
        List<ActivationChecklistWrapper.GetPricingPrograms> pricingPrograms
    ) {
        Map<String, Double> pricingProductToValue = new Map<String, Double>();
        String product = '';
        String key = '';
        String feeType = '';
        Double pricingInformation = 0.0;
        for (ActivationChecklistWrapper.GetPricingPrograms eachPricingProgram : pricingPrograms) {
            if (
                !eachPricingProgram.isActive ||
                eachPricingProgram?.productInformation?.experience == EXPERIENCE_CAVIAR
            ) {
                continue;
            }
            product = eachPricingProgram?.productInformation?.audience == SUBSCRIBER_AUDIENCE
                ? DASHPASS_PRODUCT
                : eachPricingProgram?.productInformation?.fulfillmentType;
            for (
                ActivationChecklistWrapper.FeeAttributes eachFeeAttribute : eachPricingProgram.pricingInformation.feeAttributesInformation
            ) {
                if (eachFeeAttribute.feeType == COMMISSION_FEE_TYPE) {
                    pricingInformation = (Double) eachFeeAttribute.feeRate;
                    key = product + UNDERSCORE + eachFeeAttribute.feeType;
                } else {
                    pricingInformation = (Double) eachFeeAttribute.flatFee;
                    key = product + UNDERSCORE + FEE_TYPE;
                }
                pricingProductToValue.put(key, pricingInformation);
                pricingInformation = 0.0;
                key = '';
            }
        }

        for (Merchant_Service__c eachService : merchantServices) {
            if (
                eachService.Active__c == YES_ACTIVE &&
                eachService.Bundle__c == MARKETPLACE_BUNDLE &&
                String.isNotBlank(eachService.Order_Product__r.Fee_Type__c)
            ) {
                feeType = eachService.Order_Product__r.Fee_Type__c.toUpperCase();
                key = eachService.Name.toUpperCase() + UNDERSCORE + feeType.toUpperCase();
                if (pricingProductToValue.containsKey(key)) {
                    switch on feeType {
                        when 'COMMISSION' {
                            if (eachService.Final_Commission__c != pricingProductToValue.get(key)) {
                                return false;
                            }
                        }
                        when 'FEE' {
                            if (eachService.Final_Fee__c != pricingProductToValue.get(key)) {
                                return false;
                            }
                        }
                    }
                }
                feeType = '';
                key = '';
            }
        }
        return true;
    }
}
