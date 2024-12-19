/**
 * @author Deloitte
 * @date 03/03/2022
 * @description This class created to handle exception in case of any exception scenarios in lightning component.
 */
public with sharing class LogController {
    /**
     * @description This method is used to log exception
     * @param lwcName - LWC Name
     * @param methodName - Method Name
     * @param message - Message to be logged
     */
    @AuraEnabled
    public static void createLog(String lwcName, String methodName, String message) {
        Logger.publish(LogEntry.newLog(lwcName, methodName, message));
    }
}