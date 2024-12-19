/**
 * @author Aethereus
 * @date 03/06/2024
 * @description This is the Selector interface for Products Selector related logic
 */
public interface IProductsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting Products based on the provided Product Name
     * @return List<Product2>
     * @param productName - Products Name
     */
    List<Product2> selectProductByProductName(Set<String> productName);
}