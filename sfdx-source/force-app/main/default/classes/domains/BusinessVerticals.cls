/**
 * @description Domain Class for Business Vertical Object
 * @author Deloitte
 */
public inherited sharing class BusinessVerticals extends fflib_SObjects implements IBusinessVerticals {
    static final String BLANK_SPACE = ' ';
    static final String STARTING_BRACKET = '(';
    static final String CLOSING_BRACKET = ')';

    /**
     * @description This method is to return the IBusinessVerticals interface
     * @param List<Business_Vertical__c> - list of Business Verticals
     * @param recordList - Business Verticals record list
     * @return IBusinessVerticals - Returns IBusinessVerticals Interface
     */
    public static IBusinessVerticals newInstance(List<Business_Vertical__c> recordList) {
        return (IBusinessVerticals) Application.Domain.newInstance(recordList);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     * @param Schema.Business_Vertical__c.SObjectType
     */
    public BusinessVerticals(List<Business_Vertical__c> sObjectList) {
        super(sObjectList, Schema.Business_Vertical__c.SObjectType);
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
     * @description To create instance of BusinessVertical domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of Business Verticals
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (BusinessVerticals.constructorMock != null) {
                return (fflib_ISObjects) BusinessVerticals.constructorMock.construct(objects);
            }
            return new BusinessVerticals((List<Business_Vertical__c>) objects);
        }
    }

     /**
      * @description Assigning Business Vertical Name on record insert or Name update
      */
    public void assignNameOnInsertOrNameUpdate() {
        for (Business_Vertical__c eachBusinessVertical : (List<Business_Vertical__c>) getRecords()) {
            String businessVerticalId = eachBusinessVertical.Business_Vertical_ID__c;
            String verticalName = eachBusinessVertical.Vertical_Name__c;
            
            if (!String.isEmpty(businessVerticalId)) {
                eachBusinessVertical.Name = verticalName + BLANK_SPACE +
                    STARTING_BRACKET + businessVerticalId + CLOSING_BRACKET;
            } else {
                eachBusinessVertical.Name = verticalName; // If Business_Vertical_ID__c is blank, only use Vertical_Name__c
            }
        }
    }
}