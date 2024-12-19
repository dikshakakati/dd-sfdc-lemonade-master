/**
 * @author Deloitte
 * @date 29/07/2022
 * @description Interface to add selector class methods.
 */
public interface IEncryptedFieldsConfigurationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting the configuration related to the object on which viewEncryptedData
     * lightning web component is added.
     * @param componentLocation
     * @return List<Encrypted_Fields_Configuration__mdt>
     */
    List<Encrypted_Fields_Configuration__mdt> selectByComponetLocationAndObjectApiName(
        String componentLocation
    );
}