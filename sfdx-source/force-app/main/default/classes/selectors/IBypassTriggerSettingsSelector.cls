/**
 * @author Deloitte
 * @date 03/01/2022
 * @description Interface for Bypass_Trigger_Setting__mdt custom metadata selector.
 */
public interface IBypassTriggerSettingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch all Bypass Trigger Setting records.
     * @return List<Bypass_Trigger_Setting__mdt>
     */
    List<Bypass_Trigger_Setting__mdt> getAllValues();
}