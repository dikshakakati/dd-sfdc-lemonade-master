/**
 * @author DoorDash
 * @date 08/28/2023
 * @description Test class for StandardRateCardTiersSelector class.
 */
@isTest
public class StandardRateCardTiersSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Standard Rate Card Tier';
    private static final String ASSERT_MESSAGE_NOT_RETRIEVED = 'Unexpected result: The Standard Rate Card Tiers were not retrieved appropriately.';
    
	/**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        StandardRateCardTiersSelector standardRateCardTiersSelectorInstance = new StandardRateCardTiersSelector();

        Schema.SObjectType typeOfObj = standardRateCardTiersSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = standardRateCardTiersSelectorInstance.getSObjectFieldList();

        StandardRateCardTiersSelector.newInstance();

        System.assertEquals(
            Schema.Standard_Rate_Card_Tier__mdt.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Standard_Rate_Card_Tier__mdt.Lower_Bound__c,
            	Standard_Rate_Card_Tier__mdt.Upper_Bound__c,
            	Standard_Rate_Card_Tier__mdt.Fee_Value__c
            },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
    
    /**
     * @description To test Standard Rate Card Tiers custom metadata query.
     */
    @isTest
    private static void testWhenGetAllValuesMethodCalledThenReturnAllMetadataRecords() {
        List<Standard_Rate_Card_Tier__mdt> standardRateCardTiers = StandardRateCardTiersSelector.newInstance()
            .getAllValues();
        System.assertEquals(
            !standardRateCardTiers.isEmpty(),
            true,
            ASSERT_MESSAGE_NOT_RETRIEVED
        );
    }
}