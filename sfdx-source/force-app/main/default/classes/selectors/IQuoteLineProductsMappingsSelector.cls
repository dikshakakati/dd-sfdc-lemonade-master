/**
 * @author DoorDash
 * @date 06/30/2022
 * @description Interface to add selector class methods
 */
public interface IQuoteLineProductsMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on Legal_Entity_Mapping__mdt
     * @return List<Schema.SObjectField>- Quote_Line_Drawer_Products__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
    /**
     * @description Method fetches all metadata records
     * @return List<Quote_Line_Drawer_Products__mdt> - returns list of metadata records
     */
    List<Quote_Line_Drawer_Products__mdt> getAllActiveQuoteLineProducts();
    /**
     * @description Method fetches all metadata records
     * @return List<Quote_Line_Drawer_Products__mdt> - returns list of metadata records
     */
    List<Quote_Line_Drawer_Products__mdt> selectQLProductsWithAttributes();

    /**
     * @description It is used to fetch Quote Line Products with Attributes related to the passed set of Product Codes.
     * @param productCodes
     * @return List<Quote_Line_Drawer_Products__mdt>
     */
    List<Quote_Line_Drawer_Products__mdt> selectQLProductsWithRequiredAttributesByProductCode(
        Set<String> productCodes
    );
}