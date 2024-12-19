/**
 * @author Deloitte
 * @date 11/08/2022
 * @description This is the service interface for the accounts provisioning service for Drive
 */
public class XrefAndBizRefService {
    /** @description Generic method to create Xref and Biz Ref for Account Provisioning
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param autoCreate
     * @param isParentWorkOrder
     */
    public static void createXRefsAndBusinessRefs(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean autoCreate,
        Boolean isParentWorkOrder
    ) {
        service()
            .createXRefsAndBusinessRefs(
                workOrderAccountIds,
                bizRefStatus,
                xRefStatus,
                autoCreate,
                isParentWorkOrder
            );
    }

    /** @description It is used to create Xrefs and Business Refs for SMB Accounts Provisioning.
     * @param workOrderAccountIds
     * @param bizRefStatus
     * @param xRefStatus
     * @param autoCreate
     * @param isParentWorkOrder
     */
    public static void createXrefsAndBusinessRefsForSMB(
        Set<Id> workOrderAccountIds,
        String bizRefStatus,
        String xRefStatus,
        Boolean autoCreate,
        Boolean isParentWorkOrder
    ) {
        service()
            .createXrefsAndBusinessRefsForSMB(
                workOrderAccountIds,
                bizRefStatus,
                xRefStatus,
                autoCreate,
                isParentWorkOrder
            );
    }

    /**
     * @description It is used to create Xrefs and Business Refs for Accounts Provisioning using
     * the passed Mp Bz Ids.
     * @param accountIdToMpBzId
     * @param bizRefStatus
     * @param xRefStatus
     * @param isAutoCreate
     * @param isParentWorkOrder
     */
    public static void createXrefsAndBusinessRefsByMpBzIds(
        Map<Id, String> accountIdToMpBzId,
        String bizRefStatus,
        String xRefStatus,
        Boolean isAutoCreate,
        Boolean isParentWorkOrder
    ) {
        service()
            .createXrefsAndBusinessRefsByMpBzIds(
                accountIdToMpBzId,
                bizRefStatus,
                xRefStatus,
                isAutoCreate,
                isParentWorkOrder
            );
    }

    /**
     * @description It is used to deactivate Xrefs for the passed Store Account Ids.
     * @JIRA# LEM-23780
     * @param storeAccountIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    public static fflib_ISObjectUnitOfWork deactivateChurnedMxXrefs(
        Set<Id> storeAccountIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        return service().deactivateChurnedMxXrefs(storeAccountIds, uow);
    }

    private static IXrefAndBizRefService service() {
        return (IXrefAndBizRefService) Application.Service.newInstance(IXrefAndBizRefService.class);
    }
}