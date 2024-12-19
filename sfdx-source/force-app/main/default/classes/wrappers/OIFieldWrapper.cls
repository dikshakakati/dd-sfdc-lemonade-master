/**
 * @author Deloitte
 * @date 06/03/2024
 * @description OIFieldWrapper for OIUserForm lightning web component.
 */
public class OIFieldWrapper {
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public String fieldValue;
    @AuraEnabled
    public String fieldType;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param fieldApiName
     * @param fieldValue
     * @param fieldType
     */
    public OIFieldWrapper(String fieldApiName, String fieldValue, String fieldType) {
        this.fieldApiName = fieldApiName;
        this.fieldValue = fieldValue;
        this.fieldType = fieldType;
    }
}