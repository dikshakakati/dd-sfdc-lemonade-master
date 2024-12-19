/**
 * @author Gaurav Bisht
 * @date 03/07/2024
 * @description Service Implementation of Contract_Brand_Association__c related logic
 */
public inherited sharing class ContractBrandAssociationsServiceImpl implements IContractBrandAssociationsService{
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';
    private static final String SERVICE_CREATE_BRAND_ASSOCIATION = 'Brand And BizRef Automation - createContractBrandAssociaiton';
    private static final String SERVICE_CREATE_BRAND_ASSOCIATIONS = 'Brand And BizRef Automation - createContractBrandAssociaitons';
    private static final String ACTIVE_STATUS = 'Active';


    /**
     * @description Creates a new Contract_Brand_Association__c record and associates it with the specified Contract and Brand.
     * @param contractId The Id of the Contract to associate with the new record.
     * @param brandAsscId The Id of the Brand to associate with the new record.
     * @return The newly created Contract_Brand_Association__c record.
     */
    public static Contract_Brand_Association__c createContractBrandAssociaiton(Id contractId, Id brandAsscId){
        try {
            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            Contract_Brand_Association__c obr = (
                new Contract_Brand_Association__c
                 (Brand__c= brandAsscId,
                 Contract__c  = contractId,
                 Status__c = ACTIVE_STATUS
                 ));
            uow.registerNew(obr);
            uow.commitWork();
            return obr;
        } catch (Exception createContractBrandAssociaitonException) {
            GenericLoggerService.publish( GenericLoggerService.createGenericLog(SERVICE_CREATE_BRAND_ASSOCIATION,LOG_DOMAIN_SALES_TO_CONTRACT, GenericLogEntry.SeverityLevel.MEDIUM).logException(createContractBrandAssociaitonException));
        }
        return NULL;
    }

    /**
     * @description Creates Contract Brand Associations for a given Contract and a set of Brand Association IDs.
     * @param contractId The ID of the Contract for which the Brand Relationships are to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Contract.
     * @return A list of Contract_Brand_Association__c records representing the created relationships.
     */
    public static List<Contract_Brand_Association__c> createContractBrandAssociaitons(Id contractId, Set<Id> brandAsscIds){
        try {

            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            List<Contract_Brand_Association__c> obrs = new List<Contract_Brand_Association__c>();
            for(Id brandAsscId : brandAsscIds){
                obrs.add(
                    new Contract_Brand_Association__c
                         (Brand__c= brandAsscId,
                         Contract__c  = contractId,
                         Status__c = ACTIVE_STATUS
                         )
                   );
            }
            uow.registerNew(obrs);
            uow.commitWork();
            return obrs;

        } catch (Exception createContractBrandAssociaitonsException) {

            GenericLoggerService.publish( GenericLoggerService.createGenericLog(SERVICE_CREATE_BRAND_ASSOCIATIONS,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException(createContractBrandAssociaitonsException));

        }
        return NULL;

    }

}