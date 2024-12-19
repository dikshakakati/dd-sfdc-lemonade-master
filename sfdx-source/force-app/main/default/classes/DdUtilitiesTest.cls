/**
 * @author Sanidhya Jain
 * @date October 2024
 * @description Test class for the methods in DdUtilitiesService and PicklistUtil
 */

 @isTest
public without sharing class DdUtilitiesTest {

    /**
     * Begin - Test class to execute if one of these classes is updated
     */

    private static List<System.Type> classReference = new List<System.Type>{
        DdUtilitiesService.class,
        PicklistUtil.class
    };

    @isTest
    public static void testWhenPicklistThenIsCorrect() {
        Map<String, List<PicklistUtil.PicklistOption>> picklistOptions =
            PicklistUtil.getPicklistOptions('Contact','CurrencyIsoCode');
        Assert.isTrue(picklistOptions.containsKey('CurrencyIsoCode'),'Contact.CurrencyIsoCode object picklist not found');
        Assert.isTrue(!picklistOptions.get('CurrencyIsoCode').isEmpty(),'Contact.CurrencyIsoCode object picklist is empty');
    }

    @isTest
    public static void testWhenDependentPicklistThenIsCorrect() {
        Map<String, List<String>> picklistValues =
            PicklistUtil.getDependentPicklistValues('Account','Request_Type__c','Activation_Method__c');
        Assert.isTrue(!picklistValues.isEmpty(),'Account dependent picklist Request Type/Activation Method is empty');
    }

    @isTest
    public static void testWhenSanitizeStringSOSLThenIncreaseCodeCoverage() {
        String soslString = 'Ben & Jerry [Parent-12345]';
        String sanitizedSoslString = 'Ben \\& Jerry \\[Parent\\-12345\\]';
        Assert.areEqual(sanitizedSoslString, DdUtilitiesService.sanitizeStringSOSL(soslString),'Should Have a Valid String');
    }

    @isTest
    public static void testWhenGetFieldValThenAsString() {
        List<User> users =
            [SELECT Id,Name,Manager.Name,CreatedDate,isActive
               FROM User
              WHERE ManagerId != null
              LIMIT 1];

        system.assert(!users.isEmpty(),'No Users found matching this criteria');

        User u = users[0];
        String userName = DdUtilitiesService.getFieldValAsString(u,'Name','String');
        system.assert(userName == u.Name,'User name does not match');
        String userManagerName = DdUtilitiesService.getFieldValAsString(u,'Manager.Name','String');
        system.assert(userManagerName == u.Manager.Name,'User manager does not match');
        String userIsActive = DdUtilitiesService.getFieldValAsString(u,'isActive','Boolean');
        system.assert(u.isActive ? (userIsActive == DdConstants.STRING_YES) : (userIsActive == DdConstants.STRING_NO),'User isActive does not match');
        String userName2 = DdUtilitiesService.getFieldValAsString(u,'Name');
        system.assert(userName2 == u.Name,'User name does not match');
    }

    @isTest
    public static void testWhenGetFieldValThenNullError() {
        List<User> users =
            [SELECT Id,Name,Manager.Name,CreatedDate,isActive
               FROM User
              WHERE ManagerId != null
              LIMIT 1];

        system.assert(!users.isEmpty(),'No Users found matching this criteria');

        User u = users[0];
        String userName = DdUtilitiesService.getFieldValAsString(u,null);
        Assert.areEqual(userName,'' , 'User Name Should be null');

        String userName2 = DdUtilitiesService.getFieldValAsString(u,null,'Date');
        Assert.areEqual(userName2,'' , 'User Name 2 Should be null');
    }

    @isTest
    public static void testWhenIsDecimalThenTrue(){
        Boolean isDecimal = DdUtilitiesService.isDecimal('1.2');
        Assert.isTrue(isDecimal, 'Its Should be a decimal Number');
    }

    @isTest
    public static void testWhenIsDecimalThenFalse(){
        Boolean isDecimal = DdUtilitiesService.isDecimal('Test');
        Assert.isFalse(isDecimal, 'It cannot a decimal Number');
    }

    @isTest
    public static void testWhenFormatDecimalThenTrue(){
        String decimalValue = DdUtilitiesService.formatDecimal('1.2');
        Assert.isTrue(!String.isEmpty(decimalValue),'decimalValue cannot be empty');
    }

}