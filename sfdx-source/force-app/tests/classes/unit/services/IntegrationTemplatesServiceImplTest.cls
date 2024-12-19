/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Test class for IntegrationOutboundServiceImpl class.
 */
@isTest(SeeAllData=false)
public class IntegrationTemplatesServiceImplTest {
    private static final String ACCOUNT_ID_FIELD = 'AccountId';
    private static final String COMPARATOR_EQUALS = 'EQUALS';
    private static final String CRITERIA_NAME_LOGIC = '1 AND 2';
    private static final String CRITERIA_NAME_OPPORTUNITY_STAGE_CLOSED_WON = 'Opportunity Stage Closed Won';
    private static final String CRITERION_NAME_DM_CONTACT_EMAIL = 'DM Contact Email exists';
    private static final String CRITERION_NAME_OPPORTUNITY_NAME = 'Opportunity Name';
    private static final String CRITERION_RECORD_TYPE_NAME_CRITERION = 'Criterion';
    private static final String CRITERION_RECORD_TYPE_NAME_LOGIC = 'Logic';
    private static final String CRITERION_RECORD_TYPE_NAME_MERGE_FIELD = 'Merge Field Mapping';
    private static final String DM_CONTACT_EMAIL_FIELD_REFERENCE = 'Email';
    private static final String DM_CONTACT_EMAIL_FIELD_VALUE = 'test@test.com';
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String INITIATE_EMAIL_INTEGRATION = 'EMAIL_INTEGRATION_OUTBOUND';
    private static final String INTEGRATION_TEMPLATE_NAME = 'Opportunity_Closed_Won';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static final String OPPORTUNITY_DECISION_MAKER_METHOD = 'collectDecisionMakerContactDetails';
    private static final String OPPORTUNITY_NAME_FIELD_API_NAME = 'Name';
    private static final String OPPORTUNITY_NAME_FIELD_VALUE = 'Best Opportunity';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGENAME_FIELD_API_NAME = 'StageName';
    private static final String REFERENCE_TYPE_FIELD_API_NAME = 'Field API Name';
    private static final String REFERENCE_TYPE_SERVICE_METHOD_NAME = 'Service Method Name';
    private static final Integer RETRY_LIMIT = 5;
    private static final String SOBJECT_TYPE_OPPORTUNITY = 'Opportunity';

