/**
 * @author DoorDash
 * @date 03/25/2024
 * @description Service class for processing order protocol updates.
 */
public with sharing class OrderProtocolUpdatesService {

    private static IOrderProtocolUpdatesService service() {
        return (IOrderProtocolUpdatesService) Application.SERVICE.newInstance(IOrderProtocolUpdatesService.class);
    }
    /**
     * @description It is used for processing the store Accounts Order Protocol updates on the WO(s)
     * @param storeAccountMap
     */
    public static void processOrderProtocolUpdatesOnStoreAccounts(Map<Id, Account> storeAccountMap) {
        service().processOrderProtocolUpdatesOnStoreAccounts(storeAccountMap);
    }
}