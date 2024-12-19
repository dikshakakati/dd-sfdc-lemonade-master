/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Service implementation class for StoresOnWorkPlanController related logic.
 */
public inherited sharing class StoresOnWorkPlansServiceImpl implements IStoresOnWorkPlansService {
    private static final String ACCOUNTCONTACTRELATIONSHIP_OBJECT_NAME = 'AccountContactRelation';
    private static final String ACCOUNT_DETAILS_SECTION_NAME = 'Account Details';
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String ACCOUNT_PAYMENT_ACCOUNT_RELATION_OBJECT_NAME = 'Account_Payment_Account_Relation__c';
    private static final String ACCOUNT_PAYMENT_ACCOUNT_RELATION_RELATIONSHIP_NAME = 'Account_Payment_Account_Relations__r';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String AGREEMENT_OBJECT_NAME = 'Agreement__c';
    private static final String AGREEMENT_RELATIONSHIP_NAME = 'Agreements__r';
    private static final String AGREEMENT_TYPE_FRANCHISE = 'Franchise Agreement';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement';
    private static final String BANKING_INFORMATION_SECTION_NAME = 'Banking Details';
    private static final String CONTACT_OBJECT_NAME = 'Contact';
    private static final String CONTRACT_OBJECT_NAME = 'Contract';
    private static final String CONTRACT_RELATIONSHIP_NAME = 'Contracts';
    private static final String MX_ORDER_OBJECT_NAME = 'MX_Order__c';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String OPPORTUNITYCONTACTROLE_OBJECT_NAME = 'OpportunityContactRole';
    private static final String ORDERITEM_OBJECT_NAME = 'OrderItem';
    private static final String PAYMENT_ACCOUNT_BILLING_CONTACT_NAME_FIELD = 'Billing_Contact_Name__c';
    private static final String PAYMENT_ACCOUNT_OBJECT_NAME = 'Payment_Account__c';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_FIELD = 'Record_Type__c';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_RELATIONSHIP_NAME = 'Payment_Account__r';
    private static final String SPLIT_DELIMETER = ',';
    private static final String XREF_EXTERNAL_ID_SOURCE_DRIVEDB = 'DriveDb';
    private static final String XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String XREF_OBJECT_NAME = 'Xref__c';
    private static final String XREF_RELATIONSHIP_NAME = 'Xrefs__r';
    private static final String VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION = 'View_Encrypted_Banking_Information';
    private static final String WORK_ORDER_OBJECT_NAME = 'WorkOrder';
    private static final String WORK_ORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_PLAN_NAME_DRIVE = 'Drive';
    private static final String WORK_STEP_OBJECT_NAME = 'WorkStep';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String STATUS_DEAD = 'Dead';
    private enum ObjectNames {
        ACCOUNT,
        ACCOUNTCONTACTRELATIONSHIP,
        ACCOUNTPAYMENTACCOUNTRELATION,
        AGREEMENT,
        CONTACT,
        CONTRACT,
        MERCHANTORDER,
        OPPORTUNITYCONTACTROLE,
        ORDERITEM,
        PAYMENTACCOUNT,
        WORKORDER,
        WORKSTEP,
        XREF
    }
    private static final Map<String, ObjectNames> OBJECTNAMETOOBJECTNAMEENUMVALUES = new Map<String, ObjectNames>{
        ACCOUNTCONTACTRELATIONSHIP_OBJECT_NAME => ObjectNames.ACCOUNTCONTACTRELATIONSHIP,
        ACCOUNT_OBJECT_NAME => ObjectNames.ACCOUNT,
        ACCOUNT_PAYMENT_ACCOUNT_RELATION_OBJECT_NAME => ObjectNames.ACCOUNTPAYMENTACCOUNTRELATION,
        AGREEMENT_OBJECT_NAME => ObjectNames.AGREEMENT,
        CONTACT_OBJECT_NAME => ObjectNames.CONTACT,
        CONTRACT_OBJECT_NAME => ObjectNames.CONTRACT,
        MX_ORDER_OBJECT_NAME => ObjectNames.MERCHANTORDER,
        OPPORTUNITYCONTACTROLE_OBJECT_NAME => ObjectNames.OPPORTUNITYCONTACTROLE,
        ORDERITEM_OBJECT_NAME => ObjectNames.ORDERITEM,
        PAYMENT_ACCOUNT_OBJECT_NAME => ObjectNames.PAYMENTACCOUNT,
        WORK_ORDER_OBJECT_NAME => ObjectNames.WORKORDER,
        WORK_STEP_OBJECT_NAME => ObjectNames.WORKSTEP,
        XREF_OBJECT_NAME => ObjectNames.XREF
    };
    private static final Map<ObjectNames, String> SOBJECTTYPETORELATIONSHIP = new Map<ObjectNames, String>{
        ObjectNames.ACCOUNTPAYMENTACCOUNTRELATION => ACCOUNT_PAYMENT_ACCOUNT_RELATION_RELATIONSHIP_NAME,
        ObjectNames.AGREEMENT => AGREEMENT_RELATIONSHIP_NAME,
        ObjectNames.CONTRACT => CONTRACT_RELATIONSHIP_NAME,
        ObjectNames.XREF => XREF_RELATIONSHIP_NAME
    };
    private List<Id> accountContactIds;
    private List<Id> agreementIds;
    private List<Id> contactIds;
    private List<Id> contractIds;
    private List<Id> invoicePaymentAccountIds;
    private List<Id> merchantOrderIds;
    private List<Id> opportunityContactRoleIds;
    private List<Id> filteredOrderItemIds;
    private Map<Id, Id> paymentAccountToContactId;
    private List<Id> paymentAccountIds;
    private List<Account> storeAccounts;
    private String workPlanType;
    private List<Id> workStepIds;
    private List<Id> xRefIds;
    private List<String> applicableDeadworkOrderTypes;

    /**
     * @description Default constructor to insantiate variables.
     */
    public StoresOnWorkPlansServiceImpl() {
        this.accountContactIds = new List<Id>();
        this.agreementIds = new List<Id>();
        this.contactIds = new List<Id>();
        this.contractIds = new List<Id>();
        this.invoicePaymentAccountIds = new List<Id>();
        this.merchantOrderIds = new List<Id>();
        this.opportunityContactRoleIds = new List<Id>();
        this.filteredOrderItemIds = new List<Id>();
        this.paymentAccountToContactId = new Map<Id, Id>();
        this.paymentAccountIds = new List<Id>();
        this.storeAccounts = new List<Account>();
        this.workPlanType = '';
        this.workStepIds = new List<Id>();
        this.xRefIds = new List<Id>();
        this.applicableDeadworkOrderTypes = new List<String>{ WORK_ORDER_TYPE_PHOTOSHOOT };
    }

    /**
     * @description To fetch unique stores from current WorkPlan.
     * @JIRA# LEM-1158
     * @param currentWorkPlanRecordId
     * @return StoresOnWorkPlanWrapper
     */
    public StoresOnWorkPlanWrapper fetchStoresByWorkPlan(Id currentWorkPlanRecordId) {
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>();
        Set<Id> uniqueStoreIds = new Set<Id>();
        WorkPlan currentWorkPlan = WorkPlansSelector.newInstance()
            .selectById(new Set<Id>{ currentWorkPlanRecordId })[0];
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectByIdAndStoreAccountRecordType(currentWorkPlanRecordId)
        ) {
            if (
                eachWorkPlan.WorkOrder.AccountId == null ||
                uniqueStoreIds.contains(eachWorkPlan.WorkOrder.AccountId)
            ) {
                continue;
            } else if (isEligibleWorkPlan(eachWorkPlan)) {
                AccountWrapper accountWrapper = new AccountWrapper(
                    eachWorkPlan.WorkOrder.AccountId,
                    eachWorkPlan.WorkOrder.Account.Name,
                    eachWorkPlan.WorkOrder.Opportunity__c != null
                        ? eachWorkPlan.WorkOrder.Opportunity__c
                        : eachWorkPlan.WorkOrder.ParentWorkOrder.Opportunity__c,
                    eachWorkPlan.WorkOrderId
                );
                accountWrapper.businessAccountId = eachWorkPlan.WorkOrder.ParentWorkOrder.AccountId ==
                    null
                    ? (eachWorkPlan.WorkOrder.Type__c == 'POS'
                          ? eachWorkPlan.WorkOrder.Account.ParentId
                          : eachWorkPlan.WorkOrder.AccountId)
                    : eachWorkPlan.WorkOrder.ParentWorkOrder.AccountId;
                accountWrapper.parentWorkOrderId = eachWorkPlan.WorkOrder.ParentWorkOrder.Id == null
                    ? eachWorkPlan.WorkOrderId
                    : eachWorkPlan.WorkOrder.ParentWorkOrder.Id;
                accountWrapper.workPlanId = currentWorkPlanRecordId;
                accountWrapper.workOrderType = eachWorkPlan.WorkOrder.Type__c;
                accountWrapper.workOrderContractId = eachWorkPlan.WorkOrder.Contract__c;
                accountWrappers.add(accountWrapper);
                uniqueStoreIds.add(eachWorkPlan.WorkOrder.AccountId);
            }
        }
        return new StoresOnWorkPlanWrapper(
            accountWrappers,
            currentWorkPlan.Name,
            evaluateANDLogicalOperator(
                currentWorkPlan.Parent_Work_Plan__c == null,
                !accountWrappers.isEmpty()
            )
        );
    }

    /**
     * @description To fetch stores details when accountWrapper is passed.
     * @JIRA# LEM-1158
     * @JIRA# LEM-1470 - WorkOrder is considered for pulling the menu details with assumption
     * that a Store Account will have a single WorkOrder in a WorkOrder hierarchy.
     * @JIRA# LEM-2198 - Added banking information and contract details
     * @JIRA# LEM-4524 - Added Tablet details section using Work Step
     * @param accountWrapper
     * @return List<SectionWrapper>
     */
    public List<SectionWrapper> fetchStoresData(String accountWrapper) {
        List<AccountWrapper> accountWrappers = (List<AccountWrapper>) JSON.deserialize(
            accountWrapper,
            List<AccountWrapper>.class
        );
        workPlanType = accountWrappers[0].workPlanType;
        // storing zeroth index of returned list as it will return only one record
        collectStoreRelatedData(
            new WorkOrder(
                Id = accountWrappers[0].workOrderId,
                AccountId = accountWrappers[0].accountId,
                Opportunity__c = accountWrappers[0].opportunityId,
                ParentWorkOrderId = accountWrappers[0].parentWorkOrderId,
                Type__c = accountWrappers[0].workOrderType,
                Contract__c = accountWrappers[0].workOrderContractId
            ),
            accountWrappers[0].workPlanId
        );
        List<SectionWrapper> sectionWrappers = new List<SectionWrapper>();
        if (isEmptyOrNull(storeAccounts)) {
            return sectionWrappers;
        }
        String objectName;
        Id recordId;
        // List is required to maintain the sorting order.
        List<Id> recordIds;
        String accountRecordType = ACCOUNT_RECORD_TYPE_NAME_STORE;
        if (
            accountWrappers[0].accountId == accountWrappers[0].businessAccountId &&
            !System.Label.WorkOrderTypesToExcludeBusinessRecordType.split(SPLIT_DELIMETER)
                .contains(accountWrappers[0].workOrderType)
        ) {
            accountRecordType = ACCOUNT_RECORD_TYPE_NAME_BUSINESS;
        }
        // LEM-2516: Added Account Record Type check to pull the applicable sections on onboarding details
        for (
            Stores_List_View_Configuration__mdt eachStoresListViewConfig : StoresListViewConfigurationsSelector.newInstance()
                .selectByWorkPlanTypeAndAccountRecordType(workPlanType, accountRecordType)
        ) {
            if (
                evaluateANDLogicalOperator(
                    String.isNotBlank(eachStoresListViewConfig.Types_To_Exclude__c),
                    eachStoresListViewConfig.Types_To_Exclude__c
                        ?.split(SPLIT_DELIMETER)
                        .contains(workPlanType)
                )
            ) {
                continue;
            }
            objectName = eachStoresListViewConfig.Object_Name__c;
            switch on OBJECTNAMETOOBJECTNAMEENUMVALUES.get(objectName) {
                when ACCOUNT {
                    recordId = storeAccounts[0].Id;
                    if (
                        evaluateANDLogicalOperator(
                            evaluateANDLogicalOperator(
                                eachStoresListViewConfig.Section_Name__c ==
                                ACCOUNT_DETAILS_SECTION_NAME,
                                !System.Label.WorkOrderTypesToExcludeBusinessRecordType.split(
                                        SPLIT_DELIMETER
                                    )
                                    .contains(accountWrappers[0].workOrderType)
                            ) ||
                            eachStoresListViewConfig.Section_Name__c ==
                            BANKING_INFORMATION_SECTION_NAME,
                            !eachStoresListViewConfig.Show_Section_Header__c
                        )
                    ) {
                        recordId = accountWrappers[0].businessAccountId;
                    }
                    sectionWrappers.add(getSectionWrapper(eachStoresListViewConfig, recordId));
                }
                when ACCOUNTCONTACTRELATIONSHIP {
                    recordIds = accountContactIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when AGREEMENT {
                    recordIds = agreementIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when CONTACT {
                    recordIds = contactIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when CONTRACT {
                    recordIds = contractIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when MERCHANTORDER {
                    recordIds = merchantOrderIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when OPPORTUNITYCONTACTROLE {
                    recordIds = opportunityContactRoleIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when ORDERITEM {
                    recordIds = filteredOrderItemIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when PAYMENTACCOUNT {
                    if (
                        eachStoresListViewConfig.Applicable_Account_Record_Type__c ==
                        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
                    ) {
                        sectionWrappers.addAll(
                            getSectionWrappers(eachStoresListViewConfig, invoicePaymentAccountIds)
                        );
                    } else {
                        sectionWrappers.addAll(
                            getPaymentAccountsSectionWrappers(eachStoresListViewConfig)
                        );
                    }
                }
                when WORKORDER {
                    recordId = accountWrappers[0].workOrderId;
                    sectionWrappers.add(getSectionWrapper(eachStoresListViewConfig, recordId));
                }
                when WORKSTEP {
                    recordIds = workStepIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
                when XREF {
                    recordIds = xRefIds;
                    sectionWrappers.addAll(getSectionWrappers(eachStoresListViewConfig, recordIds));
                }
            }
        }
        return sectionWrappers;
    }

    /**
     * @description It compares the received boolean values with AND(&&) logical operator
     * and returns the result.
     * It is added to reduce the Cyclomatic Complexity of the class.
     * @param leftOperand
     * @param rightOperand
     * @return Boolean
     */
    private Boolean evaluateANDLogicalOperator(Boolean leftOperand, Boolean rightOperand) {
        return leftOperand && rightOperand;
    }

    /**
     * @description It collects Agreement or Contract Ids on basis of Agreement Type.
     * @param sObjectInstance
     */
    private void collectAgreementIds(SObject sObjectInstance) {
        Agreement__c agreement = (Agreement__c) sObjectInstance;
        if (agreement.Type__c == AGREEMENT_TYPE_FRANCHISE) {
            contractIds.add(agreement.Contract__c);
        } else if (agreement.Type__c == AGREEMENT_TYPE_STORE) {
            agreementIds.add(agreement.Id);
        }
    }

    /**
     * @description It collects Payment Account Ids for Payments or Invoice record Type.
     * Added isEmpty check to select only the most recently created Payment Account.
     * @param sObjectInstance
     */
    private void collectPaymentAccountIds(SObject sObjectInstance) {
        Payment_Account__c paymentAccount = (Payment_Account__c) sObjectInstance.getSObject(
            PAYMENT_ACCOUNT_RELATIONSHIP_NAME
        );
        String paymentAccountRecordType = (String) sObjectInstance.get(
            PAYMENT_ACCOUNT_RECORD_TYPE_FIELD
        );
        if (
            paymentAccountRecordType == PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS &&
            paymentAccountIds.isEmpty()
        ) {
            paymentAccountIds.add(paymentAccount.Id);
            // get Billing_Contact_Name__c from Payment_Account__r parent field
            paymentAccountToContactId.put(
                paymentAccount.Id,
                (Id) paymentAccount?.get(PAYMENT_ACCOUNT_BILLING_CONTACT_NAME_FIELD)
            );
        } else if (
            paymentAccountRecordType == PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE &&
            invoicePaymentAccountIds.isEmpty()
        ) {
            invoicePaymentAccountIds.add(paymentAccount.Id);
        }
    }

    /**
     * @description It collects Xref Ids on basis of Work Plan type and External Id Source.
     * @param sObjectInstance
     */
    private void collectXrefIds(SObject sObjectInstance) {
        Xref__c xref = (Xref__c) sObjectInstance;
        if (
            evaluateANDLogicalOperator(
                workPlanType == WORK_PLAN_NAME_DRIVE,
                xref.External_ID_Source__c == XREF_EXTERNAL_ID_SOURCE_DRIVEDB
            )
        ) {
            xRefIds.add(xref.Id);
        } else if (
            evaluateANDLogicalOperator(
                workPlanType != WORK_PLAN_NAME_DRIVE,
                xref.External_ID_Source__c == XREF_EXTERNAL_ID_SOURCE_MDS
            )
        ) {
            xRefIds.add(xref.Id);
        }
    }

    /**
     * @description It collects store details and related records:
     * Contact To Payment Account Relations, Contracts, Decision Makers,
     * Payment Accounts, Xrefs, Work Steps.
     * @param workOrder
     * @param workPlanId
     */
    private void collectStoreRelatedData(WorkOrder workOrder, Id workPlanId) {
        storeAccounts = AccountsSelector.newInstance()
            .selectRelatedChildsById(new Set<Id>{ workOrder.AccountId });
        if (isEmptyOrNull(storeAccounts)) {
            return;
        }
        getRecordIds(storeAccounts[0], AGREEMENT_OBJECT_NAME);
        contractIds.addAll(getRecordIds(storeAccounts[0], CONTRACT_OBJECT_NAME));
        // collects Payment Account Ids and Invoice Ids from 'Account Payment Account Relation' object
        getRecordIds(storeAccounts[0], ACCOUNT_PAYMENT_ACCOUNT_RELATION_OBJECT_NAME);
        // collects Xref Ids
        getRecordIds(storeAccounts[0], XREF_OBJECT_NAME);
        if (workOrder.Type__c != WORK_ORDER_TYPE_PHOTOSHOOT) {
            getContactIds(new List<WorkOrder>{ workOrder });
        }
        // It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids using the passed Work Orders.
        getOCRAndACRIdsByAll(new List<WorkOrder>{ workOrder });
        // JIRA# - LEM-19767
        if (workOrder.Type__c == WORK_ORDER_TYPE_ADS_AND_PROMOS) {
            getOrderItemIds(storeAccounts[0].Id, workOrder.Contract__c);
        }
        getWorkStepIds(
            storeAccounts[0].Id,
            workOrder.Id,
            new Set<String>{ WORK_STEP_TYPE_DELIVER_TABLET }
        );
        getMerchantOrderAndContactIds(workOrder.ParentWorkOrderId);
    }

    /**
     * @description To get contact ids from passed Work Orders.
     * @param workOrders
     */
    private void getContactIds(List<WorkOrder> workOrders) {
        for (
            List<Id> eachUniqueId : DecisionMakerCalculationService.getDecisionMakers(workOrders)
                .values()
        ) {
            contactIds.addAll(eachUniqueId);
        }
    }

    /**
     * @description To get Merchant Order Ids from the passed Work Order Id.
     * @JIRA# LEM-13492, LEM-15794
     * @param workOrderId
     */
    private void getMerchantOrderAndContactIds(Id workOrderId) {
        for (
            MX_Order__c eachMxOrder : MerchantOrdersSelector.newInstance()
                .selectByWorkOrderIds(new Set<Id>{ workOrderId })
        ) {
            merchantOrderIds.add(eachMxOrder.Id);
            // It is used to get 'Contact' Ids.
            if (eachMxOrder.Contact__c == null) {
                continue;
            }
            contactIds.add(eachMxOrder.Contact__c);
        }
    }

    /**
     * @description It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids using the passed Work Orders.
     * @JIRA# LEM-5367
     * @param workOrders
     */
    private void getOCRAndACRIdsByAll(List<WorkOrder> workOrders) {
        Map<Id, List<Id>> getDecisionMakersMap = DecisionMakerCalculationService.getOCRAndACRIds(
            workOrders
        );
        if (!isEmptyOrNull(getDecisionMakersMap)) {
            for (Id accountIdOpportunityId : getDecisionMakersMap.keySet()) {
                String sObjectName = accountIdOpportunityId.getSObjectType()
                    .getDescribe()
                    .getName();
                if (sObjectName == ACCOUNT_OBJECT_NAME) {
                    accountContactIds.addAll(getDecisionMakersMap.get(accountIdOpportunityId));
                }
                if (sObjectName == OPPORTUNITY_OBJECT_NAME) {
                    opportunityContactRoleIds.addAll(
                        getDecisionMakersMap.get(accountIdOpportunityId)
                    );
                }
            }
        }
    }

    /**
     * @description To get Order Item Ids from the passed store Account Id.
     * @JIRA# LEM-16579
     * @param storeId
     * @param workOrderContractId
     */
    private void getOrderItemIds(Id storeId, Id workOrderContractId) {
        for (
            OrderItem eachOrderItem : OrderItemsSelector.newInstance()
                .selectActivatedOrderItemsByAccountIds(new Set<Id>{ storeId })
        ) {
            if (eachOrderItem.SBQQ__Contract__c == workOrderContractId) {
                filteredOrderItemIds.add(eachOrderItem.Id);
            }
        }
    }

    /**
     * @description To get Work Step Ids from the passed store Account Id and Work Order Id.
     * @param storeId
     * @param workOrderId
     * @param workStepTypes
     */
    private void getWorkStepIds(Id storeId, Id workOrderId, Set<String> workStepTypes) {
        workStepIds = new List<Id>(
            new Map<Id, WorkStep>(
                    WorkStepsSelector.newInstance()
                        .selectByStoreAccountAndWorkOrderIds(
                            new Set<Id>{ storeId },
                            new Set<Id>{ workOrderId },
                            workStepTypes
                        )
                )
                .keySet()
        );
    }

    /**
     * @description To get the list of fields corresponding to object
     * from FieldSet which needs to be displayed in a section.
     * @JIRA# LEM-1397
     * @param objectName
     * @param fieldSetName
     * @return List<String>
     */
    private List<String> getFields(String objectName, String fieldSetName) {
        if (isEmptyOrNull(fieldSetName)) {
            return new List<String>();
        }
        List<String> fields = new List<String>();
        Schema.SObjectType sObjectTypeObject = ((SObject) Type.forName(objectName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getSObjectType();
        Schema.FieldSet fieldSetObject = sObjectTypeObject.getDescribe()
            .FieldSets.getMap()
            .get(fieldSetName);
        for (Schema.FieldSetMember eachFieldSetMember : fieldSetObject.getFields()) {
            fields.add(eachFieldSetMember.getFieldPath());
        }
        return fields;
    }

    /**
     * @description To get section wrappers for Payment Accounts and related Contacts.
     * @param storesListViewConfiguration
     * @return List<SectionWrapper>
     */
    private List<SectionWrapper> getPaymentAccountsSectionWrappers(
        Stores_List_View_Configuration__mdt storesListViewConfiguration
    ) {
        Integer iterator = 0;
        List<SectionWrapper> sectionWrappers = new List<SectionWrapper>();
        SectionWrapper sectionWrapper;
        if (isEmptyOrNull(paymentAccountIds)) {
            sectionWrappers.add(getSectionWrapper(storesListViewConfiguration, null));
        }
        for (Id eachPaymentAccountId : paymentAccountIds) {
            // changes Object Name to 'Payment Account' for showing Payment Account Details
            storesListViewConfiguration.Object_Name__c = PAYMENT_ACCOUNT_OBJECT_NAME;
            sectionWrapper = getSectionWrapper(storesListViewConfiguration, eachPaymentAccountId);
            sectionWrapper.showEncrytedData = evaluateANDLogicalOperator(
                    sectionWrapper.showEncrytedData == true,
                    iterator == 0
                )
                ? true
                : false;
            sectionWrappers.add(sectionWrapper);
            // changes Object Name to 'Contact' for showing Billing Contact Details related to Payment Account
            storesListViewConfiguration.Object_Name__c = CONTACT_OBJECT_NAME;
            storesListViewConfiguration.Show_Section_Header__c = false;
            sectionWrapper = getSectionWrapper(
                storesListViewConfiguration,
                paymentAccountToContactId.get(eachPaymentAccountId)
            );
            sectionWrapper.showEncrytedData = false;
            sectionWrappers.add(sectionWrapper);
            iterator++;
        }
        return sectionWrappers;
    }

    /**
     * @description To get section record Ids from store Account on basis of object name.
     * @param account - Account Record with related Xrefs.
     * @param objectName
     * @return List<Id>
     */
    private List<Id> getRecordIds(Account account, String objectName) {
        List<Id> recordIds = new List<Id>();
        String relationshipType = SOBJECTTYPETORELATIONSHIP.get(
            OBJECTNAMETOOBJECTNAMEENUMVALUES.get(objectName)
        );
        Map<String, Object> fieldsToValue = account.getPopulatedFieldsAsMap();
        if (fieldsToValue.containsKey(relationshipType)) {
            for (SObject eachSobject : account.getSObjects(relationshipType)) {
                if (objectName == ACCOUNT_PAYMENT_ACCOUNT_RELATION_OBJECT_NAME) {
                    collectPaymentAccountIds(eachSobject);
                } else if (objectName == AGREEMENT_OBJECT_NAME) {
                    collectAgreementIds(eachSobject);
                } else if (objectName == XREF_OBJECT_NAME) {
                    collectXrefIds(eachSobject);
                } else {
                    recordIds.add(eachSobject.Id);
                }
            }
        }
        return recordIds;
    }

    /**
     * @description To generate section wrapper for passed record Id.
     * @param storesListViewConfiguration
     * @param recordId
     * @return SectionWrapper
     */
    private SectionWrapper getSectionWrapper(
        Stores_List_View_Configuration__mdt storesListViewConfiguration,
        Id recordId
    ) {
        SectionWrapper sectionWrapper = new SectionWrapper(
            Integer.valueOf(storesListViewConfiguration.Section_Sequence__c),
            storesListViewConfiguration.Section_Name__c,
            recordId,
            storesListViewConfiguration.Object_Name__c,
            getFields(
                storesListViewConfiguration.Object_Name__c,
                storesListViewConfiguration.FieldSet_Name__c
            )
        );
        sectionWrapper.showEncrytedData = evaluateANDLogicalOperator(
            evaluateANDLogicalOperator(
                FeatureManagement.checkPermission(VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION),
                storesListViewConfiguration.Section_Name__c == BANKING_INFORMATION_SECTION_NAME
            ),
            evaluateANDLogicalOperator(
                storesListViewConfiguration.Object_Name__c == PAYMENT_ACCOUNT_OBJECT_NAME,
                storesListViewConfiguration.Applicable_Account_Record_Type__c !=
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
        );
        sectionWrapper.showSectionHeader = storesListViewConfiguration.Show_Section_Header__c;
        // TODO: Move isSupportedObject attribute to 'Onboarding Details Configuration' custom metadata.
        sectionWrapper.isSupportedObject = storesListViewConfiguration.Object_Name__c ==
            WORK_STEP_OBJECT_NAME
            ? false
            : true;
        return sectionWrapper;
    }

    /**
     * @description To generate section wrappers for passed record Ids.
     * @param storesListViewConfiguration
     * @param recordIds
     * @return SectionWrapper
     */
    private List<SectionWrapper> getSectionWrappers(
        Stores_List_View_Configuration__mdt storesListViewConfiguration,
        List<Id> recordIds
    ) {
        SectionWrapper sectionWrapper;
        List<SectionWrapper> sectionWrappers = new List<SectionWrapper>();
        Boolean showSectionHeader = storesListViewConfiguration.Show_Section_Header__c;
        Set<Id> processedIds = new Set<Id>();
        if (isEmptyOrNull(recordIds)) {
            sectionWrappers.add(getSectionWrapper(storesListViewConfiguration, null));
        }
        for (Id eachId : recordIds) {
            // It ensures that duplicate section is not visible in the onboarding details.
            if (processedIds.contains(eachId)) {
                continue;
            }
            sectionWrapper = getSectionWrapper(storesListViewConfiguration, eachId);
            sectionWrapper.showSectionHeader = showSectionHeader;
            sectionWrappers.add(sectionWrapper);
            // To control visiblity of section header in-case of multiple records.
            showSectionHeader = false;
            processedIds.add(eachId);
        }
        return sectionWrappers;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }
    /**
     * @description To check if the current work plan is applicable for fetching associated store account.
     * @param currentWorkPlan
     * @return Boolean
     */
    private Boolean isEligibleWorkPlan(WorkPlan currentWorkPlan) {
        return currentWorkPlan.Status__c != STATUS_DEAD ||
            currentWorkPlan.Status__c == STATUS_DEAD &&
            applicableDeadworkOrderTypes.contains(WORK_ORDER_TYPE_PHOTOSHOOT);
    }
}