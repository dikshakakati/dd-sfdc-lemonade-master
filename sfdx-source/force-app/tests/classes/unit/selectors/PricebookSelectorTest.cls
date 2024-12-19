/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for AccountsSelector class
 */
@isTest(seeAllData=false)
public class PricebookSelectorTest {
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            isactive = true
        );
        update standardPricebook;
        PricebookSelector pricebookInstance = new PricebookSelector();
        Schema.SObjectType typeOfObj = pricebookInstance.getSobjectType();
        List<Schema.SObjectField> pricebookFieldList = pricebookInstance.getSObjectFieldList();
        PricebookSelector.newInstance();
        System.assertEquals(
            Schema.Pricebook2.SObjectType,
            typeOfObj,
            'The object type must be Pricebook2'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Pricebook2.Id,
                Pricebook2.isActive,
                Pricebook2.isStandard
            },
            pricebookFieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenSelectStandardPricebookThenCall() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            isactive = true
        );
        update standardPricebook;
        PricebookSelector pricebookInstance = new PricebookSelector();
        Pricebook2 standardPricebookQueryReturn = pricebookInstance.selectStandardPricebook();
        PricebookSelector.newInstance();
        System.assertEquals(
            standardPricebook.id,
            standardPricebookQueryReturn.id,
            'Standard pricebook wasnt returned'
        );
    }
}