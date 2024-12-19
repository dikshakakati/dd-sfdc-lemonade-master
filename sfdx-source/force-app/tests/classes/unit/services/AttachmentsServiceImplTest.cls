/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Test class for AttachmentsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class AttachmentsServiceImplTest {
    private static final String ATTACHMENT_BODY = 'AttachmentsServiceImplTest Body';
    private static final String ATTACHMENT_DESCRIPTION = 'AttachmentsServiceImplTest Description';
    private static final String ATTACHMENT_NAME = 'AttachmentsServiceImplTest_Menu_Nintex';
    private static final String EXCEPTION_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: The Exception fired was not a TestCommitException';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';

    /**
     * @description To test conversion of Attachments to Files related to the Account.
     */
    @isTest
    private static void testWhenConvertToFilesCalledThenConvertAttachmentsToFiles() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id attachmentId = fflib_IDGenerator.generate(Attachment.SObjectType);
        List<Attachment> mockAttachments = new List<Attachment>{
            new Attachment(
                Id = attachmentId,
                Name = ATTACHMENT_NAME,
                Description = ATTACHMENT_DESCRIPTION,
                Body = Blob.valueOf(ATTACHMENT_BODY),
                ParentId = storeAccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AttachmentsService.convertToFiles(mockAttachments);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        ContentVersion.Title => ATTACHMENT_NAME,
                        ContentVersion.FirstPublishLocationId => storeAccountId
                    }
                )
            );
    }

    /**
     * @description To test conversion of Attachments related to the Account
     * to Files when Unit of Work instance is passed.
     */
    @isTest
    private static void testWhenConvertToFilesWithUOWCalledThenConvertAttachmentsToFiles() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id attachmentId = fflib_IDGenerator.generate(Attachment.SObjectType);
        List<Attachment> mockAttachments = new List<Attachment>{
            new Attachment(
                Id = attachmentId,
                Name = ATTACHMENT_NAME,
                Description = ATTACHMENT_DESCRIPTION,
                Body = Blob.valueOf(ATTACHMENT_BODY),
                ParentId = storeAccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AttachmentsService.convertToFiles(mockUOW, mockAttachments);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        ContentVersion.Title => ATTACHMENT_NAME,
                        ContentVersion.FirstPublishLocationId => storeAccountId
                    }
                )
            );
    }

    /**
     * @description To test conversion of Attachments to Files and deletion when
     * uploaded by Nintex integration user.
     */
    @isTest
    private static void testWhenRemoveCalledThenAttachmentsAreDeleted() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class)
            .setFakeId()
            .setField(Attachment.Name, ATTACHMENT_NAME)
            .setField(Attachment.ParentId, storeAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AttachmentsService.remove(new List<Attachment>{ mockAttachment });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Attachment.Id => mockAttachment.Id }
                )
            );
    }

    /**
     * @description To test deletion of Attachments related to the Account
     * to Files when Unit of Work instance is passed.
     */
    @isTest
    private static void testWhenRemoveWithUOWCalledThenAttachmentsAreDeleted() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class)
            .setFakeId()
            .setField(Attachment.Name, ATTACHMENT_NAME)
            .setField(Attachment.ParentId, storeAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AttachmentsService.remove(mockUOW, new List<Attachment>{ mockAttachment });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Attachment.Id => mockAttachment.Id }
                )
            );
    }
}