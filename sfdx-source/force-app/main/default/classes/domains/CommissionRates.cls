/**
 * @author Deloitte
 * @date 24/04/2024
 * @description Domain Class for Commission_Rate__c Object
 */
public inherited sharing class CommissionRates extends SObjects implements ICommissionRates {
	private static final Date START_DATE = Date.newInstance(2000, 1, 1);
    private static final Date END_DATE = Date.newInstance(3000, 12, 31);

    /**
     * @description This method is used to return the ICommissionRates interface
     * @param recordList - CommissionRate records list
     * @return ICommissionRates - Returns ICommissionRates Interface
     */
    public static ICommissionRates newInstance(List<Commission_Rate__c> recordList) {
        return (ICommissionRates) Application.Domain.newInstance(recordList);
    }
     /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public CommissionRates(List<Commission_Rate__c> sObjects) {
        super(sObjects, Schema.Commission_Rate__c.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

	/**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }
    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return CommissionRates - List of CommissionRates
         */
        public fflib_ISObjects construct(List<Object> objectList) {
            return new CommissionRates((List<Commission_Rate__c>) objectList);
        }
    }

    /**
     * @description Set Search Key and Start and End date fields correctly.
     */
    public void generateSearchKey() {

        for (Commission_Rate__c eachComissionRate  : (List<Commission_Rate__c>) getRecords()) {
            if (checkSearchKeyEligibility(eachComissionRate)) {
                eachComissionRate.Search_Key__c = generateKey(eachComissionRate.Product__c, eachComissionRate.Package__c, eachComissionRate.CurrencyIsoCode, eachComissionRate.Account_Primary_Vertical__c);
            } else {
                eachComissionRate.Search_Key__c = null;
            }
            if (eachComissionRate.Start__c == null) {
                eachComissionRate.Start__c = START_DATE;
            }
            if (eachComissionRate.End__c == null) {
                eachComissionRate.End__c = END_DATE;
            }
        }
    }
    /**
     * @description checks for the search key eligibility.
     * @param commissionRate
     * @return searchKeyEligibility
     */
    private Boolean checkSearchKeyEligibility (Commission_Rate__c commissionRate){
        Boolean searchKeyEligibility = false;
        if ((String.isEmpty(commissionRate.Submarket__c)) && (!String.isEmpty(commissionRate.Product__c)) &&
            (!String.isEmpty(commissionRate.Package__c)) && (!String.isEmpty(commissionRate.CurrencyIsoCode)) &&
            (!String.isEmpty(commissionRate.Account_Primary_Vertical__c))) {
                searchKeyEligibility= true;
            }
        return searchKeyEligibility;
    }

    /**
     * @description Generate Search key by concatenating fields.
     * @param productId
     * @param packageId
     * @param currencyCode
     * @param category
     * @return key
     */
    private String generateKey (Id productId, Id packageId, String currencyCode, String category){
        //Use empty string to convince apex that this is concat and not math
        String key = '';
        if(String.isNotBlank(productId)){
            key += productId;
        }
        if(String.isNotBlank(packageId)){
            key += packageId;
        }
        if(String.isNotBlank(currencyCode)){
            key += currencyCode;
        }
        if(String.isNotBlank(category)){
            key += category;
        }
        return key;
    }
}