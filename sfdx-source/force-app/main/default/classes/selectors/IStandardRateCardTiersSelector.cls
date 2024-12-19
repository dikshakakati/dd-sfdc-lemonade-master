/**
 * @author DoorDash
 * @date 08/25/2023
 * @description Selector interface for the Standard_Rate_Card_Tier__mdt custom metadata.
**/
public interface IStandardRateCardTiersSelector extends fflib_ISObjectSelector {
    /**
     * @description It fetches all records of Standard Rate Card Tier metadata.
     * @return List<Standard_Rate_Card_Tier__mdt> - Returns list of metadata records
     */
    List<Standard_Rate_Card_Tier__mdt> getAllValues();
}