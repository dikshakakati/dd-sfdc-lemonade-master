/**
 * @description : Service Implimentation class for PhoneValidation Object
 * @author Deloitte
 * @date 19/04/2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts')
public inherited sharing class PhoneValidationImpl implements IPhoneValidation {
    static final String ACCOUNT_OBJECT = 'Account';
    static final String CONTACT_OBJECT = 'Contact';
    static final String NINTEX_INTEGRATION_USER_IDENTIFIER = 'Nintex_Integration_user_identifier';
    static final String BYPASS_PHONE_VALIDATION = 'Bypass_Phone_Validation';
    /**
     * @description Determines if the code is invoked from a trigger context and needs the
     *              `addError()` methods.
     * @return Boolean
     **/
    private static Boolean calledFromTrigger {
        get {
            if (calledFromTrigger == null) {
                calledFromTrigger = Trigger.isExecuting || Test.isRunningTest();
            }

            return calledFromTrigger;
        }
        set;
    }

    /**
     * @description validates phone numbers
     * @param record
     * @param fieldName
     * @param countryToCountryAttributes
     * @param phoneCodesToCountryAttributes
     * @param billingCountryCode
     * @return String
     */
    public String validationOnPhoneFields(
        SObject record,
        Schema.SObjectField fieldName,
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        String billingCountryCode
    ) {
        // removing special characters in the Phone filed like (,).-
        String phone = (String) record.get(fieldName);
        record.put(fieldName, phone.replaceAll('(?!^\\+)[-|,|\\(.*\\)| ]', ''));
        if (!Pattern.matches('[+[0-9]][0-9]*?', (String) record.get(fieldName))) {
            //throwing validation when phone number contains any special charecter/Alphabets except + in first place.
            if (calledFromTrigger) {
                record.addError(fieldName, System.Label.Phone_Validation_Special_Character);
            }
            return System.Label.Phone_Validation_Special_Character;
        } else if (!Pattern.matches('[+][0-9]*?', (String) record.get(fieldName))) {
            return prependCountryCode(
                record,
                billingCountryCode,
                countryToCountryAttributes,
                phoneCodesToCountryAttributes,
                fieldName
            );
        } else {
            return validationOnUserEnteredCountryCode(
                record,
                phoneCodesToCountryAttributes,
                fieldName
            );
        }
    }
    /**
     * @description It checks whether the passed Country is bypassed for Phone length validation
     * on Nintex form submission.
     * @param country
     * @return Boolean
     */
    private Boolean isPhoneLengthCheckBypassed(String country) {
        return (byPassPhoneValidation() ||
        (FeatureManagementService.newInstance()
            .checkPermission(NINTEX_INTEGRATION_USER_IDENTIFIER) &&
        country == System.Label.Countries_with_bypass_phone_validation ||
        country == System.Label.Countries_with_bypass_phone_validation_NZ));
    }
    /**
     * @description It checks whether the passed Country_Attributes_Mapping__mdt record has
     * Phone_Maximum_Digits__c or Phone_Minimum_Digits__c as null.
     * @param countryAttributesMapping
     * @return Boolean
     */
    private Boolean isPhoneMaxMinDigitsNull(
        Country_Attributes_Mapping__mdt countryAttributesMapping
    ) {
        return countryAttributesMapping.Phone_Maximum_Digits__c == null ||
            countryAttributesMapping.Phone_Minimum_Digits__c == null;
    }
    /**
     * @description validation based on user entered country code.
     * @param record
     * @param phoneCodesToCountryAttributes
     * @param fieldName
     * @return String
     */
    private String validationOnUserEnteredCountryCode(
        SObject record,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        Schema.SObjectField fieldName
    ) {
        if (byPassPhoneValidation()) {
            return null;
        }
        String phone = (String) record.get(fieldName);
        if (phone.startsWith('+1')) {
            record.put(fieldName, '+1' + phone.substring(2).replaceFirst('^0+', '')); //removes zeros from after country code
            return validateMaxMinPhoneLength(record, '1', phoneCodesToCountryAttributes, fieldName);
        } else if (phone.startsWith('+7')) {
            record.put(fieldName, '+7' + phone.substring(2).replaceFirst('^0+', '')); //removes zeros from after country code
            return validateMaxMinPhoneLength(record, '7', phoneCodesToCountryAttributes, fieldName);
        } else if (phoneCodesToCountryAttributes.keySet().contains(phone.substring(1, 3))) {
            record.put(
                fieldName,
                phone.substring(0, 3) + phone.substring(3).replaceFirst('^0+', '')
            ); //removes zeros from after country code
            return validateMaxMinPhoneLength(
                record,
                phone.substring(1, 3),
                phoneCodesToCountryAttributes,
                fieldName
            );
        } else if (phoneCodesToCountryAttributes.keySet().contains(phone.substring(1, 4))) {
            record.put(
                fieldName,
                phone.substring(0, 4) + phone.substring(4).replaceFirst('^0+', '')
            ); //removes zeros from after country code
            return validateMaxMinPhoneLength(
                record,
                phone.substring(1, 4),
                phoneCodesToCountryAttributes,
                fieldName
            );
        } else {
            String validationError = String.format(
                System.Label.Phone_Validation_Not_Acceptable,
                new List<Object>{ String.valueOf(record.getsobjecttype()).toLowerCase() }
            );
            if (calledFromTrigger) {
                record.addError(fieldName, validationError);
            }
            return validationError;
        }
    }
    /**
     * @description prepend country code based on billing country and removing zeros after country code
     * @param record
     * @param contactBillingCountryCode
     * @param countryToCountryAttributes
     * @param phoneCodesToCountryAttributes
     * @param fieldName
     * @return String
     */
    private String prependCountryCode(
        SObject record,
        String contactBillingCountryCode,
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        Schema.SObjectField fieldName
    ) {
        String billingCountryCode = '';
        if (
            record.getSObjectType() ==
            ((SObject) Type.forName(ACCOUNT_OBJECT).newInstance())
                .getSObjectType()
                .getDescribe()
                .getSObjectType() &&
            record.get('BillingCountryCode') != null
        ) {
            //if it's an account record then it will prepend based on billing country code.
            billingCountryCode = (String) record.get('BillingCountryCode');
        } else if (
            record.getSObjectType() ==
            ((SObject) Type.forName(CONTACT_OBJECT).newInstance())
                .getSObjectType()
                .getDescribe()
                .getSObjectType()
        ) {
            //if it's an contact record then it will prepend based on account billing country code.
            billingCountryCode = contactBillingCountryCode;
        }
        String phone = (String) record.get(fieldName);
        record.put(fieldName, phone.replaceFirst('^0+', '')); //replace zeros from first place
        phone = (String) record.get(fieldName);
        if (countryToCountryAttributes.get(billingCountryCode) != null) {
            record.put(
                fieldName,
                '+' +
                    countryToCountryAttributes.get(billingCountryCode).Phone_Country_Code__c +
                    phone
            );
            return validateMaxMinPhoneLength(
                record,
                countryToCountryAttributes.get(billingCountryCode).Phone_Country_Code__c,
                phoneCodesToCountryAttributes,
                fieldName
            );
        }
        return null;
    }
    /**
     * @description validatiing number with respective country.
     * @param record
     * @param phoneCode
     * @param phoneCodesToCountryAttributes
     * @param fieldName
     * @return String
     */
    private String validateMaxMinPhoneLength(
        SObject record,
        String phoneCode,
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes,
        Schema.SObjectField fieldName
    ) {
        if (isPhoneLengthCheckBypassed(phoneCodesToCountryAttributes.get(phoneCode).Country__c)) {
            return null;
        }
        String phone = (String) record.get(fieldName);
        if (!isPhoneMaxMinDigitsNull(phoneCodesToCountryAttributes.get(phoneCode))) {
            if (
                phoneCode == '1' &&
                phoneCodesToCountryAttributes.get(phoneCode).Phone_Maximum_Digits__c !=
                (phone.length() -
                phoneCode.length() -
                1)
            ) {
                if (calledFromTrigger) {
                    record.addError(fieldName, System.Label.Phone_Validation_US_Canada);
                }
                return System.Label.Phone_Validation_US_Canada;
            } else if (
                phoneCode != '1' &&
                phoneCodesToCountryAttributes.get(phoneCode).Phone_Maximum_Digits__c <
                (phone.length() -
                phoneCode.length() -
                1) ||
                phoneCodesToCountryAttributes.get(phoneCode).Phone_Minimum_Digits__c >
                (phone.length() -
                phoneCode.length() -
                1)
            ) {
                String validationError = String.format(
                    System.Label.Phone_Validation,
                    new List<Object>{
                        phoneCodesToCountryAttributes.get(phoneCode).Country__c,
                        phoneCode,
                        phoneCodesToCountryAttributes.get(phoneCode)
                            .Phone_Minimum_Digits__c.intValue(),
                        phoneCodesToCountryAttributes.get(phoneCode)
                            .Phone_Maximum_Digits__c.intValue()
                    }
                );
                if (calledFromTrigger) {
                    record.addError(fieldName, validationError);
                }
                return validationError;
            }
        } else if ((phone.length() - 1) > 15) {
            if (calledFromTrigger) {
                record.addError(fieldName, System.Label.Phone_Validation_Limit);
            }
            return System.Label.Phone_Validation_Limit;
        }
        return null;
    }
    /**
     * @description It is used to bypass phone validation.
     * @return boolean
     */
    private boolean byPassPhoneValidation() {
        return FeatureManagementService.newInstance().checkPermission(BYPASS_PHONE_VALIDATION);
    }
}