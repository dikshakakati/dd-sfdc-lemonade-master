/**
 * @description Interface for selecting Ressmo configurations.
 */
public Interface IRessmoConfigurationsSelector extends fflib_ISObjectSelector {

    /**
     * @description Selects the Ressmo Eligibility Configuration.
     * @return RESSMO_Configuration__mdt The selected Ressmo Eligibility Configuration.
     */
    RESSMO_Configuration__mdt selectRessmoEligibilityConfiguration();
}