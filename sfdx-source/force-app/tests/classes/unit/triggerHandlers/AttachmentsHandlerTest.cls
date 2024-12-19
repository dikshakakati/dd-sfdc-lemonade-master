/**
 * @author Deloitte
 * @date 08/19/2022
 * @description Test class for AttachmentsHandler class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class AttachmentsHandlerTest {
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';

    /**
     * @description To test when after insert called then after insert domain method is called.
     */
    @isTest
    private static void testWhenAttachmentAfterInsertIsCalledThenAfterInsertDomainMethodCalled() {
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class).setFakeId().toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexAttachmentsConversionService mockNintexAttachmentsConversionService = (INintexAttachmentsConversionService) mocks.mock(
            INintexAttachmentsConversionService.class
        );
        Application.SERVICE.setMock(
            INintexAttachmentsConversionService.class,
            mockNintexAttachmentsConversionService
        );
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Attachment>{ mockAttachment });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(AttachmentsHandler.class);
        ((INintexAttachmentsConversionService) mocks.verify(
                mockNintexAttachmentsConversionService,
                1
            ))
            .convertAttachmentsToFiles(new List<Attachment>{ mockAttachment });
    }
}