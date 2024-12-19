/**
 * @description       : Interface for ProcessFlowRequests
 * @author            : rishab.goyal
 * @group             :
 * @last modified on  : 03-20-2024
 * @last modified by  : rishab.goyal
**/
public interface IProcessFlowRequests extends fflib_ISObjects{

    /**
     * @description if an order is migrated,set the start date to the related quote's start date
     */
    void sendNotifcationsForProcessFlowRequestWithExternalIdsCreated();
}