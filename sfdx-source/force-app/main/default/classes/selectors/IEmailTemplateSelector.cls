/**
 * @author atg
 * @date 05/11/2022
 * @description Interface to add Selector class methods
 */
public interface IEmailTemplateSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return List<IEmailTemplateSelector> List of EmailTemplates
     */
    List<EmailTemplate> selectById(Set<Id> idSet);

    /**
     * @description This method is used for getting all IEmailTemplateSelector
     * @param folderName
     * @return List<IEmailTemplateSelector> List of EmailTemplates
     */
    List<EmailTemplate> selectByFolderName(String folderName);

    /**
     * @description This method is used for getting Email Templates based on Names.
     * @param templateNames
     * @return List<EmailTemplate>
     */
    List<EmailTemplate> selectByTemplateNames(Set<String> templateNames);
}