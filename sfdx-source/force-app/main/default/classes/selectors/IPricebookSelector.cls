/**
 * @description Interface to add Pricebook Selector  class methods
 * @author Deloitte
 */
public interface IPricebookSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting standard pricebook
     * @return Pricebook2
     */
    Pricebook2 selectStandardPricebook();
}