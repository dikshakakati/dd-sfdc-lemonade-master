/**
 * @description       :
 * @author            : rishab.goyal
 * @group             :
 * @last modified on  : 05-24-2024
 * @last modified by  : Soumya Dash
**/
@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId')
private class BrandWrapperTest {

    @isTest
    static void testWhenStringIsPassedThenReturnDeserializedValues() {
        String jsonString = '[{"brandName":"bingoBrand01","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":true,"brandAssociationId":null,"accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo05","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo06","businessVerticalId":"a4EOt0000003gVlMAI"}]},{"brandName":"bingoBrand02","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":true,"brandAssociationId":null,"accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo07","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo08","businessVerticalId":"a4EOt0000003gVlMAI"}]}]';
        List<BrandWrapper> dataList = (List<BrandWrapper>) JSON.deserialize(jsonString, List<BrandWrapper>.class);

        System.assertEquals(2, dataList.size(), 'Not deserialized as expected');
        System.assertEquals('bingoBrand01',dataList[0].brandName, 'Not deserialized as expected');
        System.assertEquals(null, dataList[0].brandId, 'Not deserialized as expected');
        System.assertEquals('006Ot000006euXvIAI', dataList[0].recordId, 'Not deserialized as expected');
        System.assertEquals(true, dataList[0].createBrandAssociations, 'Not deserialized as expected');
        System.assertEquals(null, dataList[0].brandAssociationId, 'Not deserialized as expected');
        System.assertEquals('001Ot00000ArIe3IAF', dataList[0].accountId, 'Not deserialized as expected');
        System.assertEquals('USD', dataList[0].currencyOfAccount, 'Not deserialized as expected');
        System.assertEquals(2, dataList[0].bizRefList.size(), 'Not deserialized as expected');
        System.assertEquals('bingo05', dataList[0].bizRefList[0].businessName, 'Not deserialized as expected');
        System.assertEquals('a4EOt0000003IQDMA2', dataList[0].bizRefList[0].businessVerticalId, 'Not deserialized as expected');
        System.assertEquals('bingo06', dataList[0].bizRefList[1].businessName, 'Not deserialized as expected');
        System.assertEquals('a4EOt0000003gVlMAI', dataList[0].bizRefList[1].businessVerticalId, 'Not deserialized as expected');
        System.assertEquals('bingoBrand02',dataList[1].brandName, 'Not deserialized as expected');
        System.assertEquals(null, dataList[1].brandId, 'Not deserialized as expected');
        System.assertEquals('006Ot000006euXvIAI', dataList[1].recordId, 'Not deserialized as expected');
        System.assertEquals(true, dataList[1].createBrandAssociations, 'Not deserialized as expected');
        System.assertEquals(null, dataList[1].brandAssociationId, 'Not deserialized as expected');
        System.assertEquals('001Ot00000ArIe3IAF', dataList[1].accountId, 'Not deserialized as expected');
        System.assertEquals('USD', dataList[1].currencyOfAccount, 'Not deserialized as expected');
        System.assertEquals(2, dataList[1].bizRefList.size(), 'Not deserialized as expected');
        System.assertEquals('bingo07', dataList[1].bizRefList[0].businessName, 'Not deserialized as expected');
        System.assertEquals('a4EOt0000003IQDMA2', dataList[1].bizRefList[0].businessVerticalId, 'Not deserialized as expected');
        System.assertEquals('bingo08', dataList[1].bizRefList[1].businessName, 'Not deserialized as expected');
        System.assertEquals('a4EOt0000003gVlMAI', dataList[1].bizRefList[1].businessVerticalId, 'Not deserialized as expected');
    }


    /**
    * @description Test class to getAllBrandAssociationIds
    * @author Gaurav | 03-18-2024
    **/
    @isTest
    static void testWhenGetAllBrandAssociationIdsCalledThenReturnExactData() {
        String jsonString = '[{"brandName":"bingoBrand01","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":false,"brandAssociationId":"a3GOt000000xXrBMAU","accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo05","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo06","businessVerticalId":"a4EOt0000003gVlMAI"}]},{"brandName":"bingoBrand02","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":true,"brandAssociationId":"a3GOt000000xY2bMAE","accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo07","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo08","businessVerticalId":"a4EOt0000003gVlMAI"}]},{"brandName":"bingoBrand02","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":true,"brandAssociationId":null,"accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo07","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo08","businessVerticalId":"a4EOt0000003gVlMAI"}]},{"brandName":"bingoBrand02","brandId":null,"recordId":"006Ot000006euXvIAI","createBrandAssociations":false,"brandAssociationId":null,"accountId":"001Ot00000ArIe3IAF","currencyOfAccount":"USD","bizRefList":[{"businessName":"bingo07","businessVerticalId":"a4EOt0000003IQDMA2"},{"businessName":"bingo08","businessVerticalId":"a4EOt0000003gVlMAI"}]}]}]';
        List<BrandWrapper> dataList = (List<BrandWrapper>) JSON.deserialize(jsonString, List<BrandWrapper>.class);

        Set<Id> bizRefIds = BrandWrapper.getAllBrandAssociationIds(dataList);

        System.assertEquals(1, bizRefIds.size(), 'Condition or jsonString is not as expected');
        System.assertEquals('a3GOt000000xXrBMAU', new List<Id>(bizRefIds)[0], 'Condition or jsonString is not as expected');
    }

