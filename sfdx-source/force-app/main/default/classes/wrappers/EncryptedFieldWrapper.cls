/**
 * @author Deloitte
 * @date 07/26/2022
 * @description It is used for sending information about encrypted fields of an object to
 * viewEncryptedData lightning web component.
 */
public class EncryptedFieldWrapper {
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public String fieldHelpText;
    @AuraEnabled
    public String fieldLabel;
    @AuraEnabled
    public Integer fieldLength;
    @AuraEnabled
    public String fieldType;
    @AuraEnabled
    public String fieldValue;
    @AuraEnabled
    public Boolean isEditable;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param fieldApiName
     * @param fieldLabel
     * @param fieldType
     * @param fieldValue
     * @param isEditable
     */
    public EncryptedFieldWrapper(
        String fieldApiName,
        String fieldLabel,
        String fieldType,
        String fieldValue,
        Boolean isEditable
    ) {
        this.fieldApiName = fieldApiName;
        this.fieldHelpText = '';
        this.fieldLength = 0;
        this.fieldLabel = fieldLabel;
        this.fieldType = fieldType;
        this.fieldValue = fieldValue;
        this.isEditable = isEditable;
    }
}