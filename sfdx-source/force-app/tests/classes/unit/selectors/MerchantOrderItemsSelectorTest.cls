/**
 * @author Deloitte
 * @date 04/25/2024
 * @description This is test class for MerchantOrdersSelector class
 */
@isTest
public class MerchantOrderItemsSelectorTest {
    private static final String ASSERT_MESSAGE_FIELD_LIST = 'Unexpected Error: Mismatch in field list';
    private static final String ASSERT_MESSAGE_METADATA_TYPE = 'Unexpected Error: The object type must be Merchant Order Items';
    private static final String ASSERT_MESSAGE_RECORD_RETRIEVE = 'Unexpected Error: Records are not retrieved';
    private static final String ASSERT_MESSAGE_RECORD_RETRIEVE_TYPE = 'Unexpected Error: Records are not retrieved by type';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String ACCOUNT_ORDER_PROTOCOL = 'Tablet (DoorDash Owns)';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String VENDOR_ORDER_ID = 'VEN101';
    private static final String VENDOR_ORDER_ID2 = 'VEN102';
    private static final String IDENTIFIER = 'Iden111';
    private static final String IDENTIFIER_TWO = 'Iden112';
    private static final String ACCOUNT_NAME = 'Rx Business';
    private static final String PHOTOSHOOT_BUNDLE = '1.5 hour';
    private static final String PRODUCT_NAME = '1.5 hour';
    private static final String MX_ORDER_TYPE_OF_REQUEST_NET_NEW = 'Net-New';

