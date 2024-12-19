/**
 * @author CriticalRiver
 * @date Sep 20, 2024
 * @description Wrapper used by lwcDdMultiSelectPicklist lwc/CDdMutliSelectPicklist code -- UI will read this wrapper to render the results
 */
 public class MultiSelectPicklistWrapper {
    @Auraenabled public String dropDownLabel;
    @Auraenabled public String dropDownSubLabel;
    @Auraenabled public String pillLabel;
    @Auraenabled public String value;
    @Auraenabled public String iconSrc;
    @Auraenabled public String obj;
    @Auraenabled public String operator;

    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description Set values of the Wrapper by default
     */
    public MultiSelectPicklistWrapper() {
        this.obj = obj;
    }

    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description Set values of the Wrapper by user input
     * @param obj Define the Sobject type
     */
    public MultiSelectPicklistWrapper(Sobject obj) {
        this.obj = JSON.serialize(obj);
    }
}