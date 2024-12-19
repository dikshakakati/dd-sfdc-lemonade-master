/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Useful Javascript functions to import into your LWC component
 */

/**
 * Reduces one or more LDS errors into a string[] of error messages. Copied from Salesforce LWC recipes, upated to do better API DML error parsing.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // Page level errors
                else if (
                    error?.body?.pageErrors &&
                    error.body.pageErrors.length > 0
                ) {
                    return error.body.pageErrors.map((e) => e.message);
                }
                // Field level errors
                else if (
                    error?.body?.fieldErrors &&
                    Object.keys(error.body.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML page level errors
                else if (
                    error?.body?.output?.errors &&
                    error.body.output.errors.length > 0
                ) {
                    return error.body.output.errors.map((e) => e.message);
                }
                // UI API DML field level errors
                else if (
                    error?.body?.output?.fieldErrors &&
                    Object.keys(error.body.output.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.output.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Useful Javascript functions to import into your LWC component
 */

/**
* Method to give if passed value is undefined or null (truthy/falsey JS treats '',0 etc in same category, not using that)
* @param {Object} val
* @return {Boolean}
*/
export function isUndefinedOrNull(val) {
    return val === undefined || val === null;
}

/**
* Method to give if passed string is actually a string and is not blank (truthy/falsey JS treats '',0, etc in same category, not using that)
* @param {String} val
* @return {Boolean}
*/
export function stringIsNotBlank(val) {
    return !stringIsBlank(val) && typeof val === 'string';
}

/**
* Method to give if passed string is actually a string and blank
* @param {String} val
* @return {Boolean}
*/
export function stringIsBlank(val) {
    return (!val || val.length === 0);
}

/**
* In certain components, if you want to deep clone an object to enforce 'reactivity' in LWC, use this method.
* Reactivity is enforced as deep clone is a new memory instance.
* @param {Object} obj
* @return {Object} <Deep Cloned obj>
*/
export function cloneObject(obj) {
    if (!obj) {
        return null;
    }
    return JSON.parse(JSON.stringify(obj));
}

/**
* Used in example apps to generate random legit sounding words
* @param {Object[]} array
*                {Integer} size
* @return {Object[]} Array of chunked arrays, each child array max size is 'size'
*/
export function chunkArray(array, size) {
    const chunked_arr = [];
    let index = 0;
    while (index < array.length) {
        chunked_arr.push(array.slice(index, size + index));
        index += size;
    }
    return chunked_arr;
}

/**
* Format Date as a readable string
* @param {Date} value
* @return {String} <Formatted Date>
*/
export function formatDate(value) {
    const dt = (typeof(value) === 'string') ? new Date(value) : value;
    const utcDt = new Date(dt.getTime() + dt.getTimezoneOffset() * 60000);

    return utcDt.toLocaleString('en-us', { month: 'short' }) + ' ' +
           utcDt.toLocaleString('en-us', { day: 'numeric' }) + ', ' +
           utcDt.toLocaleString('en-us', { year: 'numeric' });
}