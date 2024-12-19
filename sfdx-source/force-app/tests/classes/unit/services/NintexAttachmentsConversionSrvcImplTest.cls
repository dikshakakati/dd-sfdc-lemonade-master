/**
 * @author Deloitte
 * @date 08/23/2022
 * @description Test class for NintexAttachmentsConversionServiceImpl class.
 */
@isTest(seeAllData=false)
private class NintexAttachmentsConversionSrvcImplTest {
    private static final String ADMIN_USER_ALIAS = 'admUser';
    private static final String ADMIN_USER_EMAIL_ID = 'adminuser@testorg.com';
    private static final String ADMIN_USER_LAST_NAME = 'Testing';
    private static final String ADMIN_USER_USERNAME = 'adminuser@testorg.com.test';
    private static final String ATTACHMENT_BODY = 'NintexAttachmentsConversionSrvcImplTest Body';
    private static final String ATTACHMENT_DESCRIPTION = 'NintexAttachmentsConversionSrvcImplTest Description';
    private static final String ATTACHMENT_NAME = 'NintexAttachmentsConversionSrvcImplTestt_Menu_Nintex';
    private static final String EXCEPTION_MISMATCH_ASSERT_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String NINTEX_USER_ALIAS = 'ninUser';
    private static final String NINTEX_USER_EMAIL_ID = 'nintexUser@testorg.com';
    private static final String NINTEX_USER_USERNAME = System.Label.NintexUsername + '.test';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Testing';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'America/Los_Angeles';

    /**
     * @description To test conversion of Attachments to Files and deletion when
     * uploaded by Nintex integration user.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAttachmentsInsertedByNintexIntegrationUserThenAttachmentsConvertedToFilesAndDeleted() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class)
            .setFakeId()
            .setField(Attachment.Name, ATTACHMENT_NAME)
            .setField(Attachment.ParentId, storeAccountId)
            .toSObject();
        User nintexUser = new User(
            Alias = NINTEX_USER_ALIAS,
            Email = NINTEX_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = NINTEX_USER_USERNAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAttachmentsService mockAttachmentsService = (IAttachmentsService) mocks.mock(
            IAttachmentsService.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAttachmentsService.class, mockAttachmentsService);
        System.runAs(nintexUser) {
            NintexAttachmentsConversionService.convertAttachmentsToFiles(
                new List<Attachment>{ mockAttachment }
            );
        }
        ((IAttachmentsService) mocks.verify(mockAttachmentsService, 1))
            .convertToFiles(mockUOW, new List<Attachment>{ mockAttachment });
        ((IAttachmentsService) mocks.verify(mockAttachmentsService, 1))
            .remove(mockUOW, new List<Attachment>{ mockAttachment });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that when exception occurs in Attachments are inserted
     * then Attachment to File conversion fails.
     */
    @isTest
    private static void testWhenExceptionOccursInAttachmentsInsertionThenAttachmentToFileConversionFails() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String exceptionMessage;
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class)
            .setField(Attachment.Name, ATTACHMENT_NAME)
            .setField(Attachment.ParentId, storeAccountId)
            .toSObject();
        User nintexUser = new User(
            Alias = NINTEX_USER_ALIAS,
            Email = NINTEX_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = NINTEX_USER_USERNAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAttachmentsService mockAttachmentsService = (IAttachmentsService) mocks.mock(
            IAttachmentsService.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAttachmentsService.class, mockAttachmentsService);
        try {
            System.runAs(nintexUser) {
                NintexAttachmentsConversionService.convertAttachmentsToFiles(
                    new List<Attachment>{ mockAttachment }
                );
            }
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        System.assertEquals(
            MOCK_EXCEPTION_MESSAGE,
            exceptionMessage,
            EXCEPTION_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test there is no conversion of Attachments to Files when uploaded
     * by any user other than Nintex integration user.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAttachmentsInsertedByAdminUserThenAttachmentsConversionAndDeletionFails() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Attachment mockAttachment = (Attachment) new Fake(Attachment.class)
            .setFakeId()
            .setField(Attachment.Name, ATTACHMENT_NAME)
            .setField(Attachment.ParentId, storeAccountId)
            .toSObject();
        User adminUser = new User(
            Alias = ADMIN_USER_ALIAS,
            Email = ADMIN_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = ADMIN_USER_USERNAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAttachmentsService mockAttachmentsService = (IAttachmentsService) mocks.mock(
            IAttachmentsService.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAttachmentsService.class, mockAttachmentsService);
        System.runAs(adminUser) {
            NintexAttachmentsConversionService.convertAttachmentsToFiles(
                new List<Attachment>{ mockAttachment }
            );
        }
        ((IAttachmentsService) mocks.verify(mockAttachmentsService, 0))
            .convertToFiles(mockUOW, new List<Attachment>{ mockAttachment });
        ((IAttachmentsService) mocks.verify(mockAttachmentsService, 0))
            .remove(mockUOW, new List<Attachment>{ mockAttachment });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}