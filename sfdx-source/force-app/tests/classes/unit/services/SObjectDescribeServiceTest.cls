/**
 * @description : Test class used to cover SObjectDescribeService and SObjectDescribeServiceImpl classes.
 * @author Deloitte
 * @date 20/04/2022
 */
@isTest
private class SObjectDescribeServiceTest {
    /**
     * @description to get all phone field in a object.
     */
    @isTest
    private static void testWhenGivingAnObjectNameWithPhoneTypeThenReturnSetOfPhoneFields() {
        //Act
        Set<Schema.SObjectField> phoneFields = SObjectDescribeService.getFieldsByDisplayType(
            Account.SObjectType,
            schema.displaytype.Phone
        );
        //Assert
        System.assertEquals(
            phoneFields.size() != null,
            true,
            'There is no Phone field in Account object'
        );
        System.assertEquals(
            new Set<Schema.SObjectField>{
                Account.Phone,
                Account.Fax,
                Account.Order_Protocol_Fax__c
            },
            phoneFields,
            ' Mismatch in field list'
        );
    }
}