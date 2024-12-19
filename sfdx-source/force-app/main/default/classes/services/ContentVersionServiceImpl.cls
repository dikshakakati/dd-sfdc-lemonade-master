/**
 * @author DoorDash QTC
 * @date   07/25/2022
 * @description LEM-2190
 */
public inherited sharing class ContentVersionServiceImpl implements IContentVersionService {

     /** @method createContentVersion() [private]
    * @description Creates a content version from a given file's base64 and name
    * @param base64Data - base64 string that represents the file
    * @param filename - full file name with extension, i.e. 'products.csv'
    * @param recordId - Id of the record you want to attach this file to
   */
   public static void createContentVersion(String base64Data, String filename , Id recordId) {
       fflib_ISObjectUnitOfWork uowForContentVersionCreation = Application.UNITOFWORK.newInstance();
       ContentVersion cv = new ContentVersion();
       cv.Title = fileName;
       cv.PathOnClient = '/' + fileName;
       cv.FirstPublishLocationId = recordId;
       cv.VersionData = Blob.valueOf(base64Data) ;
       cv.IsMajorVersion = true;
       uowForContentVersionCreation.registerNew(cv);

       try {
           uowForContentVersionCreation.commitWork();
       } catch (Exception contentVersionCreateException) {
           Logger.publish(contentVersionCreateException, LogEntry.SeverityLevel.HIGH);
       }
   }
}