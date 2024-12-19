/**
 * @author Deloitte
 * @date 11/15/2023
 * @description Test class for BusinessVerticalServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class BusinessVerticalsServiceImplTest {
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
    private static final String DRIVE_DB = 'DriveDb';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String MDS = 'MDS';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Business_Vertical__c.';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String RX_PRIMARY_VERTICAL = 'Rx';
    private static final String RESTAURANT ='Restaurant';

    @isTest
    private static void testWhenBusinessReferenceUpdatedWithBusinessVerticalThenBusinessVerticalFieldsUpdated() {

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();
        List<Business_Vertical__c> businessVerticalList = new List<Business_Vertical__c>();
        businessVerticalList.add(businessVertical);
        Business_Reference__c businessRef = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.External_Id_Source__c, DRIVE_DB)
            .setField(Business_Reference__c.Business_Vertical__c, businessVertical.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        BusinessVerticalsSelector businessVerticalsSelectorMock = (BusinessVerticalsSelector) mocks.mock(BusinessVerticalsSelector.class);
        IBusinessVerticalsService mockBusinessVerticalService = (IBusinessVerticalsService) mocks.mock(
            IBusinessVerticalsService.class
        );
        Application.Service.setMock(IBusinessVerticalsService.class, mockBusinessVerticalService);

        mocks.startStubbing();
        mocks.when(businessVerticalsSelectorMock.sObjectType()).thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(
                businessVerticalsSelectorMock.selectById(
                    new Set<Id>{
                        businessVertical.Id
                    }
                )
            )
            .thenReturn(
                businessVerticalList
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessVerticalsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BusinessVerticalsService.populateBusinessVerticalDetails(new List<Business_Reference__c>{businessRef});
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Business_Reference__c>{ businessRef }
        );
        fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);
        ((IBusinessVerticalsService) mocks.verify(mockBusinessVerticalService, 2))
            .populateBusinessVerticalDetails(new List<Business_Reference__c>{businessRef});
    }
    
    
    
    
    @isTest
    private static void testWhenBusinessReferenceUpdatedThenBusinessVerticalDefaulted() {
        //Generate Ids for BVID and BizRef
        Id mockBVId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id mockBizRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Set<Id> bVIdSet = new Set<Id>{ mockBVId };
        

        List<Business_Vertical__c> bVIDList = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = mockBVId,
                Business_Vertical_ID__c = '',
                Name = BUSINESS_VERTICAL_NAME,
                Primary_Vertical__c = RX_PRIMARY_VERTICAL,
                Menu_UI_Type__c = RESTAURANT,
                Product__c = PRODUCT_MARKETPLACE,
                Vertical_Name__c = RESTAURANT,
                Active__c = true
            )
        };

            Business_Reference__c businessRef = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, mockBVId)
            .setField(Business_Reference__c.Id, mockBizRefId)
            .setField(Business_Reference__c.External_Id_Source__c, MDS)
            .toSObject();
        
        List<Business_Reference__c> businessRefList = new List<Business_Reference__c>{
          businessRef
        };

            
        List<Business_Reference__c> updatedBusinessRefList = new List<Business_Reference__c>{
            new Business_Reference__c(
                id = mockBizRefId,
                Business_Vertical__c = mockBVId)
        };
                
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        BusinessVerticalsSelector bvidSelectorMock = (BusinessVerticalsSelector) mocks.mock(
            BusinessVerticalsSelector.class
        );

        mocks.startStubbing();
        mocks.when(bvidSelectorMock.sObjectType()).thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(bvidSelectorMock.selectById(bVIdSet)).thenReturn(bVIDList);
        mocks.when(bvidSelectorMock.selectPrimaryVerticalRxRecord()).thenReturn(bVIDList);
        mocks.stopStubbing();
		Application.SELECTOR.setMock(bvidSelectorMock);
        BusinessVerticalsService.populateBusinessVerticalDetails(businessRefList);
		
        System.assertEquals(mockBVId, updatedBusinessRefList[0].Business_Vertical__c, 'No bvid was set');
        
    }
    
    @isTest
    private static void testWhenBusinessReferenceUpdatedThenRxBusinessVerticalDefaulted() {
        //Generate Ids for BVID and BizRef
        Id mockBVId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id mockBVId1 = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id mockBizRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Set<Id> bVIdSet = new Set<Id>{ mockBVId };
        
            List<Business_Vertical__c> bVIDList1 = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = mockBVId1,
                Business_Vertical_ID__c = '',
                Name = BUSINESS_VERTICAL_NAME,
                Primary_Vertical__c = RX_PRIMARY_VERTICAL,
                Menu_UI_Type__c = RESTAURANT,
                Product__c = PRODUCT_MARKETPLACE,
                Vertical_Name__c = RESTAURANT,
                Active__c = true
            )
        };

            Business_Reference__c businessRef = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, mockBVId)
            .setField(Business_Reference__c.Id, mockBizRefId)
            .setField(Business_Reference__c.External_Id_Source__c, MDS)
            .toSObject();
        
        List<Business_Reference__c> businessRefList = new List<Business_Reference__c>{
          businessRef
        };

            
        List<Business_Reference__c> updatedBusinessRefList = new List<Business_Reference__c>{
            new Business_Reference__c(
                id = mockBizRefId,
                Business_Vertical__c = mockBVId)
        };
                
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        BusinessVerticalsSelector bvidSelectorMock = (BusinessVerticalsSelector) mocks.mock(
            BusinessVerticalsSelector.class
        );

        mocks.startStubbing();
        mocks.when(bvidSelectorMock.sObjectType()).thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(bvidSelectorMock.selectById(bVIdSet)).thenReturn(bVIDList1);
        mocks.when(bvidSelectorMock.selectPrimaryVerticalRxRecord()).thenReturn(bVIDList1);
        mocks.stopStubbing();
		Application.SELECTOR.setMock(bvidSelectorMock);
        BusinessVerticalsService.populateBusinessVerticalDetails(businessRefList);
		
        System.assertEquals(mockBVId, updatedBusinessRefList[0].Business_Vertical__c, 'No bvid was set');
        
    }
}