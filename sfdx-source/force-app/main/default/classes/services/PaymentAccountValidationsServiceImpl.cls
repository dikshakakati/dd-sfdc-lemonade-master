/**
 * @author Deloitte
 * @date 11/27/2022
 * @description Service implementation class for Payment Account's
 * readiness validations related logic.
 */
public inherited sharing class PaymentAccountValidationsServiceImpl implements IPaymentAccountValidationsService, IHandleStoreReadinessValidations {
    private static final string PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
      .get('Invoice')
      .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
      .get('Payments')
      .getRecordTypeId();
    private static final String SEGMENT_SMB = 'SMB';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private enum MethodTypes {
      INSTITUTIONNUMBERONSTORE,
      NULLVALUESONINVOICE,
      NULLVALUESONPAYMENTS,
      PAYMENTACCOUNTONBUSINESS,
      PAYMENTACCOUNTONSTORE
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
      'validateInstitutionNumberOnPaymentAccounts' => MethodTypes.INSTITUTIONNUMBERONSTORE,
      'validateNullFieldValuesOnInvoiceRecordType' => MethodTypes.NULLVALUESONINVOICE,
      'validateNullFieldValuesOnPaymentsRecordType' => MethodTypes.NULLVALUESONPAYMENTS,
      'validatePaymentAccountsOnBusiness' => MethodTypes.PAYMENTACCOUNTONBUSINESS,
      'validatePaymentAccountsOnStore' => MethodTypes.PAYMENTACCOUNTONSTORE
    };
    private static final String COMMA_SEPARATOR = ',';
    private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
    private static final String INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA = System.Label.InstitutionNumOnPAReadinessCheckCriteria;
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String SEPARATOR = System.Label.Separator;
    private Map<Id, List<SBQQ__QuoteLine__c>> accountIdToAlocoholDeliveryQuoteLines;
    private List<WorkOrder> childWorkOrders;
    private Map<Id, WorkOrder> parentWorkOrders;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private Map<Id, List<Payment_Account__c>> accountIdToPaymentAccounts;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963
    private static final String CLASS_NAME = 'PaymentAccountValidationsServiceImpl'; //* @jira LEM-13963
    private Map<Id, List<Payment_Account__c>> accountIdToPaymentsPaymentAccounts; //LEM-15484
    private Map<Id, List<WorkOrder>> parentWorkOrderIdToChildWorkOrders;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public PaymentAccountValidationsServiceImpl() {
      this.accountIdToAlocoholDeliveryQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
      this.childWorkOrders = new List<WorkOrder>();
      this.parentWorkOrders = new Map<Id, WorkOrder>();
      this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
      this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
      this.accountIdToPaymentAccounts = new Map<Id, List<Payment_Account__c>>();
      this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963
      this.accountIdToPaymentsPaymentAccounts = new Map<Id, List<Payment_Account__c>>();
      this.parentWorkOrderIdToChildWorkOrders = new Map<Id, List<WorkOrder>>();
    }

    /**
     * @description It performs readiness validations on the Payment Accounts
     * associated with passed Work Orders according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684 @jira LEM-13963
     * @param childWorkOrders
     * @param parentWorkOrders
     * @param storeReadinessValidations
     * @param existingReadinessCheckFailures
     * @param objectName
     */
    public void validate(
      List<WorkOrder> childWorkOrders,
      List<WorkOrder> parentWorkOrders,
      List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations,
      List<Readiness_Check_Failure__c> existingReadinessCheckFailures,
      String objectName
    ) {
      this.childWorkOrders.addAll(childWorkOrders);
      this.parentWorkOrders = new Map<Id, WorkOrder>(parentWorkOrders);
      this.readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
        storeReadinessValidations
      );
      this.existingReadinessValidationFailuresRecords.addAll(
        existingReadinessCheckFailures
      ); //* @jira LEM-13963
      this.readinessObjectName = objectName; //* @jira LEM-13963
      runValidations(storeReadinessValidations);
      publishReadinessCheckFailures();
    }

    /**
     * @description It is used to collect Payment Accounts associated with Accounts of
     * the child and parent Work Orders.
     * @JIRA# LEM-3587
     */
      private void collectPaymentAccountsByWorkOrders() {
          Map<Id, Set<Id>> accountIdToWorkOrderIds = new Map<Id, Set<Id>>();
          List<WorkOrder> workOrders = new List<WorkOrder>();
          workOrders.addAll(parentWorkOrders.values());
          workOrders.addAll(childWorkOrders);
          for (WorkOrder eachWorkOrder : workOrders) {
              if (!accountIdToWorkOrderIds.containsKey(eachWorkOrder.AccountId)) {
                  accountIdToWorkOrderIds.put(eachWorkOrder.AccountId, new Set<Id>());
              }
              accountIdToWorkOrderIds.get(eachWorkOrder.AccountId).add(eachWorkOrder.Id);
              if (eachWorkOrder.parentWorkOrderId == null) {
                  continue;
              }
              if (!parentWorkOrderIdToChildWorkOrders.containsKey(eachWorkOrder.parentWorkOrderId)) {
                  parentWorkOrderIdToChildWorkOrders.put(
                      eachWorkOrder.parentWorkOrderId,
                      new List<WorkOrder>()
                  );
              }
              parentWorkOrderIdToChildWorkOrders.get(eachWorkOrder.parentWorkOrderId)
                  .add(eachWorkOrder);
          }
          accountIdToPaymentAccounts = getPaymentAccountsByAccounts(accountIdToWorkOrderIds);
      }

    /**
     * @description It checks whether the business account associated to the parent work order has
     * an Alcohol Delivery Quote Line added to Quote
     * @JIRA# LEM-7996
     * @param workOrders
     */
    @TestVisible
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    private void createAccountToAlcoholDeliveryQuoteLineMap(
      List<WorkOrder> workOrders
    ) {
      Set<Id> businessAccountIds = new Set<Id>();
      List<SBQQ__QuoteLine__c> alcoholDeliveryQuoteLines = new List<SBQQ__QuoteLine__c>();

      for (WorkOrder eachWorkOrder : workOrders) {
        if (eachWorkOrder.ParentWorkOrderId == null) {
          continue;
        }
        if (
          eachWorkOrder.Account.Shopping_Protocol__c ==
          DASHER_PICK_SHOPPING_PROTOCOL
        ) {
          businessAccountIds.add(eachWorkOrder.ParentWorkOrder.AccountId);
        }
      }

      if (businessAccountIds.isEmpty()) {
        return;
      }

      alcoholDeliveryQuoteLines = QuoteLineItemsSelector.newInstance()
        .selectAlcoholDeliveryQuoteLineItemByAccounts(businessAccountIds);

      if (alcoholDeliveryQuoteLines.size() > 0) {
        for (SBQQ__QuoteLine__c eachQuoteLine : alcoholDeliveryQuoteLines) {
          if (eachQuoteLine.SBQQ__Quote__r.SBQQ__Account__c != null) {
            if (
              accountIdToAlocoholDeliveryQuoteLines.containsKey(
                eachQuoteLine.SBQQ__Quote__r.SBQQ__Account__c
              )
            ) {
              accountIdToAlocoholDeliveryQuoteLines.get(
                  eachQuoteLine.SBQQ__Quote__r.SBQQ__Account__c
                )
                .add(eachQuoteLine);
            } else {
              accountIdToAlocoholDeliveryQuoteLines.put(
                eachQuoteLine.SBQQ__Quote__r.SBQQ__Account__c,
                new List<SBQQ__QuoteLine__c>{ eachQuoteLine }
              );
            }
          }
        }
      }
    }

    /**
     * @description It is used to collect Payment Account details from related Accounts.
     * @param accountIdToWorkOrder
     * @return Map<Id, List<Payment_Account__c>>
     */

    private Map<Id, List<Payment_Account__c>> getPaymentAccountsByAccounts(
      Map<Id, Set<Id>> accountIdToWorkOrder
    ) {
      //WorkOrder workOrderToProcess;
      if (accountIdToWorkOrder.isEmpty()) {
        return accountIdToPaymentAccounts;
      }
      for (
        Account_Payment_Account_Relation__c eachAPAR : AccountPaymentAccountRelationsSelector.newInstance()
          .selectByAccountIdsAndPaymentAccountRecordTypes(
            accountIdToWorkOrder.keySet(),
            new Set<String>{
              PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
              PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
            }
          )
      ) {
       if (!accountIdToPaymentAccounts.containsKey(eachAPAR.Account__c)) {
              accountIdToPaymentAccounts.put(
                eachAPAR.Account__c,
                new List<Payment_Account__c>()
              );
            }
            accountIdToPaymentAccounts.get(eachAPAR.Account__c)
              .add(eachAPAR.Payment_Account__r);
            // Add to accountIdToPaymentsPaymentAccounts if it's a PAYMENTS record type
            if (eachAPAR.Record_Type__c == PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS) {
              if (
                !accountIdToPaymentsPaymentAccounts.containsKey(eachAPAR.Account__c)
              ) {
                accountIdToPaymentsPaymentAccounts.put(
                  eachAPAR.Account__c,
                  new List<Payment_Account__c>()
                );
              }
              accountIdToPaymentsPaymentAccounts.get(eachAPAR.Account__c)
                .add(eachAPAR.Payment_Account__r);
            }
      }
      return accountIdToPaymentAccounts;
    }

    /**
     * @description It checks whether the Institution Number on Payment Account has valid length
     * of digits and associated with stores of eligible country.
     * Current eligibility criteria:
     * 1. Country = "Canada"
     * 2. Length != 3.
     * Logic: 1 AND 2
     * @JIRA# LEM-10041
     * @param paymentAccount
     * @param storeAccount
     * @param storeReadinessValidationRule
     * @return Boolean
     */
    private Boolean isInstitutionNumberEligibilityCriteriaSatisfied(
      Payment_Account__c paymentAccount,
      Account storeAccount,
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
      Map<String, Integer> countryToInstitutionNumberLength = new Map<String, Integer>();
      Boolean isInstitutionNumberNull = false;
      isInstitutionNumberNull = isFieldValueNull(
        paymentAccount,
        storeReadinessValidationRule.Field_Name__c
      );
      for (
        String eachCriteria : INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA
          ?.split(COMMA_SEPARATOR)
      ) {
        countryToInstitutionNumberLength.put(
          eachCriteria.split(SEPARATOR)[0],
          Integer.valueOf(eachCriteria.split(SEPARATOR)[1])
        );
      }
      return paymentAccount.RecordTypeId ==
        PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID &&
        countryToInstitutionNumberLength.containsKey(
          storeAccount.BillingCountryCode
        ) &&
        (isInstitutionNumberNull ||
        (!isInstitutionNumberNull &&
        paymentAccount.Institution_Number__c.length() !=
        countryToInstitutionNumberLength.get(storeAccount.BillingCountryCode)));
    }

    /**
     * @description It checks whether the passed field value is null on the passed sObjectInstance.
     * @JIRA# LEM-4851
     * @param sObjectInstance
     * @param fieldName
     * @return Boolean
     */
    private Boolean isFieldValueNull(SObject sObjectInstance, String fieldName) {
      return sObjectInstance.get(fieldName) == null;
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed
     * Store Readiness Validation Rule, Work Order and Payment Account Id.
     * @JIRA# LEM-3587
     * @param storeReadinessValidationRule
     * @param workOrder
     * @param paymentAccountId
     */
    private void logReadinessCheckFailure(
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
      WorkOrder workOrder,
      Id paymentAccountId
    ) {
      readinessValidationFailures.add(
        new Readiness_Check_Failure__c(
          Account_Name__c = workOrder.AccountId,
          Child_Work_Order__c = workOrder.Id,
          Payment_Account_Name__c = paymentAccountId,
          Error_Message__c = storeReadinessValidationRule.Error_Message__c,
          Field_Name__c = storeReadinessValidationRule.Field_Label__c,
          Object_Name__c = storeReadinessValidationRule.Object_Label__c,
          Parent_Work_Order__c = workOrder.ParentWorkOrderId == null
            ? workOrder.Id
            : workOrder.ParentWorkOrderId
        )
      );
    }

    /**
     * @description It commits 'Readiness Check Failures' records in the database.
     * @JIRA# LEM-3587 // @jira LEM-13963
     */
    private void publishReadinessCheckFailures() {
      StoreReadinessModificationService.processReadinessCheckFailures(
        existingReadinessValidationFailuresRecords,
        readinessValidationFailures,
        readinessObjectName,
        CLASS_NAME
      );
    }

    /**
     * @description It run store readiness validations on child and parent Work Orders.
     * @JIRA# LEM-3587
     * @param storeReadinessValidations - custom metadata records
     */
    private void runValidations(
      List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations
    ) {
      collectPaymentAccountsByWorkOrders();
      for (
        Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : storeReadinessValidations
      ) {
        switch on
          METHODNAMETOMETHODTYPES.get(
            eachStoreReadinessValidationRule.Service_Method_Name__c
          ) {
          when INSTITUTIONNUMBERONSTORE {
            validateInstitutionNumber(
              eachStoreReadinessValidationRule,
              childWorkOrders
            );
          }
          when NULLVALUESONINVOICE {
            validateNullFieldValuesOnInvoiceRecordType(
              eachStoreReadinessValidationRule,
              parentWorkOrders.values()
            );
          }
          when NULLVALUESONPAYMENTS {
            validateNullFieldValuesOnPaymentsRecordType(
              eachStoreReadinessValidationRule,
              childWorkOrders
            );
          }
          when PAYMENTACCOUNTONBUSINESS {
            validatePaymentAccountsOnAccount(
              eachStoreReadinessValidationRule,
              parentWorkOrders.values(),
              true
            );
          }
          when PAYMENTACCOUNTONSTORE {
            validatePaymentAccountsOnAccount(
              eachStoreReadinessValidationRule,
              childWorkOrders,
              false
            );
          }
        }
      }
    }

    /**
     * @description It is used to perform validation on "Institution Number" on Payment Account
     * associated with store Account of eligible country for the passed child work
     * orders of 'Marketplace' OR 'COO' type has valid length of digits.
     * @JIRA# LEM-10041
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateInstitutionNumber(
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
      List<WorkOrder> workOrders
    ) {
      for (WorkOrder eachWorkOrder : workOrders) {
        if (
          accountIdToPaymentAccounts.containsKey(eachWorkOrder.AccountId) &&
          ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRule,
            eachWorkOrder
          ) && !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(storeReadinessValidationRule.DeveloperName, eachWorkOrder)
        ) {
          for (
            Payment_Account__c eachPaymentAccount : accountIdToPaymentAccounts.get(
              eachWorkOrder.AccountId
            )
          ) {
            if (
              isInstitutionNumberEligibilityCriteriaSatisfied(
                eachPaymentAccount,
                eachWorkOrder.Account,
                storeReadinessValidationRule
              )
            ) {
              logReadinessCheckFailure(
                storeReadinessValidationRule,
                eachWorkOrder,
                eachPaymentAccount.Id
              );
            }
          }
        }
      }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the passed Payment Account and creates
     * readiness check failure record.
     * @JIRA# LEM-4851
     * @param paymentAccount
     * @param workOrder
     * @param storeReadinessValidationRule
     */
    private void validateNullFieldValues(
      Payment_Account__c paymentAccount,
      WorkOrder workOrder,
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
    ) {
      if (
        isFieldValueNull(
          paymentAccount,
          storeReadinessValidationRule.Field_Name__c
        )
      ) {
        logReadinessCheckFailure(
          storeReadinessValidationRule,
          workOrder,
          paymentAccount.Id
        );
      }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the passed Payment Accounts having Invoice Record Type.
     * @JIRA# LEM-3587, LEM-4851, LEM-5700
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValuesOnInvoiceRecordType(
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
      List<WorkOrder> workOrders
    ) {
      for (WorkOrder eachWorkOrder : workOrders) {
        if (
          eachWorkOrder.Segment__c == SEGMENT_SMB &&
          eachWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETPLACE
        ) {
          validatePaymentAccountOnMarketplaceWorkOrder(
            eachWorkOrder,
            storeReadinessValidationRule
          );
        } else if (
                accountIdToPaymentAccounts.containsKey(eachWorkOrder.AccountId) &&
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
              ) && !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(storeReadinessValidationRule.DeveloperName, eachWorkOrder)
            ) {
                for (
            Payment_Account__c eachPaymentAccount : accountIdToPaymentAccounts.get(
              eachWorkOrder.AccountId
            )
          ) {
            if (
              eachPaymentAccount.RecordTypeId ==
              PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
            ) {
              validateNullFieldValues(
                eachPaymentAccount,
                eachWorkOrder,
                storeReadinessValidationRule
              );
              break;
            }
          }
        }
      }
    }

    /**
     * @description It is used to validate ‘Invoice’ Payment Accounts for Marketplace (child) Work Orders.
     * @param workOrderInstance
     * @param storeReadinessValidationRule
     */
    private void validatePaymentAccountOnMarketplaceWorkOrder(
          WorkOrder workOrderInstance,
          Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule
      ) {
          if (!parentWorkOrderIdToChildWorkOrders.containsKey(workOrderInstance.Id)) {
              return;
          }
          for (
              WorkOrder eachWorkOrder : parentWorkOrderIdToChildWorkOrders.get(workOrderInstance.Id)
          ) {
              if (!accountIdToPaymentAccounts.containsKey(eachWorkOrder.AccountId)) {
                  continue;
              }
              for (
                  Payment_Account__c eachPaymentAccount : accountIdToPaymentAccounts.get(
                      eachWorkOrder.AccountId
                  )
              ) {
                  if (eachPaymentAccount.RecordTypeId == PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID) {
                      validateNullFieldValues(
                          eachPaymentAccount,
                          workOrderInstance,
                          storeReadinessValidationRule
                      );
                      break;
                  }
              }
          }
      }

    /**
     * @description It is used to perform validation to check whether the field configured in the
     * passed custom metadata is null on the passed Payment Accounts having Payments Record Type.
     * @JIRA# LEM-4851, LEM-5700
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValuesOnPaymentsRecordType(
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
      List<WorkOrder> workOrders
    ) {
      for (WorkOrder eachWorkOrder : workOrders) {
        if (
          accountIdToPaymentAccounts.containsKey(eachWorkOrder.AccountId) &&
          ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRule,
            eachWorkOrder
          ) && !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(storeReadinessValidationRule.DeveloperName, eachWorkOrder)
        ) {
          for (
            Payment_Account__c eachPaymentAccount : accountIdToPaymentAccounts.get(
              eachWorkOrder.AccountId
            )
          ) {
            if (
              eachPaymentAccount.RecordTypeId ==
              PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            ) {
              validateNullFieldValues(
                eachPaymentAccount,
                eachWorkOrder,
                storeReadinessValidationRule
              );
              break;
            }
          }
        }
      }
    }

    /**
     * @description It is used to perform validation to check whether the Payment Account is
     * associated with business account associated with the passed parent work orders of 'Drive'
     * type OR store account associated with the passed child work orders of 'Marketplace/COO' type
     * not having shopping protocol field's value as 'Shopper Pick' and 'Dasher Pick'.
     * @JIRA# LEM-5297, LEM-6178, LEM-7996
     * @param storeReadinessValidationRule
     * @param workOrders
     * @param isBusinessAccount
     */
    private void validatePaymentAccountsOnAccount(
      Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
      List<WorkOrder> workOrders,
      Boolean isBusinessAccount
    ) {
      createAccountToAlcoholDeliveryQuoteLineMap(workOrders);
      //LEM-15484
      Map<Id, List<Payment_Account__c>> relevantPaymentAccounts = isBusinessAccount
        ? accountIdToPaymentAccounts
        : accountIdToPaymentsPaymentAccounts;
      for (WorkOrder eachWorkOrder : workOrders) {
        if (
          !relevantPaymentAccounts.containsKey(eachWorkOrder.AccountId) &&
          ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
            readinessValidationToTypeToSubTypes,
            storeReadinessValidationRule,
            eachWorkOrder
          ) && !ReadinessValidationRulesService.isBypassedBySegmentTypeSubType(storeReadinessValidationRule.DeveloperName, eachWorkOrder)
          // Skip Shopping Protocol value check for 'Drive' (parent) work orders.
          && (eachWorkOrder.ParentWorkOrderId == null ||
          ReadinessValidationRulesService.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
            eachWorkOrder,
            accountIdToAlocoholDeliveryQuoteLines
          ))
        ) {
          logReadinessCheckFailure(
            storeReadinessValidationRule,
            eachWorkOrder,
            null
          );
        }
      }
    }
  }
