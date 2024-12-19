/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface for Interface Transaction Configurations custom metadata type
 * selector class methods.
 */
public interface IInterfaceTransactionConfigSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting the instance on basis of the passed
     * developer name.
     * @param developerName
     * @return Interface_Transaction_Configuration__mdt
     */
    Interface_Transaction_Configuration__mdt getInstanceValue(String developerName);

    /**
     * @description It is used for getting the interface transaction configuration records..
     * @param interfaceTransactionNames
     * @return List<Interface_Transaction_Configuration__mdt>
     */
    List<Interface_Transaction_Configuration__mdt> selectByInterfaceTransactionNames(
        Set<String> interfaceTransactionNames
    );

    /**
     * @description It is used for all active interface transaction configuration records.
     * @return List<Interface_Transaction_Configuration__mdt>
     */
    List<Interface_Transaction_Configuration__mdt> selectAllActiveInterfaceTransactionCongis();
}