/**
 * @author Deloitte
 * @date 02/25/2022
 * @description Service class to implement bypass logic using custom metadata.
 */
public with sharing class BypassLogicModel {
    /**
     * @description It checks whether trigger context is bypassed for the passed context
     * @param sObjectName
     * @param triggerContext
     * @return Boolean - returns true when trigger is bypassed, else returns false
     */
    public static Boolean isTriggerBypassed(
        String sObjectName,
        System.TriggerOperation triggerContext
    ) {
        return service().isTriggerBypassed(sObjectName, triggerContext);
    }

    /**
     * @description It sets parentCallingClassName for further transactions.
     * @param className
     * @return String
     */
    public static String setParentCallingClassName(String className) {
        return service().setParentCallingClassName(className);
    }

    /**
     * @description It creates instance of BypassLogicModelImpl class.
     * @return IBypassLogicModel - return instance of BypassLogicModelImpl class
     */
    private static IBypassLogicModel service() {
        return (IBypassLogicModel) Application.SERVICE.newInstance(IBypassLogicModel.class);
    }
}