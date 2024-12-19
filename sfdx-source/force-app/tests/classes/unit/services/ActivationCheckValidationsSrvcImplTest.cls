/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Test class for ActivationCheckValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount, PMD.NcssTypeCount')
public class ActivationCheckValidationsSrvcImplTest {
    private static final String FAILURE_STATUS_RESULT = 'Failed';
    private static final String PRODUCT_EXPERIENCE_ANY = 'ANY_EXPERIENCE';
    private static final String PRODUCT_CHANNEL_ANY = 'ANY_CHANNEL';
    private static final String PRODUCT_FULFILLMENT_TYPE_ANY = 'ANY_FULFILLMENT_TYPE';
    private static final String PRODUCT_AUDIENCE_ANY = 'ANY_AUDIENCE';
    private static final String STORE_PARTNERSHIP_PRICING_PROGRAM = 'Store Partnership';
    private static final String SUCCESS_STATUS_RESULT = 'Passed';
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';

    /**
     * @description To test Activation Checklist record is created with success status when
     * Merchant Supplied Id validation passes.
     */
    @isTest
    private static void testWhenMerchantSuppliedIdValidationPassesThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        String mockMerchantSuppliedId = 'mockMerchantSuppliedId';
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.Error errorInformation = new ActivationChecklistWrapper.Error(
            'test',
            'test',
            'test'
        );
        mockStoreInformation.merchantSuppliedId = mockMerchantSuppliedId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        mockActivationChecklistData.errors = new List<ActivationChecklistWrapper.Error>{
            errorInformation
        };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Merchant_Supplied_ID__c, mockMerchantSuppliedId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(Activation_Checklist_Validation__mdt.Activation_Validation_Name__c, 'MSID')
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'MSID on store in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'MSID on store in SFDMSID on store in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateMerchantSuppliedId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Merchant Supplied Id validation fails.
     */
    @isTest
    private static void testWhenMerchantSuppliedIdValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        String mintMerchantSuppliedId = 'mintMerchantSuppliedId';
        String sfdcMerchantSuppliedId = 'sfdcMerchantSuppliedId';
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.merchantSuppliedId = mintMerchantSuppliedId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Merchant_Supplied_ID__c, sfdcMerchantSuppliedId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(Activation_Checklist_Validation__mdt.Activation_Validation_Name__c, 'MSID')
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'MSID on store in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'MSID on store in SFDMSID on store in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateMerchantSuppliedId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Submarket Id validation passes.
     */
    @isTest
    private static void testWhenSubmarketIDValidationPassesThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id submarketID = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        String mockSubmarketID = String.valueOf(submarketID).substring(0, 6);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.submarketId = mockSubmarketID;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.SubMarket__c, mockSubmarketID)
            .setParent(
                'SubMarket__r',
                new Fake(Submarket__c.class).setField(Submarket__c.Submarket_Id__c, mockSubmarketID)
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Submarket'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Submarket from SFDC and from MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Submarket from SFDC = Submarket from MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateSubmarket'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<String>{ (String) storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * SUBMARKET ID validation fails.
     */
    @isTest
    private static void testWhenSubmarketIDValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id subMarketID = fflib_IDGenerator.generate(SubMarket__c.SObjectType);
        Id mintSubmarketID = fflib_IDGenerator.generate(SubMarket__c.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        String mockSubmarketID = String.valueOf(mintSubmarketID).substring(0, 6);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.submarketId = mockSubmarketID;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.SubMarket__c, subMarketID);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Submarket'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Submarket from SFDC and from MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Submarket from SFDC = Submarket from MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateSubmarket'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Starting Point Id validation passes.
     */
    @isTest
    private static void testWhenStartingPointIdValidationPassesThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String mockStartingPointId = '2.0';
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.startingPointId = mockStartingPointId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Starting_Point_ID__c, 2);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Starting_Point_Id'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Starting Point in SFDC and in MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Starting Point in SFDC = Starting Point in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateStartingPointId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Starting Point Id validation fails.
     */
    @isTest
    private static void testWhenStartingPointIdValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String mockStartingPointId = '2.0';
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.startingPointId = mockStartingPointId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Starting_Point_ID__c, 3);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Starting_Point_Id'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Starting Point in SFDC and in MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Starting Point in SFDC = Starting Point in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateStartingPointId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * PDOA validation fails.
     */
    @isTest
    private static void testWhenPDOAValidationfailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Date proposedDateOfActivation = system.today().addDays(2);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, proposedDateOfActivation);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };

        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(Activation_Checklist_Validation__mdt.Activation_Validation_Name__c, 'PDOA')
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'PDOA is in the future'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'PDOA is today or in the past'
            )
            .setField(Activation_Checklist_Validation__mdt.Service_Method_Name__c, 'validatePDOA')
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setParent(
                'WorkPlan',
                new Fake(WorkPlan.class)
                    .setField(WorkPlan.Id, workPlanId)
                    .setParent(
                        'WorkOrder',
                        new Fake(WorkOrder.class)
                            .setParent(
                                'ParentWorkOrder',
                                new Fake(WorkOrder.class)
                                    .setField(
                                        WorkOrder.Proposed_Date_of_Activation__c,
                                        proposedDateOfActivation
                                    )
                            )
                    )
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * PDOA validation passes.
     */
    @isTest
    private static void testWhenPDOAValidationPassesThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Date proposedDateOfActivation = system.today().addDays(-2);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, proposedDateOfActivation);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(Activation_Checklist_Validation__mdt.Activation_Validation_Name__c, 'PDOA')
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'PDOA is in the future'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'PDOA is today or in the past'
            )
            .setField(Activation_Checklist_Validation__mdt.Service_Method_Name__c, 'validatePDOA')
            .setFakeId();
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setParent(
                'WorkPlan',
                new Fake(WorkPlan.class)
                    .setField(WorkPlan.Id, workPlanId)
                    .setParent(
                        'WorkOrder',
                        new Fake(WorkOrder.class)
                            .setParent(
                                'ParentWorkOrder',
                                new Fake(WorkOrder.class)
                                    .setField(
                                        WorkOrder.Proposed_Date_of_Activation__c,
                                        proposedDateOfActivation
                                    )
                            )
                    )
            )
            .toSObject();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ mockWorkStep });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Business is active.
     */
    @isTest
    private static void testWhenBusinessIsActiveThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Date proposedDateOfActivation = system.today().addDays(-2);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetBusinessDetails mockBusinessDetails = new ActivationChecklistWrapper.GetBusinessDetails();
        mockBusinessDetails.active = 'true';
        mockActivationChecklistData.businessInformation = mockBusinessDetails;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, proposedDateOfActivation);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Business Is Active'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(Activation_Checklist_Validation__mdt.Error_Message__c, 'Business is inactive')
            .setField(Activation_Checklist_Validation__mdt.Success_Message__c, 'Business is active')
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBusinessIsActive'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Business is inactive.
     */
    @isTest
    private static void testWhenBusinessIsInactiveThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Date proposedDateOfActivation = system.today().addDays(-2);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetBusinessDetails mockBusinessDetails = new ActivationChecklistWrapper.GetBusinessDetails();
        mockBusinessDetails.active = 'false';
        mockActivationChecklistData.businessInformation = mockBusinessDetails;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, proposedDateOfActivation);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Business Is Active'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(Activation_Checklist_Validation__mdt.Error_Message__c, 'Business is inactive')
            .setField(Activation_Checklist_Validation__mdt.Success_Message__c, 'Business is active')
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBusinessIsActive'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * charges enabled in payment account.
     */
    @isTest
    private static void testWhenChargesEnabledInPaymentAccountThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetPayment mockPaymentAccountInformation = new ActivationChecklistWrapper.GetPayment();
        mockPaymentAccountInformation.charges_enabled = 'true';
        mockPaymentAccountInformation.transfers_enabled = 'true';
        mockActivationChecklistData.paymentAccountInformation = mockPaymentAccountInformation;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Banking Information'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Charges and/or transfers are not enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Charges and transfers are enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBankingInformation'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * charges disabled in payment account.
     */
    @isTest
    private static void testWhenChargesDisabledInPaymentAccountThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetPayment mockPaymentAccountInformation = new ActivationChecklistWrapper.GetPayment();
        mockPaymentAccountInformation.charges_enabled = 'false';
        mockActivationChecklistData.paymentAccountInformation = mockPaymentAccountInformation;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Banking Information'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Charges and/or transfers are not enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Charges and transfers are enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBankingInformation'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * store is partner.
     */
    @isTest
    private static void testWhenStoreIsPartnerThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        List<ActivationChecklistWrapper.GetPricingPrograms> mockpricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>();
        ActivationChecklistWrapper.GetProducts mockGetProducts = new ActivationChecklistWrapper.GetProducts();
        mockpricingPrograms.add(new ActivationChecklistWrapper.GetPricingPrograms());
        mockpricingPrograms[0].isPartner = true;
        mockpricingPrograms[0].sourceId = STORE_PARTNERSHIP_PRICING_PROGRAM;
        mockGetProducts.experience = PRODUCT_EXPERIENCE_ANY;
        mockGetProducts.channel = PRODUCT_CHANNEL_ANY;
        mockGetProducts.fulfillmentType = PRODUCT_FULFILLMENT_TYPE_ANY;
        mockGetProducts.audience = PRODUCT_AUDIENCE_ANY;
        mockpricingPrograms[0].productInformation = mockGetProducts;
        mockActivationChecklistData.pricingPrograms = mockpricingPrograms;

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Store Is Partner'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(Activation_Checklist_Validation__mdt.Error_Message__c, 'Is Partner = false')
            .setField(Activation_Checklist_Validation__mdt.Success_Message__c, 'Is Partner = true')
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateStoreIsPartner'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * store is not partner.
     */
    @isTest
    private static void testWhenStoreIsNotPartnerThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);
        List<ActivationChecklistWrapper.GetPricingPrograms> mockpricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>();
        mockpricingPrograms.add(new ActivationChecklistWrapper.GetPricingPrograms());
        mockpricingPrograms[0].isPartner = false;
        mockActivationChecklistData.pricingPrograms = mockpricingPrograms;

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Store Is Partner'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(Activation_Checklist_Validation__mdt.Error_Message__c, 'Is Partner = false')
            .setField(Activation_Checklist_Validation__mdt.Success_Message__c, 'Is Partner = true')
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateStoreIsPartner'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * order protocol validation passes.
     */
    @isTest
    private static void testWhenOrderProtocolValidationPassesThenCreateActivationChecklistWithPassedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.orderProtocol = 'Email';
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.Order_Protocol__c, 'Email')
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Order Protocol'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Order protocol in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Order protocol in SFDC and MINT match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateOrderProtocol'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * order protocol validation fails.
     */
    @isTest
    private static void testWhenOrderProtocolValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.orderProtocol = 'Email';
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.Order_Protocol__c, 'POS')
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Order Protocol'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Order protocol in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Order protocol in SFDC and MINT match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateOrderProtocol'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Business Id validation passes.
     */
    @isTest
    private static void testWhenBusinessIdValidationPassesThenCreateActivationChecklistWithPassedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        String mockBusinessId = 'mockBusinessId';
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.businessId = mockBusinessId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_ID__c, storeAccount.Id)
            .setField(Xref__c.BusinessID__c, mockBusinessId);
        Xref__c mockXref = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Business ID'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Business ID in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Business ID on Xref = Business ID in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBusinessId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectByUltimateParentAccountsforActivationValidation(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Business Id validation fails.
     */
    @isTest
    private static void testWhenBusinessIdValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        String mockBusinessId = 'mockBusinessId';
        String mintBusinessId = 'mintBusinessId';
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.businessId = mintBusinessId;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_ID__c, storeAccount.Id)
            .setField(Xref__c.BusinessID__c, mockBusinessId);
        Xref__c mockXref = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Business ID'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Business ID in SFDC and MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Business ID on Xref = Business ID in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateBusinessId'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefSelector.selectByUltimateParentAccountsforActivationValidation(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Tier Level validation passes.
     */
    @isTest
    private static void testWhenTierLevelValidationPassesThenCreateActivationChecklistWithPassedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.tierLevel = String.valueOf(Integer.valueOf(1.0));
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = new Fake(Order.class)
            .setField(Order.Id, orderId)
            .setField(Order.AccountId, storeAccount.Id)
            .setField(Order.Pricing_Tier__c, 1);
        Order mockOrder = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Tier Level'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Pricing Tier on Services on Store and Tier Level in MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Pricing Tier on Services on Store = Tier Level in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateTierLevel'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        mocks.startStubbing();
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                mockOrdersSelector.selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Order>{ mockOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Tier Level validation fails.
     */
    @isTest
    private static void testWhenTierLevelValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        String mockTierLevel = '1';
        String mintTierLevel = '2';
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.tierLevel = mintTierLevel;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = new Fake(Order.class)
            .setField(Order.Id, orderId)
            .setField(Order.AccountId, storeAccount.Id)
            .setField(Order.Pricing_Tier__c, mockTierLevel);
        Order mockOrder = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Tier Level'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Pricing Tier on Services on Store and Tier Level in MINT do not match'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Pricing Tier on Services on Store = Tier Level in MINT'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateTierLevel'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        mocks.startStubbing();
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                mockOrdersSelector.selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Order>{ mockOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * Menu is active.
     */
    @isTest
    private static void testWhenMenuIsActiveThenCreateActivationChecklistWithSuccessStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetMenu mockMenuInformation = new ActivationChecklistWrapper.GetMenu();
        mockMenuInformation.isMenuActive = 'true';
        mockActivationChecklistData.menuInformation = mockMenuInformation;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Active Menu Count'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Charges and/or transfers are not enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'An active menu exists'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateActiveMenuCount'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * Menu is not active.
     */
    @isTest
    private static void testWhenMenuIsInactiveThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetMenu mockMenuInformation = new ActivationChecklistWrapper.GetMenu();
        mockMenuInformation.isMenuActive = 'false';
        mockActivationChecklistData.menuInformation = mockMenuInformation;
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Active Menu Count'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Charges and/or transfers are not enabled'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'An active menu exists'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateActiveMenuCount'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with success status when
     * pick up validation passes
     */
    @isTest
    private static void testWhenPickUpValidationPassesThenCreateActivationChecklistWithPassedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        String mockSubmarketID = String.valueOf(submarketID);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        mockStoreInformation.offersPickup = 'true';
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'SubMarket__r',
                new Fake(Submarket__c.class).setField(Submarket__c.Submarket_Id__c, mockSubmarketID)
            )
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class).setField(Merchant_Service__c.Name, 'Pickup')
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Offers Pickup/Delivery'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Does not offer pickup, delivery or Dashpass'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Offers Pickup, Delivery, and/or Dashpass'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateOffersPickupDeliveryDashpass'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectAccountsWithServices(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(
                mockAccountsSelector.selectById(new Set<String>{ String.valueOf(storeAccount.Id) })
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => SUCCESS_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Success_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Activation Checklist record is created with failed status when
     * pick up validation fails.
     */
    @isTest
    private static void testWhenPickUpValidationFailsThenCreateActivationChecklistWithFailedStatus() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        String mockSubmarketID = String.valueOf(submarketID).substring(0, 6);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetStore mockStoreInformation = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.GetPointOfSales mockPointSales = new ActivationChecklistWrapper.GetPointOfSales(
            'test',
            'test',
            'test',
            'test'
        );

        mockStoreInformation.offersPickup = 'false';
        mockActivationChecklistData.storeInformation = mockStoreInformation;
        mockActivationChecklistData.posInformation = mockPointSales;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'SubMarket__r',
                new Fake(Submarket__c.class).setField(Submarket__c.Submarket_Id__c, mockSubmarketID)
            )
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class).setField(Merchant_Service__c.Name, 'Pickup')
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, ActivationChecklistWrapper> storeIdToMintStoreAccounts = new Map<Id, ActivationChecklistWrapper>{
            storeAccount.Id => mockActivationChecklistData
        };
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                'Offers Pickup/Delivery'
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(
                Activation_Checklist_Validation__mdt.Error_Message__c,
                'Does not offer pickup, delivery or Dashpass'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                'Offers Pickup, Delivery, and/or Dashpass'
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                'validateOffersPickupDeliveryDashpass'
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansService serviceMock = (IWorkPlansService) mocks.mock(IWorkPlansService.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectAccountsWithServices(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(
                mockAccountsSelector.selectById(new Set<String>{ String.valueOf(storeAccount.Id) })
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.when(mockWorkStepsSelector.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Store_Account__c = storeAccount.Id,
                        WorkPlanId = workPlanId
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkPlansService.class, serviceMock);
        Test.startTest();
        ActivationCheckValidationsService.validateStoreAccount(
            new List<Account>{ storeAccount },
            storeIdToMintStoreAccounts,
            activationChecklistValidations
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Activation_Checklist__c.Activation_Validation_Name__c => mockActivationChecklistValidation.Activation_Validation_Name__c,
                            Activation_Checklist__c.Store_Account__c => storeAccount.Id,
                            Activation_Checklist__c.Work_Plan__c => null,
                            Activation_Checklist__c.Parent_Work_Step__c => null,
                            Activation_Checklist__c.Work_Step__c => workStepId,
                            Activation_Checklist__c.Status__c => FAILURE_STATUS_RESULT,
                            Activation_Checklist__c.Result__c => mockActivationChecklistValidation.Error_Message__c
                        }
                    }
                )
            );
        ((IWorkPlansService) mocks.verify(serviceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => WORK_STEP_STATUS_ESCALATED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }
}