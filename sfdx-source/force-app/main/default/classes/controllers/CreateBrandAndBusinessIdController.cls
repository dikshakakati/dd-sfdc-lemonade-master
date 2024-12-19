/**
 * @author Aethereus
 * @date 03/13/2023
 * @description Controller class for the CreateBrandAndBusinessIdQuickAction LWC component.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class CreateBrandAndBusinessIdController {

    private static final Set<String> FIELD_TO_WRAP_TEXT = new Set<String>{ 'Store Account' };
    private static final String ACCOUNT_LABEL = 'Account';
    private static final String LABEL = 'label';
    private static final String NAME = 'Name';


    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STAGE_FLOW_INITIATED = 'Flow Initiated';
    private static final String REQUEST_STAGE_FLOW_COMPLETED = 'Flow Completed';
    private static final String BRAND_UNIQUE_IDENTIFIER = 'Brand__c';

    private static final String BUSINESS_REFERENCE_DUPLICATE_COMBINATION = 'You have already entered this combination';
    private static final String BUSINESS_REFERENCE_ALREADY_EXIST_IN_DB = 'This combination is already present in Database';
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';


    /**
     * @description check if the business reference is unique or not
     * @param businessRefListJSON json containing list of busines reference
     * @return Map<String,String>
     */
    @AuraEnabled
    public static Map<String,String> checkIfBusinessReferenceUnique(String businessRefListJSON){
        Map<String, String> brefKeyToErroMapping = new Map<String, String>();
        Map<String, Business_Reference__c> businessReferenceKeyToBusinessReferenceMap = new Map<String, Business_Reference__c>();


        // Process provided Business References
        List<Business_Reference__c> brefList = (List<Business_Reference__c>) JSON.deserialize(businessRefListJSON, List<Business_Reference__c>.class);
        List<Business_Reference__c> brefListForDatabaseCheck = new  List<Business_Reference__c>();

        for (Business_Reference__c businessReference : brefList) {
            processBusinessReference(businessReference, brefKeyToErroMapping, businessReferenceKeyToBusinessReferenceMap);
            if(businessReference.Brand__c == NULL){
                continue;
            }
            brefListForDatabaseCheck.add(businessReference);

        }

        // Early return if no errors found
        if (businessReferenceKeyToBusinessReferenceMap.isEmpty()) {
        return brefKeyToErroMapping;
        }

        // Check for duplicates in database
        List<Business_Reference__c> existingReferences =new List<Business_Reference__c>();
        if(brefListForDatabaseCheck != NULL && !brefListForDatabaseCheck.isEmpty()){
            existingReferences = BusinessReferencesSelector.newInstance()
            .selectByBusinessReferenceUniqueIdentifierFields(brefListForDatabaseCheck);

        }


        for (Business_Reference__c existingReference : existingReferences) {
            String key = generateKey(existingReference);
            handleDuplicateInDatabase(key, brefKeyToErroMapping, businessReferenceKeyToBusinessReferenceMap);
        }

        // Add any remaining records without errors
        handleBusinessRefWithNoErrors(brefList, brefKeyToErroMapping);
        return brefKeyToErroMapping;

    }


     /**
     * @description It process Business Reference .
     * @param businessReference  business reference.
     * @param mapping  Map<String, String>.
     * @param businessReferenceMap  Map<String, Business_Reference__c>.
     */
    private static void processBusinessReference(Business_Reference__c businessReference, Map<String, String> mapping, Map<String, Business_Reference__c> businessReferenceMap) {
        String key = generateKey(businessReference);
        if (key == null) {
            return; // Skip if key is null
        }
        if (businessReferenceMap.containsKey(key)) {
            mapping.put(key, BUSINESS_REFERENCE_DUPLICATE_COMBINATION);
        } else {
            businessReferenceMap.put(key, businessReference);
        }
    }


    /**
     * @description It handle Duplicate In Database .
     * @param key uniqueness key.
     * @param mapping  Map<String, String>.
     * @param businessReferenceMap  Map<String, Business_Reference__c>.
     */
    private static void handleDuplicateInDatabase(String key, Map<String, String> mapping, Map<String, Business_Reference__c> businessReferenceMap) {
        if (businessReferenceMap.containsKey(key)) {
            String existingValue = mapping.get(key);
            if (existingValue != null) {
              mapping.put(key, existingValue + ' & ' + BUSINESS_REFERENCE_ALREADY_EXIST_IN_DB);
            } else {
              mapping.put(key, BUSINESS_REFERENCE_ALREADY_EXIST_IN_DB);
            }
          }
    }


    /**
     * @description It pushes empty string in the value if no errors found .
     * @param brefList  List<Business_Reference__c>.
     * @param mapping  Map<String, String>.
     */
    private static void handleBusinessRefWithNoErrors(List<Business_Reference__c> brefList, Map<String, String> mapping) {
        for (Business_Reference__c businessReference : brefList) {
            String key = generateKey(businessReference);
            if (key != null
                    && !mapping.containsKey(key)) {
                mapping.put(key, '');
            }
        }
    }


     /**
     * @description It generates uniquness key.
     * @param businessReference  business reference, based on it's field key will be generated.
     * @return String
     */
    private Static String generateKey(Business_Reference__c businessReference) {
            String retVal = '';
            for (SObjectField field : BusinessReferences.UNIQUE_IDENTIFIER_FIELDS) {
                if (String.isBlank((String) businessReference.get(field))
                        && String.valueOf(field) != BRAND_UNIQUE_IDENTIFIER ) {
                    return null;
                }
                retVal += (String) businessReference.get(field);
            }
            return retVal;
        }


    /**
    * @description check whether a brand name exists in database or not.
    * @param brandNames
    * @return List<Brand__c>
    **/
    @AuraEnabled
    public static List<Brand__c> validateBrands(List<String> brandNames) {
        return (List<Brand__c>) Security.stripInaccessible(
                AccessType.READABLE,
                BrandsSelector.newInstance()
                    .getBrandsByBrandName(brandNames
                    )
            )
            .getRecords();
    }


    /**
     * @description insert brands in salesforce
    * @param brandNamesVsPriceRange
    * @param ownerID
    * @return List<Brand__c>
    **/
    @AuraEnabled
    public static List<Brand__c> insertBrands(String brandNamesVsPriceRange, ID ownerID) {
        Map<String, Object> brandNamesVsPriceRangeMap = (Map<String, Object>)JSON.deserializeUntyped(brandNamesVsPriceRange);
        set<Id> brandIds = new set<Id>();

            List<Brand__c> brandList = new List<Brand__c>();
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            for(String eachBrand : brandNamesVsPriceRangeMap.keySet()){
                    Brand__c newBrand = new Brand__c();
                            newBrand.Name = eachBrand;
                            newBrand.Price_Range__c = (String)brandNamesVsPriceRangeMap.get(eachBrand);
                            newBrand.Brand_Owner__c = ownerID;
                            newBrand.Source__c = 'Opportunity';
                    brandList.add(newBrand);
            }

            uow.registerNew(brandList);
            try {
                    uow.commitWork();
                    for(Brand__c eachBrand : brandList){
                        brandIds.add(eachBrand.Id);
                    }
                    BrandAssociationsService.createBrandAssociations(brandIds);
                    return brandList;

            } catch (Exception e) {
                    Logger.publish(LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.HIGH));
                    String serviceName = 'Brand And BizRef Automation - insertBrands';
                    GenericLoggerService.publish(GenericLoggerService.createGenericLog(
                            serviceName,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException (e));
                    throw new AuraHandledException('Failed to insert Brand: ' + e.getMessage());
            }
    }


    /**
     * @description It is used to fetch Existing Brands associated to Opportunity's Parent Account.
     * @param accountId
     * @return List<Brand_Association__c>
     */
     @AuraEnabled(cacheable=true)
     public static List<Brand_Association__c> fetchExistingAssociatedBrands(ID accountId) {
         return (List<Brand_Association__c>) Security.stripInaccessible(
                 AccessType.READABLE,
                 BrandAssociationsSelector.newInstance()
                     .selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(accountId
                     )
             )
             .getRecords();
     }

    /**
     * @description LEM-14427, It is used to fetch list of Business Reference the business Group IDs associated with an account.
     * @param accountId
     * @return List<Business_Reference__c>
     */
    @AuraEnabled
    public static List<Business_Reference__c> fetchBGGroupIdsAssociatedWithAccount(ID accountId) {
        return (List<Business_Reference__c>) Security.stripInaccessible(
                AccessType.READABLE,
                BusinessReferencesSelector.newInstance()
                    .selectBGGroupIdByAccountId(accountId
                    )
            )
            .getRecords();
    }

    /**
     * @description
    * @author rishab.goyal | 03-19-2024
    * @param jsonString json string received from the component
    * @param isCalledFromOpportunity determine from where the flow is being initiated.
     * @return BrandWrapper.CaseWithListOfBrandAndBizRefs
    **/
    @AuraEnabled
    public static BrandWrapper.CaseWithListOfBrandAndBizRefs createBrandAndBizRefs(String jsonString, Boolean isCalledFromOpportunity) {
            List<BrandWrapper> dataList = (List<BrandWrapper>) JSON.deserialize(jsonString, List<BrandWrapper>.class);
            BrandWrapper.CaseWithListOfBrandAndBizRefs returnVal = new BrandWrapper.CaseWithListOfBrandAndBizRefs();

            populateListOfBrandAndBusinessReferencesList(dataList, returnVal);
            String sourceObject = isCalledFromOpportunity ? 'Opportunity' :'Contract';
            List<Brand__c> brandsToInsert = BrandWrapper.getAllBrandsToInsert(returnVal.brandAndBizRefsList, sourceObject);
            if(!brandsToInsert.isEmpty()){
                createBrandFromBrandAndBizRefs(brandsToInsert);
                Set<Id> brandIds = BrandWrapper.getAllBrandIds(returnVal.brandAndBizRefsList);
                List<Brand_Association__c> createdBrandAssociations = BrandAssociationsService.createBrandAssociations(brandIds);
                Set<Id> brandAsscIdsToCreateOBR = BrandWrapper.getAllBrandAssociationIds(dataList);
                handleBrandAssociations(sourceObject, dataList[0].recordId, brandAsscIdsToCreateOBR, createdBrandAssociations,brandIds);

            }
            else{
                List<Brand_Association__c> existingBrandAssociation = BrandAssociationsSelector.newInstance().selectByBrandsAndBusinessAccountIds(new set<Id>{dataList[0].brandId},new set<id>{dataList[0].accountId});
                Set<Id> existingBrandAssociationId = new map<Id,Brand_Association__c>(existingBrandAssociation).keySet();
                List<Brand_Association__c> createdBrandAssociation =  new List<Brand_Association__c>();
                handleBrandAssociations(sourceObject, dataList[0].recordId, existingBrandAssociationId,createdBrandAssociation,new set<Id>{dataList[0].brandId});
            }

            List<Business_Reference__c> bizRefsToInsert = BrandWrapper.getAllBizRefsToInsert(returnVal.brandAndBizRefsList);
            if(!bizRefsToInsert.isEmpty()) {
                createBusinessRefsFromBrandAndBizRefs(bizRefsToInsert);
            }


            if (sourceObject == 'Opportunity') {
                returnVal.caseRecord = new Case(
                    AccountId = dataList[0].accountId,
                    Opportunity__c = dataList[0].recordId,
                    Priority = 'Normal',
                    Type = 'Business Hierarchy Assistance',
                    Sub_Type__c = 'Account Hierarchy Change',
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SO_Support_Request').getRecordTypeId()
                );

                generateSubjectAndDescriptionForSuccessCase(returnVal);
                createCaseFromBrandAndBizRefs(returnVal);
            }


        return returnVal;
    }

     /**
     * @description it is the handler to process Opportunity brand relations or contract brand associations to be created .
     * @param sourceObject - source object identifier.
     * @param recordId - record id.
     * @param brandAsscIdsToCreateOBR - List of brand associations ids.
     * @param createdBrandAssociations - brand associations list
     * @param brandIds  - brand ids
     */
    private static void handleBrandAssociations(String sourceObject, Id recordId, Set<Id> brandAsscIdsToCreateOBR, List<Brand_Association__c> createdBrandAssociations,Set<Id> brandIds) {
        if (sourceObject == 'Opportunity') {
          removeExistingBrandAssociationsIfOBRAlreadyExists(brandAsscIdsToCreateOBR, recordId);
          if (!createdBrandAssociations.isEmpty()) {
            brandAsscIdsToCreateOBR.addAll(new Map<Id, Brand_Association__c>(createdBrandAssociations).keySet());
          }
          if (!brandAsscIdsToCreateOBR.isEmpty()) {
            OpportunityBrandRelationshipsService.createOpportunityBrandRelationShips(recordId, brandAsscIdsToCreateOBR);
          }
        } else if (sourceObject == 'Contract') {
          // Existing logic for Contract handling brand associations
          removeExistingBrandAssociationsIfCBAAlreadyExists(brandIds, recordId);
          ContractBrandAssociationsService.createContractBrandAssociaitons(recordId, brandIds);
        }
      }


   /**
     * @description This method is being called from crateBrandAndBizRef and create case.
     * @param returnVal - List of case to be inserted.
     */
    private static void createCaseFromBrandAndBizRefs( BrandWrapper.CaseWithListOfBrandAndBizRefs returnVal){
        try{
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(returnVal.caseRecord);
            uow.commitWork();
        }
        catch(Exception createBrandAndBizRefsException){
            String serviceName = 'Brand And BizRef Automation - createBrandAndBizRefs';
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(serviceName,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException(createBrandAndBizRefsException));
        }
    }

    /**
     * @description This method is being called from crateBrandAndBizRef and create BusinessRefs.
     * @param bizRefsToInsert - List of business references to be inserted.
     */
    private static void createBusinessRefsFromBrandAndBizRefs( List<Business_Reference__c> bizRefsToInsert){
        try{
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(bizRefsToInsert);
            uow.commitWork();
        }
        catch(Exception createBrandAndBizRefsException){
            String serviceName = 'Brand And BizRef Automation - createBrandAndBizRefs';
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(serviceName,LOG_DOMAIN_SALES_TO_CONTRACT, GenericLogEntry.SeverityLevel.MEDIUM).logException(createBrandAndBizRefsException));
        }
    }

     /**
     * @description This method is being called from crateBrandAndBizRef and create Brands.
     * @param brandsToInsert - List of brands to be inserted.
     */
    private static void createBrandFromBrandAndBizRefs( List<Brand__c> brandsToInsert){
        try{
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(brandsToInsert);
            uow.commitWork();
        }
        catch(Exception createBrandAndBizRefsException){
            String serviceName = 'Brand And BizRef Automation - createBrandAndBizRefs';
            GenericLoggerService.publish( GenericLoggerService.createGenericLog(serviceName,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException(createBrandAndBizRefsException));
        }
    }

    /**
     * @description This method generates the subject and description for the success case of creating a brand and business ID.
     * @param caseWithListOfBrandAndBizRefs - The wrapper class containing the case record and a list of brand and business references.
     */
    @TestVisible
    private static void generateSubjectAndDescriptionForSuccessCase(BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs) {

            Set<String> queryFields = new Set<String> {'Id', 'Name', 'Owner.Name', 'Segment__c', 'Primary_Vertical__c', 'BillingCountry'};
            Account acc = AccountsSelector.newInstance()
            .selectAccountWithOutFilterswithSetOfFieldsPassed(queryFields, new Set<Id>{caseWithListOfBrandAndBizRefs.caseRecord.AccountId})[0];

            caseWithListOfBrandAndBizRefs.caseRecord.Subject = acc.Name + ' - Confirm Business Group';
            caseWithListOfBrandAndBizRefs.caseRecord.Description =
            BrandWrapper.getUrlsOfBizRefs(caseWithListOfBrandAndBizRefs.brandAndBizRefsList)
            +' Segment : '+acc.Segment__c + '\n'
            +' Account Owner:  '+acc.Owner.Name + '\n'
            +' Primary Vertical: '+acc.Primary_Vertical__c + '\n'
            +' Business Account Country: '+acc.BillingCountry;

    }

    /**
     * @description Removes existing brand associations if Opportunity Brand Relationship (OBR) already exists.
     * @param brandAsscIds   A set of brand association IDs.
     * @param opportuintyId  The ID of the opportunity.
     */
    @TestVisible
    private static void removeExistingBrandAssociationsIfOBRAlreadyExists(Set<Id> brandAsscIds, Id opportuintyId) {
            if(!brandAsscIds.isEmpty()){
                    List<Opportunity_Brand_Relationship__c> existingOBRs = OpportunityBrandRelationshipsSelector.newInstance()
                    .selectByOpportunityAndBrandAsscs(opportuintyId, brandAsscIds);
                    if(!existingOBRs.isEmpty()){
                            for(Opportunity_Brand_Relationship__c obr : existingOBRs){
                                    brandAsscIds.remove(obr.Brand__c);
                            }
                    }
            }
    }

     /**
     * @description Removes existing brands if Contract Brand Association (OBA) already exists.
     * @param brandIds   A set of brand IDs.
     * @param contractId  The ID of the opportunity.
     */
    @TestVisible
    private static void removeExistingBrandAssociationsIfCBAAlreadyExists(Set<Id> brandIds, Id contractId) {
        if(!brandIds.isEmpty()){
                List<Contract_Brand_Association__c> existingContractBrandAssociations = ContractBrandAssociationsSelector.newInstance()
                .selectByContractAndBrandAsscs(contractId, brandIds);
                if(!existingContractBrandAssociations.isEmpty()){
                        for(Contract_Brand_Association__c cba : existingContractBrandAssociations){
                            brandIds.remove(cba.Brand__c);
                            }
                    }
            }
    }

    /**
     * @description Populates the list of brand and business references list in the given caseWithListOfBrandAndBizRefs
     * based on the provided brandWrapperList.
     * @param brandWrapperList - The list of BrandWrapper objects to populate.
     * @param caseWithListOfBrandAndBizRefs - The CaseWithListOfBrandAndBizRefs object containing the data.
     */
    private static void populateListOfBrandAndBusinessReferencesList(List<BrandWrapper> brandWrapperList, BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs){
            for (BrandWrapper data : brandWrapperList) {
                    Brand__c brand = new Brand__c(Name = data.brandName,
                                                    Brand_Owner__c = data.accountId,
                                                    Price_Range__c = data.priceRange,
                                                    Brand_Type__c = data.brandType,
                                                    Id=data.brandId);

                    List<Business_Reference__c> bizRefs = new List<Business_Reference__c>();
                    for (BrandWrapper.BizRef bizRef : data.bizRefList) {
                            Business_Reference__c businessReference = new Business_Reference__c(
                            Business_Name__c = bizRef.businessName,
                            Business_Vertical__c = bizRef.businessVerticalId,
                            Business_Group_Id__c = bizRef.businessGroupId,
                            Selling_Country_Code__c  = bizRef.sellingCountryCode,
                            CurrencyIsoCode = data.currencyOfAccount,
                            Brand__c = brand.Id,
                            Default_Type__c = 'Corporate',
                            Integration_Status__c = 'Ready For Integration',
                            External_Id_Source__c = 'MDS',
                            Created_Source_Id__c = data.recordId,
                            Created_Source_Object__c = data.createdSource
                            );
                            bizRefs.add(businessReference);
                    }
                    caseWithListOfBrandAndBizRefs.brandAndBizRefsList.add(new BrandWrapper.BrandAndBizRefs(brand, bizRefs));
            }
    }




    /**
    * @description recieves an Opportunity Id to Fetch the open Brand and Business Request for the Opportunity
    * @author rishab.goyal | 03-14-2024
    * @param recordId
    * @return Process_Flow_Request__c
    **/
    private static Process_Flow_Request__c getFlowRequestforBrandAndBusinessReferenceByOpportunityId(Id recordId) {
        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance().selectOpenBrandAndBusinessRequestsForOpportunityAndUser(recordId);
        return (requests != null && !requests.isEmpty()) ? requests[0] : null;
    }

    /**
    * @description  recieves an Contract Id to Fetch the open Brand and Business Request for the Opportunity
    * @author rishab.goyal | 03-14-2024
    * @param recordId
    * @return Process_Flow_Request__c
    **/
    private static Process_Flow_Request__c getFlowRequestforBrandAndBusinessReferenceByContractId(Id recordId) {
        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance().selectOpenBrandAndBusinessRequestsForContractAndUser(recordId);
        return (requests != null && !requests.isEmpty()) ? requests[0] : null;
    }

    /**
    * @description creates a new flow Request record when the flow is initiated.
    * @author rishab.goyal | 03-14-2024
    * @param recordId
    * @param sObjectType - String ( Opportunity | Contract )
    * @return Process_Flow_Request__c
    **/
    @AuraEnabled
    public static Process_Flow_Request__c createFlowRequest(Id recordId, String sObjectType) {
        Process_Flow_Request__c request = null;
        if (sObjectType == 'Opportunity') {
            request = getFlowRequestforBrandAndBusinessReferenceByOpportunityId(recordId);
        } else if (sObjectType == 'Contract') {
            request = getFlowRequestforBrandAndBusinessReferenceByContractId(recordId);
        }
        if(request==null){
            request = new Process_Flow_Request__c();
            request.RecordTypeId =  Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName().get(BRANDANDBUSINESSFLOW_RECORDTYPE).getRecordTypeId();
            if (sObjectType == 'Opportunity') {
                request.Opportunity__c = recordId;
            } else if (sObjectType == 'Contract') {
                request.Contract__c = recordId;
            }
            request.Status__c = REQUEST_STATUS_IN_PROGRESS;
            request.Stage__c = REQUEST_STAGE_FLOW_INITIATED;
            request = commitProcessFlowRequestUpdates(request);
        }
        return request;
    }


   /**
   * @description updates the flow request when the UI flow ends.
   * @author rishab.goyal | 03-14-2024
   * @param recordId
   * @param sObjectType
   * @param serializedData
   * @return Process_Flow_Request__c
   **/
   @AuraEnabled
    public static Process_Flow_Request__c updateFlowRequestStatus(Id recordId, String sObjectType, String serializedData) {
        Process_Flow_Request__c request = null;
        if (sObjectType == 'Opportunity') {
            request = getFlowRequestforBrandAndBusinessReferenceByOpportunityId(recordId);
        } else if (sObjectType == 'Contract') {
            request = getFlowRequestforBrandAndBusinessReferenceByContractId(recordId);
        }

        if(request!=null){
            request.Status__c = REQUEST_STATUS_COMPLETED;
            request.Stage__c = REQUEST_STAGE_FLOW_COMPLETED;
            request.Serialized_Object_Data__c  = serializedData;
            request = commitProcessFlowRequestUpdates(request);
        }
        return request;
    }


     /**
     * @description Takes an inputted Process_Flow_Request__c record and commits the updates using fflib Unit of Work pattern
     * @param flowRequest - Process_Flow_Request__c record (with updates already applied) to commit DML on
     * @return Process_Flow_Request__c
    **/
     public static Process_Flow_Request__c commitProcessFlowRequestUpdates(Process_Flow_Request__c flowRequest) {
        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Process_Flow_Request__c.sObjectType }
        );

         if(flowRequest.Id!=null){
             UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
             uowInstance.registerWork(uowUpdateHelper);
             uowUpdateHelper.registerUpdate(flowRequest);
             try {
                 uowInstance.commitWork();
             } catch (Exception e) {
                 Logger.publish(LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.HIGH));
                 String serviceName = 'Brand And BizRef Automation - commitProcessFlowRequestUpdates';
                 GenericLoggerService.publish(GenericLoggerService.createGenericLog(serviceName,LOG_DOMAIN_SALES_TO_CONTRACT, GenericLogEntry.SeverityLevel.MEDIUM).logException(e));
                 throw new AuraHandledException('Failed to update Process Flow Request: ' + e.getMessage());
             }
         }
         else{
             fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
             uow.registerNew(flowRequest);
             try {
                 uow.commitWork();
             } catch (Exception e) {
                 Logger.publish(LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.HIGH));
                 String serviceName = 'Brand And BizRef Automation - commitProcessFlowRequestUpdates';
                 GenericLoggerService.publish(GenericLoggerService.createGenericLog( serviceName, LOG_DOMAIN_SALES_TO_CONTRACT, GenericLogEntry.SeverityLevel.MEDIUM).logException(e));
                 throw new AuraHandledException('Failed to insert Process Flow Request: ' + e.getMessage());
             }
         }
        return flowRequest;
    }

    /**
    * @description
    * @author rishab.goyal | 03-26-2024
    * @param recordId
    * @return List<Business_Reference__c>
    **/
    @AuraEnabled(cacheable=true)
    public static List<Business_Reference__c> getBusinessReferencesBySourceId(Id recordId) {

        // identifies if the record id is Contract or Opportunity
        Schema.SObjectType sobjectApiName = recordId.getsobjecttype();
        Schema.SObjectType contractObject = Schema.Contract.getSObjectType();
        Schema.SObjectType opportunityObject = Schema.Opportunity.getSObjectType();
        List<Id> recordIds = new List<Id>();

        if(sobjectApiName == opportunityObject){
            for(Contract eachContract : ContractsSelector.newInstance().selectContractsByOpportunityId(recordId)){
                recordIds.add(eachContract.Id);
            }
        }
        else if(sobjectApiName == contractObject){
            for(Opportunity eachOpportunity : OpportunitiesSelector.newInstance().selectOpportunitiesByContractId(recordId)){
                recordIds.add(eachOpportunity.Id);
            }
        }
        recordIds.add(recordId);

        BusinessReferencesSelector selector = new BusinessReferencesSelector();
        List<Business_Reference__c> businessReferences = selector.selectBySourceIds(recordIds);

        return businessReferences;
    }

    @AuraEnabled(cacheable=true)
    /**
     * @description Retrieves the Business Vertical record based on the provided record ID.
     * @param recordId The ID of the record.
     * @return The Business Vertical record.
     */
    public static Business_Vertical__c getBusinessVerticals(Id recordId) {
        BusinessVerticalsSelector selector = new BusinessVerticalsSelector();
        List<Business_Vertical__c> businessvertical  = selector.selectById(new Set<ID>{recordId});
        return  (businessvertical != null && !businessvertical.isEmpty()) ? businessvertical[0] : null;
    }
}