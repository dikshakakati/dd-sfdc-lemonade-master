/**
 * @description This is a generic class created to validate phone number.
 * @author Deloitte
 * @date 19/04/2022
 */
public inherited sharing class PhoneValidation {
    /**
     * @description validates phone numbers
     * @param record
     * @param fieldName
     * @param countryToCountryAttributes
     * @param phoneCodesToCountryAttributes
     * @param billingCountryCode
     * @return String
     */
    public static String validationOnPhoneFields(
        SObject record,
        Schema.SObjectField fieldName,
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        String billingCountryCode
    ) {
        return service().validationOnPhoneFields(
            record,
            fieldName,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            billingCountryCode
        );
    }

    /**
     * @description calling newInstance for service class.
     * @return IPhoneValidation - returning interface.
     */
    private static IPhoneValidation service() {
        return (IPhoneValidation) Application.SERVICE.newInstance(IPhoneValidation.class);
    }
}