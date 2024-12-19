/**
 * @author DoorDash
 * @date 06/30/2022
 * @description Interface to add selector class methods
 */
public interface IQuoteLineDrawAttributesSelector extends fflib_ISObjectSelector {

    /**
     * @description This method is for getting the fields on Quote_Line_Drawer_Attributes__mdt
     * @return List<Schema.SObjectField>- Quote_Line_Drawer_Attributes__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is for getting Quote Line Attributes for a particular product
     * @JIRA# LEM-6458
     * @param prodCode
     * @return List<Quote_Line_Drawer_Attributes__mdt>
     */
    List<Quote_Line_Drawer_Attributes__mdt> selectQLAttributesByProductCode(String prodCode);
}