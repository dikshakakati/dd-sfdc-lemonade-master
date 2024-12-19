/**
 * @author Deloitte
 * @date 11/08/2022
 * @description This is the service interface for the accounts provisioning service for Drive
 */
public interface IXrefAndBizRefService {
    /**
     * @description Generic method to create Xrefs and Business Refs for Account Provisioning
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param autoCreate
     * @param isParentWorkOrder
     */
    void createXRefsAndBusinessRefs(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean autoCreate,
        Boolean isParentWorkOrder
    );

    /**
     * @description It is used to create Xrefs and Business Refs for Accounts Provisioning using
     * the passed Mp Bz Ids.
     * @param accountIdToMpBzId
     * @param bizRefStatus
     * @param xRefStatus
     * @param isAutoCreate
     * @param isParentWorkOrder
     */
    void createXrefsAndBusinessRefsByMpBzIds(
        Map<Id, String> accountIdToMpBzId,
        String bizRefStatus,
        String xRefStatus,
        Boolean isAutoCreate,
        Boolean isParentWorkOrder
    );

    /**
     * @description It is used to create Xrefs and Business Refs for SMB Accounts Provisioning.
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param autoCreate
     * @param isParentWorkOrder
     */
    void createXrefsAndBusinessRefsForSMB(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean autoCreate,
        Boolean isParentWorkOrder
    );

    /**
     * @description It is used to deactivate Xrefs for the passed store account ids.
     * @param storeAccountIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    fflib_ISObjectUnitOfWork deactivateChurnedMxXrefs(
        Set<Id> storeAccountIds,
        fflib_ISObjectUnitOfWork uow
    );
}