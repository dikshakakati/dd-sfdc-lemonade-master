/**
 * @author DoorDash
 * @date 03/25/2024
 * @description Service class for processing new integration requests and making work plan current.
 */
public interface IOrderProtocolUpdatesService {

    /**
     * @description It is used for processing the store Accounts Order Protocol updates on the WO(s)
     * @param storeAccountMap
     */
    void processOrderProtocolUpdatesOnStoreAccounts(Map<Id, Account> storeAccountMap);
}