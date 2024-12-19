/**
 * @description Interface to add domain class methods
 * @author Doordash
 * @date 2023-18-04
 */
public interface IXrefs extends ISObjects {
    /**
     * @description To Invoke COO process for these Xrefs LEM-5768
     */
    void invokeCooProcess();
    /**
     * @description update Integration Message and Provisioning Category
     */
    void updateIntegrationMessageAndProvisioningCategory();
    /**
     * @description It is used to invoke the calling of method
     * which is used to set Brand on Business References.
     * @param accountIdsWithXref
     */
    void invokeBrandOnBusinessReferencesByXrefs( Set<Id> accountIdsWithXref );

}