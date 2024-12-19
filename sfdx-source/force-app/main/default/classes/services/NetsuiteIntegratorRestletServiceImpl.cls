/**
 * @author DoorDash
 * @date   10/12/2022
 * @description This is the service interface implementation for Sync with Netsuite implementation
 */
public class NetsuiteIntegratorRestletServiceImpl implements INetsuiteIntegrator {
    private static final string VALIDATION_ERROR_RECORD_TYPE =System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_RECORD_TYPE;
    private static final string VALIDATION_ERROR_BILLING_CONTACT_EMAIL =System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILLING_CONTACT_EMAIL;
    private static final string VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES =System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES;
    private static final string VALIDATION_ERROR_COUNTRY_CODE_ALPHA2 = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_COUNTRY_CODE_ALPHA2;
	private static final string VALIDATION_ERROR_ADDRESS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_ADDRESS;
    private static final string VALIDATION_ERROR_BILL_TO_COMPANY_NAME = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILL_TO_COMPANY_NAME;
    private static final string VALIDATION_ERROR_CURRENCY =System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_CURRENCY;
    private static final String ALLOW_SYNC_WITH_NETSUITE = System.Label.SYNC_WITH_NETSUITE_CUSTOM_PERMISSION;
    private static final String VALIDATION_PERMISSION_ISSUE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PERMISSION_SET;
    private static final String SUCCESS_MESSAGE = System.Label.SYNC_WITH_NETSUITE_SUCCESS_MESSAGE;
    private static final String RECORD_TYPE='Invoice';
    private static final String DESCRIBE_NAME = 'Payment Account';
    private static final String SOBJECT_NAME = 'Payment_Account__c';
    private static final String ERROR_KEY = 'error';
    private static final String ID_KEY = 'id';
    private static final String SUCCESS_KEY = 'success';
    private static final String MESSAGE_KEY = 'message';
    private static final Integer SUCCESS_STATUS_CODE = 200;
    private static final String STATUS_KEY='status';
    private static final Id STORE_RECORD_TYPE_ID;
    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE)
            .getRecordTypeId();
    }
    Map<String, Object> deserializedResponse = new Map<String,Object>();
    @TestVisible
    private List<String> validationErrors;
    /**
     * @description Call Netsuite Restlet API.
     * @param recordId
     * @return Map<String, Object>
    */
    public Map<String, Object> syncWithNetsuite(String recordId){
        Map<String, Object> deserializedResponse;
        Payment_Account__c paymentAccountRecord = new Payment_Account__c(
        	Id = recordId
        );
        HttpRequest request = OAuth1RequestGenerator.generateRequest(
        	DESCRIBE_NAME,
            recordId,
            SOBJECT_NAME
        );
        HttpResponse response = (new Http()).send(request);
        LogEntry entry = new LogEntry(DESCRIBE_NAME, response.getBody(), LogEntry.SeverityLevel.LOW)
            .withCallout(response.getStatus(),String.valueOf(response.getStatusCode()) , request.getEndpoint());
        entry.recordId = recordId;
        entry.className =  NetsuiteIntegratorRestletServiceImpl.class.getName();
        Logger.publish(entry);
        deserializedResponse = getDeserializedResponse(response);
        if(response.getStatusCode() == SUCCESS_STATUS_CODE){
           paymentAccountRecord.NetSuite_ID__c =String.valueOf( deserializedResponse?.get(ID_KEY));
           paymentAccountRecord.NetSuite_Sync_Response__c = null;
        }else{
           paymentAccountRecord.NetSuite_Sync_Response__c = String.valueOf( deserializedResponse?.get(MESSAGE_KEY));
        }

        PaymentAccountsService.updatePaymentAccountWithSyncWithNetsuiteResponse (paymentAccountRecord);
        return deserializedResponse;
     }
    /**
     * @description returns Map of Payment Record Id with Readiness Message for netSuiteIntegration with synchronous call.
     * @param paymentAccountId
     * @return List<String>
    */
    public List<String> performReadinessCheckValidations(Id paymentAccountId){
        validationErrors= new List<String>();
        Payment_Account__c paymentAccount = PaymentAccountsSelector.newInstance().selectById(new Set<Id>{paymentAccountId}).get(0);
            if(!FeatureManagementService.newInstance()
               .checkPermission(ALLOW_SYNC_WITH_NETSUITE)){
               validationErrors.add(VALIDATION_PERMISSION_ISSUE);
               return validationErrors;
            }
            if(paymentAccount.recordTypeId != STORE_RECORD_TYPE_ID){
                validationErrors.add(VALIDATION_ERROR_RECORD_TYPE);
                return validationErrors;
            }
            if(String.isNotBlank(paymentAccount.NetSuite_ID__c)){
                validationErrors.add(VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES);
                return validationErrors;
            }
            validateBillingContactEmail(paymentAccount);
            validateBillToCompanyName(paymentAccount);
            validateCurrency(paymentAccount);
            validateAddress(paymentAccount);
            validateCountryAlpha2(paymentAccount);
        	return validationErrors;
     }

    /**
     * @description validate Billing Contact Email field in Payment_Account__c object.
     * @param paymentAccount
    */
	  @TestVisible
    private void validateBillingContactEmail(Payment_Account__c paymentAccount){
        if(String.isBlank(paymentAccount.Billing_Contact_Email__c)){
        	validationErrors.add(VALIDATION_ERROR_BILLING_CONTACT_EMAIL);
        }
    }

    /**
     * @description validate Billing Company Name field in Payment_Account__c object.
     * @param paymentAccount
    */
    @TestVisible
    private void validateBillToCompanyName(Payment_Account__c paymentAccount){
        if(String.isBlank(paymentAccount.Bill_To_Company_Name__c)){
           validationErrors.add(VALIDATION_ERROR_BILL_TO_COMPANY_NAME);
        }
    }

    /**
     * @description validate Country Alpha2 field in Payment_Account__c object.
     * @param paymentAccount
    */
    @TestVisible
    private void validateCountryAlpha2(Payment_Account__c paymentAccount){
        if(String.isBlank(paymentAccount.Country_Code_Alpha_2__c)){
        	validationErrors.add(VALIDATION_ERROR_COUNTRY_CODE_ALPHA2);
        }
    }

    /**
     * @description validate Address(Address_Line_1, State, City, Postal code) field in Payment_Account__c object.
     * @param paymentAccount
    */
    @TestVisible
    private void validateAddress(Payment_Account__c paymentAccount){
        if(String.isBlank(paymentAccount.Address_Line_1__c)
           || String.isBlank(paymentAccount.State__c )
           || String.isBlank(paymentAccount.City__c )
           || String.isBlank(paymentAccount.Postal_Code__c )){
        	validationErrors.add(VALIDATION_ERROR_ADDRESS);
        }
    }
    /**
     * @description validate Country Alpha2 field in Payment_Account__c object.
     * @param paymentAccount
    */
    @TestVisible
    private void validateCurrency(Payment_Account__c paymentAccount){
        if(String.isBlank(paymentAccount.CurrencyIsoCode )){
        	validationErrors.add(VALIDATION_ERROR_CURRENCY);
        }
    }
    /**
     * @description Deserialize HttpResponse in Key and Value format
     * @param response
     * @return Map<String, Object>
    */

  	@testvisible
    private Map<String, Object> getDeserializedResponse(HttpResponse response){
    Map<String, Object> deserializedResponse = new Map<String, Object>();
    if(response.getStatusCode() == SUCCESS_STATUS_CODE){

         deserializedResponse.put(STATUS_KEY, SUCCESS_KEY);
         deserializedResponse.put(ID_KEY, String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody()))?.get(ID_KEY)));
         deserializedResponse.put(MESSAGE_KEY,SUCCESS_MESSAGE);

    }else{
         deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		 deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize(deserializedResponse.get(ERROR_KEY)));
		 deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(deserializedResponse.get(MESSAGE_KEY)));
		 deserializedResponse.put(STATUS_KEY, ERROR_KEY);

    }
    return deserializedResponse;
  }

}
