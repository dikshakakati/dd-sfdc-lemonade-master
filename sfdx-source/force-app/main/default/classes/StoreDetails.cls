/**
 * @author Deloitte
 * @date 07/08/2024
 * @description Domain Class for Store Detail object.
 */
public inherited sharing class StoreDetails extends fflib_SObjects implements IStoreDetails {
    public static final String UNVERIFIED = 'Unverified';
    /**
     * @description It is used to return the IStoreDetails interface.
     * @param storeDetails - Store Details record list
     * @return IStoreDetails - Returns IStoreDetails Interface
     */
    public static IStoreDetails newInstance(List<Store_Detail__c> storeDetails) {
        return (IStoreDetails) Application.Domain.newInstance(storeDetails);
    }
    /**
     * @description Default constructor for the class
     * @param storeDetails
     */
    public StoreDetails(List<Store_Detail__c> storeDetails) {
        super(storeDetails, Schema.Store_Detail__c.SObjectType);
    }
    /**
     * @description It is used to store the user entered address.
     */
    public void captureUserEnteredAddress() {
        for (Store_Detail__c eachStoreDetail : (List<Store_Detail__c>) getRecords()) {
            eachStoreDetail.User_Entered_Address__Street__s = eachStoreDetail.Address__Street__s;
            eachStoreDetail.User_Entered_Address__City__s = eachStoreDetail.Address__City__s;
            eachStoreDetail.User_Entered_Address__StateCode__s =  eachStoreDetail.Address__StateCode__s;
            eachStoreDetail.User_Entered_Address__CountryCode__s =  eachStoreDetail.Address__CountryCode__s;
            eachStoreDetail.User_Entered_Address__PostalCode__s = eachStoreDetail.Address__PostalCode__s;
        }
    }
    /*
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
         * @param sObjects
         * @return StoreDetails
         */
        public fflib_SObjects construct(List<Object> sObjects) {
            if (StoreDetails.constructorMock != null) {
                return (fflib_SObjects) StoreDetails.constructorMock.construct(sObjects);
            }
            return new StoreDetails((List<SObject>) sObjects);
        }
    }
}