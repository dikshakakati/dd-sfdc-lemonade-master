/**
 * @description : A custom action plugin lets you run code before or after custom actions in Salesforce CPQ.
 * Currently, custom action plugins support only cloning actions.
 * A custom action plugin can call either the onBeforeCloneLine method or the onAfterCloneLine method so that
 * you can evaluate and modify a quote line before or immediately after the cloning process.
 *
 * For documentation visit:
 * Custom Action Plugin - https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_custom_action_plugin.htm
 */

/**
 * @description : The calculator calls this method before it completes a calculation to determine,
 * if the fields need to be updated on the line editor screen.
 * @param {clonedLines[]} Available with onAfterCloneLine. An array of new QuoteLineModels created from the clone action.
 * @param {quote} quoteModel JS representation of the quote.
 * @returns {Promise}
 */

export function onAfterCloneLine(quote, clonedLines) {
    console.log('cloned lines-');
    console.log(clonedLines);
    const adsPromoFamilySet = new Set(["Marketplace Promotion", "Advertisement"]);
    const originalLines = clonedLines.originalLines.standard;
    const clonedlLineArray = clonedLines.clonedLines.standard;
    const quoteLinesModel = clonedLines.originalLines;
    const quoteLineNewModel = clonedLines.clonedLines;
    const quoteLineModelsAll = Object.values(quoteLinesModel)[0];
    const quoteLineModelsNewAll = Object.values(quoteLineNewModel)[0];
    quoteLineModelsAll.forEach(line => {
        if (quote.record["SBQQ__Type__c"] === 'Amendment') {
            line.record["SBQQ__Quantity__c"] = 0;
        }
    });
    quoteLineModelsNewAll.forEach(line => {
        line.record["Pricing_Search_Complete__c"] = false;
    });
    //The below code blanks the brief item fields on the cloned lines for ads and promo products when
    //upgraded subscription on original line is null, do not blank out the fields when ugraded subscription
    //is present as that is cancel and replace scenario and we don not want to create new brief items for that.

    if (quote.record.Segment__c === 'Enterprise') {
        for (let i = 0; i < clonedlLineArray.length; i++) {
            if (adsPromoFamilySet.has(clonedlLineArray[i].record['SBQQ__ProductFamily__c']) &&
                originalLines[i].record['SBQQ__UpgradedSubscription__c'] == null &&
                (clonedlLineArray[i].record['Has_Brief_Item__c'] == true ||
                    clonedlLineArray[i].record['Brief_Item__c'] != null)) {

                clonedlLineArray[i].record['Has_Brief_Item__c'] = false;
                clonedlLineArray[i].record['Brief_Item__c'] = null;

            }
        }
    }
    return Promise.resolve();
}

/*-------------------------------------------------------------------------------------
Quote  Fields
-------------------------------------------------------------------------------------
SBQQ__Type__c
Segment__c
*/

/*-------------------------------------------------------------------------------------
Quote line group Fields
-------------------------------------------------------------------------------------
*/

/*-------------------------------------------------------------------------------------
Quote Line Fields
-------------------------------------------------------------------------------------
SBQQ__Quantity__c
Id
Original_Line_is_Cloned__c
Pricing_Search_Complete__c
SBQQ__Source__c
*/