    /**
     * @description To test Interface Transaction record creation with email payloads
     * when sObject Ids received from platform event.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSObjectIdsReceivedFromPlatformEventThenInitiateEmailIntegration() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id integrationTemplateId = fflib_IDGenerator.generate(Integration_Template__c.SObjectType);
        List<Email_Outbound_Integration__e> emailOutboundEvents = new List<Email_Outbound_Integration__e>{
            new Email_Outbound_Integration__e(
                Topic__c = INITIATE_EMAIL_INTEGRATION,
                Payload__c = JSON.serialize(new Set<Id>{ opportunityId })
            )
        };
        Integration_Template__c mockIntegrationTemplate = (Integration_Template__c) new Fake(
                Integration_Template__c.class
            )
            .setField(Integration_Template__c.Id, integrationTemplateId)
            .setField(Integration_Template__c.Immediate_Communication__c, true)
            .setField(Integration_Template__c.Is_Active__c, true)
            .setField(Integration_Template__c.Name, INTEGRATION_TEMPLATE_NAME)
            .setField(Integration_Template__c.SObject_Type__c, SOBJECT_TYPE_OPPORTUNITY)
            .setChildren(
                'Criteria__r',
                new List<Fake>{
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERIA_NAME_OPPORTUNITY_STAGE_CLOSED_WON)
                        .setField(Criterion__c.Comparator__c, COMPARATOR_EQUALS)
                        .setField(Criterion__c.Field__c, OPPORTUNITY_STAGENAME_FIELD_API_NAME)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_FIELD_API_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(Criterion__c.Order_Number__c, 1)
                        .setField(Criterion__c.Value__c, OPPORTUNITY_STAGE_CLOSED_WON)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_CRITERION)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_DM_CONTACT_EMAIL)
                        .setField(Criterion__c.Comparator__c, COMPARATOR_EQUALS)
                        .setField(Criterion__c.Field__c, DM_CONTACT_EMAIL_FIELD_REFERENCE)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_SERVICE_METHOD_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(Criterion__c.Order_Number__c, 2)
                        .setField(
                            Criterion__c.Service_Method_Name__c,
                            OPPORTUNITY_DECISION_MAKER_METHOD
                        )
                        .setField(Criterion__c.Value__c, DM_CONTACT_EMAIL_FIELD_VALUE)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_CRITERION)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERIA_NAME_LOGIC)
                        .setField(Criterion__c.Criterion_Name__c, CRITERIA_NAME_LOGIC)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_LOGIC)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_OPPORTUNITY_NAME)
                        .setField(Criterion__c.Field__c, OPPORTUNITY_NAME_FIELD_API_NAME)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_FIELD_API_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_MERGE_FIELD)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_DM_CONTACT_EMAIL)
                        .setField(Criterion__c.Field__c, DM_CONTACT_EMAIL_FIELD_REFERENCE)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_SERVICE_METHOD_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(
                            Criterion__c.Service_Method_Name__c,
                            OPPORTUNITY_DECISION_MAKER_METHOD
                        )
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_MERGE_FIELD)
                        )
                }
            )
            .toSObject();
        Opportunity mockOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.Name, OPPORTUNITY_NAME_FIELD_VALUE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .toSObject();
        Contact mockContact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.Email, DM_CONTACT_EMAIL_FIELD_VALUE)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIntegrationTemplatesSelector mockIntegrationTemplatesSelector = (IIntegrationTemplatesSelector) mocks.mock(
            IIntegrationTemplatesSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        ICriteriaService mockCriteriaService = (ICriteriaService) mocks.mock(
            ICriteriaService.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(EMAIL_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = EMAIL_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = RETRY_LIMIT
                )
            );
        mocks.when(mockIntegrationTemplatesSelector.sObjectType())
            .thenReturn(Integration_Template__c.SObjectType);
        mocks.when(
                mockIntegrationTemplatesSelector.selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
                    new Set<String>{ SOBJECT_TYPE_OPPORTUNITY }
                )
            )
            .thenReturn(new List<Integration_Template__c>{ mockIntegrationTemplate });
        mocks.when(
                mockIntegrationTemplatesSelector.selectSObjectDetailsWithPassedFieldsByIds(
                    new Set<String>{
                        ACCOUNT_ID_FIELD,
                        OPPORTUNITY_STAGENAME_FIELD_API_NAME,
                        OPPORTUNITY_NAME_FIELD_API_NAME
                    },
                    new Set<Id>{ opportunityId },
                    SOBJECT_TYPE_OPPORTUNITY
                )
            )
            .thenReturn(new List<SObject>{ mockOpportunity });
        mocks.when(
                mockCriteriaService.collectDecisionMakerContactDetails(
                    new List<SObject>{ mockOpportunity },
                    new Set<String>{ DM_CONTACT_EMAIL_FIELD_REFERENCE }
                )
            )
            .thenReturn(
                new Map<Id, List<SObject>>{ opportunityId => new List<SObject>{ mockContact } }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockIntegrationTemplatesSelector);
        Application.SERVICE.setMock(ICriteriaService.class, mockCriteriaService);
        IntegrationTemplatesService.execute(emailOutboundEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Integration_Template__c => integrationTemplateId,
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => EMAIL_OUTBOUND_CONFIG_NAME,
                            Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Interface Transaction record creation with email payloads
     * when sObject record passes criteria evaluations.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCriteriaEvaluatesToTrueThenGenerateEmailPayloadAndCreateInterfaceTransaction() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id integrationTemplateId = fflib_IDGenerator.generate(Integration_Template__c.SObjectType);
        Integration_Template__c mockIntegrationTemplate = (Integration_Template__c) new Fake(
                Integration_Template__c.class
            )
            .setField(Integration_Template__c.Id, integrationTemplateId)
            .setField(Integration_Template__c.Immediate_Communication__c, true)
            .setField(Integration_Template__c.Is_Active__c, true)
            .setField(Integration_Template__c.Name, INTEGRATION_TEMPLATE_NAME)
            .setField(Integration_Template__c.SObject_Type__c, SOBJECT_TYPE_OPPORTUNITY)
            .setChildren(
                'Criteria__r',
                new List<Fake>{
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERIA_NAME_OPPORTUNITY_STAGE_CLOSED_WON)
                        .setField(Criterion__c.Comparator__c, COMPARATOR_EQUALS)
                        .setField(Criterion__c.Field__c, OPPORTUNITY_STAGENAME_FIELD_API_NAME)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_FIELD_API_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(Criterion__c.Order_Number__c, 1)
                        .setField(Criterion__c.Value__c, OPPORTUNITY_STAGE_CLOSED_WON)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_CRITERION)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_DM_CONTACT_EMAIL)
                        .setField(Criterion__c.Comparator__c, COMPARATOR_EQUALS)
                        .setField(Criterion__c.Field__c, DM_CONTACT_EMAIL_FIELD_REFERENCE)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_SERVICE_METHOD_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(Criterion__c.Order_Number__c, 2)
                        .setField(
                            Criterion__c.Service_Method_Name__c,
                            OPPORTUNITY_DECISION_MAKER_METHOD
                        )
                        .setField(Criterion__c.Value__c, DM_CONTACT_EMAIL_FIELD_VALUE)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_CRITERION)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERIA_NAME_LOGIC)
                        .setField(Criterion__c.Criterion_Name__c, CRITERIA_NAME_LOGIC)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_LOGIC)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_OPPORTUNITY_NAME)
                        .setField(Criterion__c.Field__c, OPPORTUNITY_NAME_FIELD_API_NAME)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_FIELD_API_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_MERGE_FIELD)
                        ),
                    new Fake(Criterion__c.class)
                        .setField(Criterion__c.Name, CRITERION_NAME_DM_CONTACT_EMAIL)
                        .setField(Criterion__c.Field__c, DM_CONTACT_EMAIL_FIELD_REFERENCE)
                        .setField(
                            Criterion__c.Field_Reference_Type__c,
                            REFERENCE_TYPE_SERVICE_METHOD_NAME
                        )
                        .setField(Criterion__c.Integration_Template__c, integrationTemplateId)
                        .setField(
                            Criterion__c.Service_Method_Name__c,
                            OPPORTUNITY_DECISION_MAKER_METHOD
                        )
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(RecordType.Name, CRITERION_RECORD_TYPE_NAME_MERGE_FIELD)
                        )
                }
            )
            .toSObject();
        Opportunity mockOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.Name, OPPORTUNITY_NAME_FIELD_VALUE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .toSObject();
        Contact mockContact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.Email, DM_CONTACT_EMAIL_FIELD_VALUE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIntegrationTemplatesSelector mockIntegrationTemplatesSelector = (IIntegrationTemplatesSelector) mocks.mock(
            IIntegrationTemplatesSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        ICriteriaService mockCriteriaService = (ICriteriaService) mocks.mock(
            ICriteriaService.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(EMAIL_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = EMAIL_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = RETRY_LIMIT
                )
            );
        mocks.when(mockIntegrationTemplatesSelector.sObjectType())
            .thenReturn(Integration_Template__c.SObjectType);
        mocks.when(
                mockIntegrationTemplatesSelector.selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
                    new Set<String>{ SOBJECT_TYPE_OPPORTUNITY }
                )
            )
            .thenReturn(new List<Integration_Template__c>{ mockIntegrationTemplate });
        mocks.when(
                mockIntegrationTemplatesSelector.selectSObjectDetailsWithPassedFieldsByIds(
                    new Set<String>{
                        ACCOUNT_ID_FIELD,
                        OPPORTUNITY_STAGENAME_FIELD_API_NAME,
                        OPPORTUNITY_NAME_FIELD_API_NAME
                    },
                    new Set<Id>{ opportunityId },
                    SOBJECT_TYPE_OPPORTUNITY
                )
            )
            .thenReturn(new List<SObject>{ mockOpportunity });
        mocks.when(
                mockCriteriaService.collectDecisionMakerContactDetails(
                    new List<SObject>{ mockOpportunity },
                    new Set<String>{ DM_CONTACT_EMAIL_FIELD_REFERENCE }
                )
            )
            .thenReturn(
                new Map<Id, List<SObject>>{ opportunityId => new List<SObject>{ mockContact } }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockIntegrationTemplatesSelector);
        Application.SERVICE.setMock(ICriteriaService.class, mockCriteriaService);
        IntegrationTemplatesService.initiateIntegrationTemplateCriteriaEvaluation(
            new Set<Id>{ opportunityId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Integration_Template__c => integrationTemplateId,
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => EMAIL_OUTBOUND_CONFIG_NAME,
                            Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}