    /**
    /**
     * @description To test SObject type and field lists are retrieved as expected
     * when class instantiates.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        MerchantOrderItemsSelector merchantOrderItemsSelectorInstance = new MerchantOrderItemsSelector();

        Schema.SObjectType typeOfObj = merchantOrderItemsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = merchantOrderItemsSelectorInstance.getSObjectFieldList();

        MerchantOrderItemsSelector.newInstance();

        System.assertEquals(
            Schema.MX_Order_Item__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_METADATA_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                MX_Order_Item__c.Identifier__c,
                MX_Order_Item__c.Legacy_ID__c,
                MX_Order_Item__c.Mx_Order__c,
                MX_Order_Item__c.Name,
                MX_Order_Item__c.Product__c,
                MX_Order_Item__c.Product_Bundle__c,
                MX_Order_Item__c.Product_Family__c,
                MX_Order_Item__c.Quantity__c,
                MX_Order_Item__c.SKU__c,
                MX_Order_Item__c.Password__c,
                MX_Order_Item__c.Username__c,
                MX_Order_Item__c.Identifier__c
            },
            fieldList,
            ASSERT_MESSAGE_FIELD_LIST
        );
    }

    /**
     * @description To test when Merchant Order id is passed then Merchant Order Item with the same
     * Merchant Order id is returned.
     */
    @isTest
    private static void testWhenMxOrderIdPassedThenMxOrderItemWithSameMxOrderIdReturned() {
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = PHOTOSHOOT_BUNDLE
        );
        insert productBundle;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = parentAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = parentAccount.Order_Protocol__c,
            Type__c = MX_ORDER_TYPE_TABLET,
            Vendor_Order_ID__c = VENDOR_ORDER_ID
        );
        insert tabletMerchantOrder;

        MX_Order_Item__c tabletMerchantOrderItem = new MX_Order_Item__c(
            Mx_Order__c = tabletMerchantOrder.Id,
            Identifier__c = IDENTIFIER
        );
        insert tabletMerchantOrderItem;

        List<MX_Order_Item__c> merchantOrdersItemsRetrieved = new MerchantOrderItemsSelector()
            .selectMxOrderItemWithMxOrderIds(new Set<Id>{ tabletMerchantOrder.Id });
        System.assertEquals(1, merchantOrdersItemsRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test when Merchant Order id is passed then Merchant Order Item with the same
     * Merchant Order id is returned and Merchant Order Item with other Merchant Order id is not
     * returned.
     */
    @isTest
    private static void testWhenMxOrderIdPassedThenMxOrderItemWithOtherMxOrderIdNotReturned() {
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = PHOTOSHOOT_BUNDLE
        );
        insert productBundle;
        Product2 prodOfMxOrderItem = new Product2(Name = PRODUCT_NAME);
        insert prodOfMxOrderItem;
        Mx_Order__c photoshootMerchantOrder = new Mx_Order__c(
            Account__c = parentAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = parentAccount.Order_Protocol__c,
            Type__c = MX_ORDER_TYPE_PHOTOSHOOT,
            Vendor_Order_ID__c = VENDOR_ORDER_ID
        );
        insert photoshootMerchantOrder;
        MX_Order_Item__c photoshootMerchantOrderItem = new MX_Order_Item__c(
            Mx_Order__c = photoshootMerchantOrder.Id,
            Identifier__c = IDENTIFIER,
            Product__c = prodOfMxOrderItem.Id
        );
        insert photoshootMerchantOrderItem;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = parentAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = parentAccount.Order_Protocol__c,
            Type__c = MX_ORDER_TYPE_TABLET,
            Vendor_Order_ID__c = VENDOR_ORDER_ID2
        );
        insert tabletMerchantOrder;
        MX_Order_Item__c tabletMerchantOrderItem = new MX_Order_Item__c(
            Mx_Order__c = tabletMerchantOrder.Id,
            Identifier__c = IDENTIFIER
        );
        insert tabletMerchantOrderItem;
        List<MX_Order_Item__c> merchantOrdersItemsRetrieved = new MerchantOrderItemsSelector()
            .selectMxOrderItemWithMxOrderIds(new Set<Id>{ photoshootMerchantOrder.Id });
        System.assertEquals(1, merchantOrdersItemsRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test when Identifier is passed then Merchant Order Item with the same
     * Identifier is returned.
     */
    @isTest
    private static void testWhenIdentifierPassedThenMxOrderItemWithSameIdentifierReturned() {
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = PHOTOSHOOT_BUNDLE
        );
        insert productBundle;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = parentAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = parentAccount.Order_Protocol__c,
            Type__c = MX_ORDER_TYPE_TABLET,
            Type_Of_Request__c = MX_ORDER_TYPE_OF_REQUEST_NET_NEW,
            Vendor_Order_ID__c = VENDOR_ORDER_ID
        );
        insert tabletMerchantOrder;
        MX_Order_Item__c tabletMerchantOrderItem = new MX_Order_Item__c(
            Mx_Order__c = tabletMerchantOrder.Id,
            Identifier__c = IDENTIFIER
        );
        insert tabletMerchantOrderItem;
        List<MX_Order_Item__c> merchantOrdersItemsRetrieved = new MerchantOrderItemsSelector()
            .selectMxOrderItemWithIdentifiers(new Set<String>{ IDENTIFIER });
        List<MX_Order_Item__c> merchantOrdersItemsRetrievedbyType = new MerchantOrderItemsSelector()
            .selectMxOrderItemWithIdentifiersAndTypes(
                new Set<String>{ IDENTIFIER },
                new Set<String>{ MX_ORDER_TYPE_OF_REQUEST_NET_NEW }
            );
        System.assertEquals(1, merchantOrdersItemsRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
        System.assertEquals(
            1,
            merchantOrdersItemsRetrievedbyType.size(),
            ASSERT_MESSAGE_RECORD_RETRIEVE_TYPE
        );
    }

    /**
     * @description To test when Identifier is passed then Merchant Order Item with the same
     * Identifier is returned and Merchant Order with different Identifier is not returned.
     */
    @isTest
    private static void testWhenIdentifierPassedThenMxOrderItemWithoutIdentifierNotReturned() {
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = PHOTOSHOOT_BUNDLE
        );
        insert productBundle;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = parentAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = parentAccount.Order_Protocol__c,
            Type__c = MX_ORDER_TYPE_TABLET,
            Type_Of_Request__c = MX_ORDER_TYPE_OF_REQUEST_NET_NEW,
            Vendor_Order_ID__c = VENDOR_ORDER_ID
        );
        insert tabletMerchantOrder;
        List<MX_Order_Item__c> tabletMerchantOrderItem = new List<MX_Order_Item__c>{
            new MX_Order_Item__c(Mx_Order__c = tabletMerchantOrder.Id, Identifier__c = IDENTIFIER),
            new MX_Order_Item__c(
                Mx_Order__c = tabletMerchantOrder.Id,
                Identifier__c = IDENTIFIER_TWO
            )
        };
        insert tabletMerchantOrderItem;
        List<MX_Order_Item__c> merchantOrdersItemsRetrieved = new MerchantOrderItemsSelector()
            .selectMxOrderItemWithIdentifiers(new Set<String>{ IDENTIFIER });
        System.assertEquals(1, merchantOrdersItemsRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }
}