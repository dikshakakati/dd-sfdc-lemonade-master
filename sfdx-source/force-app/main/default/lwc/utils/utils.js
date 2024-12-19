/**
 * @author Deloitte
 * @date 09/28/2022
 * @description A service component (library) for maintaining JavaScript utility methods.
 */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import toastModeDismissible from '@salesforce/label/c.Toast_Mode_Dismissible';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';
import * as ExportDataUtil from './exportData';

const DEFAULT_TOAST_MESSAGE = 'Utility Message';
const FILE_FORMAT_CSV = 'csv';
const INVALID_FILE_FORMAT_ERROR_MESSAGE = 'Invalid file format';

let message = DEFAULT_TOAST_MESSAGE;
let messageData = [];
let mode = toastModeDismissible;
let title = '';
let variant = toastVariantInfo;

/**
 * @description To reload screen.
 */
const reloadScreen = () => {
  /* Adding location reload method to prevent the screen stuck issue.
   * workspaceAPI.refreshTab and force:refreshView does not properly refresh the screen.
   * This maybe reverted once lwc has equivalent method to refresh screen.
   */
  window.location.reload();
};

/**
 * @description To reload screen after the passed delayed miliseconds.
 * @param delayInMiliseconds
 */
const reloadScreenAfterConfiguredDelay = (delayInMiliseconds) => {
  /* eslint-disable @lwc/lwc/no-async-operation */
  setTimeout(function () {
    reloadScreen();
  }, delayInMiliseconds);
};

/**
 * @description To set message of the toast notification.
 * @param messageToSet
 */
const setMessage = (messageToSet) => {
  message = messageToSet;
};

/**
 * @description To set messageData of the toast notification.
 * @param messageDataToSet
 */
const setMessageData = (messageDataToSet) => {
  messageData = messageDataToSet;
};

/**
 * @description To set mode of the toast notification.
 * @param modeToSet
 */
const setMode = (modeToSet) => {
  mode = modeToSet;
};

/**
 * @description To set title of the toast notification.
 * @param titleToSet
 */
const setTitle = (titleToSet) => {
  title = titleToSet;
};

/**
 * @description To set variant of the toast notification.
 * @param variantToSet
 */
const setVariant = (variantToSet) => {
  variant = variantToSet;
};

/**
 * @description To show the toast notification.
 * @param callerReference - reference of calling LWC
 */
const showNotification = (callerReference) => {
  const toastEvent = new ShowToastEvent({
    message: message,
    messageData: messageData,
    mode: mode,
    title: title,
    variant: variant
  });
  callerReference.dispatchEvent(toastEvent);
};


/**
 * @description To export data based on the format passed.
 * @param headersToExport
 * @param dataToExport
 * @param fileTitle
 * @param formatToApply
 */
const exportDataByFormat = (headersToExport, dataToExport, fileTitle, formatToApply) => {
  switch (formatToApply) {
    case FILE_FORMAT_CSV:
      ExportDataUtil.exportDataToCSV(headersToExport, dataToExport, fileTitle);
      break;
    default:
      console.error(INVALID_FILE_FORMAT_ERROR_MESSAGE);
  }
};

export { reloadScreen, reloadScreenAfterConfiguredDelay, setMessage, setMessageData, setMode, setTitle, setVariant, showNotification, exportDataByFormat };