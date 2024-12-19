/**
 * @author Deloitte
 * @date 07/22/2024
 * @description This is the Handler for BusinessOnboardingDetails.
 */
public without sharing class BusinessOnboardingDetailsHandler extends ApplicationDomainHandler {
    private static final String BYPASS_INTERFACE_TRANSACTION_PERMISSION = 'Bypass_Interface_Transaction';
    private static final String LOG_DOMAIN_BUSINESS_ONBOARDING_DETAILS = 'Business Onboarding Details Handler';
    private static final String LOG_SERVICE_BUSINESS_ONBOARDING_DETAILS = 'Business Onboarding Details';
    private static final String MX_ONBOARDING_USER_ACCESS = 'Mx_Onboarding_User';
    private static final String OI_DATA_SERVICE = 'OIDataService';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String RECORD_CREATION_STATUS_SUCCESS = 'Success';

    /**
     * @description Constructor Method.
     * @param sObjects
     */
    public BusinessOnboardingDetailsHandler(List<Business_Onboarding_Detail__c> sObjects) {
        super(sObjects);
        setContextBypass(
            Business_Onboarding_Detail__c.SObjectType,
            BusinessOnboardingDetailsHandler.class
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable.
         * @param sObjectList - List of SObjects
         * @return BusinessOnboardingDetailsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BusinessOnboardingDetailsHandler(sObjectList);
        }
    }
}