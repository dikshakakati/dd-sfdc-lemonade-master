/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Test class for MerchantOrdersServiceImpl class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class MxReturnLabelEmailServiceImplTest {
    private static final String ATTACHMENT_TITLE_AWB = 'AWB Label';
    private static final String ATTACHMENT_TITLE_INVOICE = 'Invoice Label';
    private static final String ATTACHMENT_TITLE_SHIPPING = 'Shipping Label';
    private static final String ASSERT_MESSAGE_EMAIL_NOT_SENT = 'Unexpected Result: Return Label email has not been sent to Mx.';
    private static final String CONTACT_NAME = 'Michael';
    private static final String CONTACT_EMAIL = 'VitoC@vitocorptest.com';
    private static final String MERCHANT_ORDER_ITEM_DYNAMIC_PLACEHOLDER = '<p>Merchant_Order_Items_For_Return_PlaceHolder</p>';
    private static final String MERCHANT_SUPPORT_EMAIL_DISPLAY_NAME = System.Label.Merchant_Support_Email_Display_Name;
    private static final String PRODUCT_NAME = 'Tablet';
    private static final String RETURN_LABEL_EMAIL_TEMPLATE = System.Label.Return_Label_Email_Template_Name;
    private static final String STATUS_RETURN_LABEL_GENERATED = 'Return Label Generated';

    /**
     * @description To test Tablet outbound integration is initiated when Tablet Mx Order is created.
     */
    @isTest
    private static void testWhenMxOrdersReceivedThenCollectReturnLabelsAndSendEmailToMx() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id mxOrderItemId = fflib_IDGenerator.generate(MX_Order_Item__c.SObjectType);
        Id mockAWBContentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id mockInvoiceContentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id mockShippingContentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Return_Label_Status__c, STATUS_RETURN_LABEL_GENERATED)
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.Name, CONTACT_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
            )
            .setChildren(
                'ContentDocumentLinks',
                new List<Fake>{
                    new Fake(ContentDocumentLink.class)
                        .setField(ContentDocumentLink.ContentDocumentId, mockAWBContentDocumentId),
                    new Fake(ContentDocumentLink.class)
                        .setField(
                            ContentDocumentLink.ContentDocumentId,
                            mockInvoiceContentDocumentId
                        ),
                    new Fake(ContentDocumentLink.class)
                        .setField(
                            ContentDocumentLink.ContentDocumentId,
                            mockShippingContentDocumentId
                        )
                }
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Id, mxOrderItemId)
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class).setField(Product2.Name, PRODUCT_NAME)
                        )
                }
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersionsSelector mockContentVersionsSelector = (IContentVersionsSelector) mocks.mock(
            IContentVersionsSelector.class
        );
        IOrgWideEmailAddressesSelector mockOrgWideEmailAddressSelector = (IOrgWideEmailAddressesSelector) mocks.mock(
            IOrgWideEmailAddressesSelector.class
        );
        IEmailTemplateSelector mockEmailTemplateSelector = (IEmailTemplateSelector) mocks.mock(
            IEmailTemplateSelector.class
        );
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(mockContentVersionsSelector.sObjectType())
            .thenReturn(ContentVersion.SObjectType);
        mocks.when(
                mockContentVersionsSelector.selectByContentDocumentIds(
                    new Set<Id>{
                        mockAWBContentDocumentId,
                        mockInvoiceContentDocumentId,
                        mockShippingContentDocumentId
                    }
                )
            )
            .thenReturn(
                new List<ContentVersion>{
                    new ContentVersion(
                        ContentDocumentId = mockAWBContentDocumentId,
                        Title = ATTACHMENT_TITLE_AWB,
                        VersionData = Blob.valueof(ATTACHMENT_TITLE_AWB)
                    ),
                    new ContentVersion(
                        ContentDocumentId = mockInvoiceContentDocumentId,
                        Title = ATTACHMENT_TITLE_INVOICE,
                        VersionData = Blob.valueof(ATTACHMENT_TITLE_INVOICE)
                    ),
                    new ContentVersion(
                        ContentDocumentId = mockShippingContentDocumentId,
                        Title = ATTACHMENT_TITLE_SHIPPING,
                        VersionData = Blob.valueof(ATTACHMENT_TITLE_SHIPPING)
                    )
                }
            );
        mocks.when(mockOrgWideEmailAddressSelector.sObjectType())
            .thenReturn(OrgWideEmailAddress.SObjectType);
        mocks.when(
                mockOrgWideEmailAddressSelector.selectOrgWideAddressByDisplayNames(
                    new Set<String>{ MERCHANT_SUPPORT_EMAIL_DISPLAY_NAME }
                )
            )
            .thenReturn(
                new List<OrgWideEmailAddress>{ new OrgWideEmailAddress(Id = mockOrgWideAddressId) }
            );
        mocks.when(mockEmailTemplateSelector.sObjectType()).thenReturn(EmailTemplate.SObjectType);
        mocks.when(
                mockEmailTemplateSelector.selectByTemplateNames(
                    new Set<String>{ RETURN_LABEL_EMAIL_TEMPLATE }
                )
            )
            .thenReturn(
                new List<EmailTemplate>{
                    new EmailTemplate(
                        Id = mockEmailTemplateId,
                        HtmlValue = MERCHANT_ORDER_ITEM_DYNAMIC_PLACEHOLDER
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContentVersionsSelector);
        Application.SELECTOR.setMock(mockOrgWideEmailAddressSelector);
        Application.SELECTOR.setMock(mockEmailTemplateSelector);
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);

        Test.StartTest();
        MxReturnLabelEmailService.sendReturnLabelEmailsToMerchants(
            new List<MX_Order__c>{ mockMxOrder }
        );
        Test.stopTest();
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .updateMxOrdersReturnLabelStatusBasedOnEmailResults(
                new Set<Id>{ mockMxOrder.Id },
                new Set<Id>()
            );
    }
}