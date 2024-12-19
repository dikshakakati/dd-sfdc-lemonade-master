/**
 * @author Deloitte
 * @date 08/04/2022
 * @description This is test class for ContentDocumentLinkSelector class
 */
@isTest(seeAllData=false)
public class ContentDocumentLinkSelectorTest {
    @isTest
    private static void testWhenClassInstantiatesThenCallSobjectFieldList() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        ContentVersion contentRecord = new ContentVersion();
        contentRecord.Title = 'Header_Picture1';
        contentRecord.PathOnClient = '/' + contentRecord.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentRecord.VersionData = bodyBlob;
        contentRecord.origin = 'H';
        insert contentRecord;

        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = opportunityList[0].Id;
        contentlink1.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecord.Id
        ]
        .contentdocumentid;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers';
        insert contentlink1;

        ContentDocumentLinkSelector contentDocumentLinkInstance = new ContentDocumentLinkSelector();

        List<ContentDocumentLink> contentLinkRecord = contentDocumentLinkInstance.selectById(
            new Set<Id>{ contentlink1.Id }
        );
        List<Schema.SObjectField> fieldList = contentDocumentLinkInstance.getSObjectFieldList();

        ContentDocumentLinkSelector.newInstance();

        System.assertEquals(
            new List<Schema.SObjectField>{
                ContentDocumentLink.Id,
                ContentDocumentLink.LinkedEntityId
            },
            fieldList,
            'Mismatch in field list'
        );
        System.assert(contentLinkRecord != null, 'The list does not contain any opportunities');
    }

    @isTest
    private static void testWhenClassInstantiatesThenCallSobjectType() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        ContentVersion contentRecord = new ContentVersion();
        contentRecord.Title = 'Header_Picture1';
        contentRecord.PathOnClient = '/' + contentRecord.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentRecord.VersionData = bodyBlob;
        contentRecord.origin = 'H';
        insert contentRecord;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = opportunityList[0].Id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecord.Id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        ContentDocumentLinkSelector contentDocumentLinkInstance = new ContentDocumentLinkSelector();

        Schema.SObjectType typeOfObj = contentDocumentLinkInstance.getSObjectType();

        ContentDocumentLinkSelector.newInstance();

        System.assertEquals(
            Schema.ContentDocumentLink.SObjectType,
            typeOfObj,
            'The object type must be Content Document Link'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenClassCallsSelectNotesByMethodThenReturnContentLink() {
        Integer numberOfDays = 120;
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise')
        };
        insert accountList;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;
        Set<Id> opportunityId = new Set<Id>{ opportunityList[0].Id };
        ContentVersion contentRecord = new ContentVersion();
        contentRecord.Title = 'Header_Picture1';
        contentRecord.PathOnClient = '/' + contentRecord.Title + '.SNOTE';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentRecord.VersionData = bodyBlob;
        contentRecord.origin = 'H';
        insert contentRecord;
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = opportunityList[0].Id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecord.Id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        ContentDocumentLinkSelector contentDocumentSelector = new ContentDocumentLinkSelector();
        List<ContentDocumentLink> documentLink = contentDocumentSelector.selectNotesByLinkedEntityAndLastModifiedDate(
            opportunityId,
            numberOfDays
        );
        System.assertEquals(
            documentLink[0].Id,
            contentlink.Id,
            'The Content Document Link Record does not match'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectCompletedTitlesByLinkedEntityThenReturnCorrectData() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);

        ContentVersion contentRecord = new ContentVersion();
        contentRecord.Title = 'Q-01378_completed.pdf';
        contentRecord.PathOnClient = 'Q-01378_completed.pdf';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentRecord.VersionData = bodyBlob;
        contentRecord.origin = 'H';
        insert contentRecord;

        ContentVersion contentRecordNotComplete = new ContentVersion();
        contentRecordNotComplete.Title = 'Q-01378.pdf';
        contentRecordNotComplete.PathOnClient = 'Q-01378.pdf';
        contentRecordNotComplete.VersionData = bodyBlob;
        contentRecordNotComplete.origin = 'H';
        insert contentRecordNotComplete;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = quote.Id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecord.Id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        ContentDocumentLink contentlinkNotCompleted = new ContentDocumentLink();
        contentlinkNotCompleted.LinkedEntityId = quote.Id;
        contentlinkNotCompleted.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecordNotComplete.Id
        ]
        .contentdocumentid;
        contentlinkNotCompleted.ShareType = 'I';
        contentlinkNotCompleted.Visibility = 'AllUsers';
        insert contentlinkNotCompleted;

        ContentDocumentLinkSelector contentDocumentSelector = new ContentDocumentLinkSelector();

        List<ContentDocumentLink> documentLink = contentDocumentSelector.selectCompletedTitlesByLinkedEntity(
            new Set<Id>{ quote.Id }
        );

        System.assertEquals(documentLink.size(), 1, 'Only 1 record should match');
    }

    @isTest
    private static void testWhenSelectDraftIOTemplateTitlesByLinkedEntityThenReturnCorrectData() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);

        ContentVersion contentRecord = new ContentVersion();
        contentRecord.Title = 'Insertion_Order_for_Q-01378.pdf';
        contentRecord.PathOnClient = 'Insertion_Order_for_Q-01378.pdf';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentRecord.VersionData = bodyBlob;
        contentRecord.origin = 'H';
        insert contentRecord;

        ContentVersion contentRecordNotComplete = new ContentVersion();
        contentRecordNotComplete.Title = 'Q-01378.pdf';
        contentRecordNotComplete.PathOnClient = 'Q-01378.pdf';
        contentRecordNotComplete.VersionData = bodyBlob;
        contentRecordNotComplete.origin = 'H';
        insert contentRecordNotComplete;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = quote.Id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecord.Id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        ContentDocumentLink contentlinkNotCompleted = new ContentDocumentLink();
        contentlinkNotCompleted.LinkedEntityId = quote.Id;
        contentlinkNotCompleted.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE Id = :contentRecordNotComplete.Id
        ]
        .contentdocumentid;
        contentlinkNotCompleted.ShareType = 'I';
        contentlinkNotCompleted.Visibility = 'AllUsers';
        insert contentlinkNotCompleted;

        ContentDocumentLinkSelector contentDocumentSelector = new ContentDocumentLinkSelector();

        List<ContentDocumentLink> documentLink = contentDocumentSelector.selectDraftIOTemplates(
            new Set<Id>{quote.Id}
        );

        System.assertEquals(documentLink.size(), 1, 'Only 1 record should match');
    }
}