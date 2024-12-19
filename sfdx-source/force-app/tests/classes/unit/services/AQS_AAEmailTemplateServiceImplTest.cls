/**
 * @author atg
 * @date 5/19/2022
 * @description Test class used to cover AQS_AAEmailTemplateService and
 * AQS_AAEmailTemplateServiceImpl classes.
 */
@isTest
public with sharing class AQS_AAEmailTemplateServiceImplTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCreateTemplatesThenTemplatesCreated() {
        Id emailTemplateId1 = Fake.generateId( EmailTemplate.class );
        Id emailTemplateId2 = Fake.generateId( EmailTemplate.class );

        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>{
			new EmailTemplate(Id = emailTemplateId1, Name = 'emailTemplateId1'),
			new EmailTemplate(Id = emailTemplateId2, Name = 'emailTemplateId2')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = ( fflib_ISObjectUnitOfWork ) mocks.mock( fflib_ISObjectUnitOfWork.class );
        Application.UNITOFWORK.setMock( mockUOW );

        AQS_AAEmailTemplateService.createTemplates(emailTemplateList);

        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                sbaa__EmailTemplate__c.Name => 'emailTemplateId1',
                sbaa__EmailTemplate__c.sbaa__templateID__c => emailTemplateId1
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                sbaa__EmailTemplate__c.Name => 'emailTemplateId2',
                sbaa__EmailTemplate__c.sbaa__templateID__c => emailTemplateId2
            }
        ) );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmptyTemplateListThenNoTemplatesCreated() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = ( fflib_ISObjectUnitOfWork ) mocks.mock( fflib_ISObjectUnitOfWork.class );
        Application.UNITOFWORK.setMock( mockUOW );

        AQS_AAEmailTemplateService.createTemplates(new List<EmailTemplate>());

        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 0 ) ).registerNew( fflib_Match.anysObject() );
    }
}