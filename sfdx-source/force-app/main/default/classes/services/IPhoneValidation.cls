/**
 * @description : Interface to add reusable methods.
 * @author Deloitte
 * @date 19/04/2022
 */
public interface IPhoneValidation {
    /**
     * @description validates phone numbers
     * @param record
     * @param fieldName
     * @param countryToCountryAttributes
     * @param phoneCodesToCountryAttributes
     * @param billingCountryCode
     * @return String
     */
    String validationOnPhoneFields(
        SObject record,
        Schema.SObjectField fieldName,
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        String billingCountryCode
    );
}