    /**
    * @description test class to getUrlsOfBizRefs
    * @author Gaurav | 03-18-2024
    **/
    @isTest
    static void testWhenGetUrlsOfBizRefsThenReturnsExactValue() {
        List<BrandWrapper.BrandAndBizRefs> brandAndBizRefsList = new List<BrandWrapper.BrandAndBizRefs>();
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(null, new List<Business_Reference__c>{(new Business_Reference__c(Id = 'a3KOt000000Pk4TMAS'))}));
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(null, new List<Business_Reference__c>{(new Business_Reference__c(Id = 'a3KOt000000PkUHMA0'))}));

        String expectedUrls = URL.getOrgDomainUrl().toExternalForm() + '/a3KOt000000Pk4TMAS\n' + URL.getOrgDomainUrl().toExternalForm() + '/a3KOt000000PkUHMA0\n';
        String actualUrls = BrandWrapper.getUrlsOfBizRefs(brandAndBizRefsList);

        System.assertEquals(expectedUrls, actualUrls, 'Not returned expected URLs');
    }

    /**
    * @description test class to getAllBrandsToInsert
    * @author Gaurav | 03-18-2024
    **/
    @isTest
    static void testWhenGetAllBrandsToInsertThenGetExactValue() {
        List<BrandWrapper.BrandAndBizRefs>  brandAndBizRefsList = new List<BrandWrapper.BrandAndBizRefs>();
        List<Brand__c> expectedBrandList = new List<Brand__c>{new Brand__c(Id=null),new Brand__c(Id=null)};
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(expectedBrandList[0], null));
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(expectedBrandList[1], null));
        String sobjectName = 'Opportunity';
        System.assertEquals(expectedBrandList, BrandWrapper.getAllBrandsToInsert(brandAndBizRefsList, sobjectName), 'Not returning valid Brand List');
        System.assertEquals(2, BrandWrapper.getAllBrandsToInsert(brandAndBizRefsList, sobjectName).size(), 'Not returning valid Brand List');
        System.assertEquals(expectedBrandList[0].Source__c, sobjectName, 'Sobject name is not updated exactly');
        expectedBrandList[0].Id = 'a3HOt0000002SzVMAU';
        System.assertEquals(expectedBrandList[1], BrandWrapper.getAllBrandsToInsert(brandAndBizRefsList, sobjectName)[0], 'Not returning valid Brand List');

    }

    /**
    * @description test class to getAllBizRefsToInsert
    * @author Gaurav | 03-18-2024
    **/
    @isTest
    static void testWhenGetAllBizRefsToInsertThenReturnBusinesRefListWithBrandIdAssigned(){
        List<BrandWrapper.BrandAndBizRefs> brandAndBizRefsList = new List<BrandWrapper.BrandAndBizRefs>();
        List<Brand__c> brandList = new List<Brand__c>{new Brand__c(Id='a3HOt0000002SzVMAU'),new Brand__c(Id='a3HOt0000003OvRMAU')};
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(brandList[0], new List<Business_Reference__c>{(new Business_Reference__c(Id = 'a3KOt000000Pk4TMAS'))}));
        brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(brandList[1], new List<Business_Reference__c>{(new Business_Reference__c(Id = 'a3KOt000000PkUHMA0'))}));

        List<Business_Reference__c> actualBizRefList = BrandWrapper.getAllBizRefsToInsert(brandAndBizRefsList);

        System.assertEquals(2, actualBizRefList.size(), 'Not returning valid list of Business Reference');
        System.assertEquals(brandList[0].Id, actualBizRefList[0].Brand__c, 'Not assigning the brand Id value correctly');
        System.assertEquals(brandList[1].Id, actualBizRefList[1].Brand__c, 'Not assigning the brand Id value correctly');
    }

}