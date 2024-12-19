({
    // Update the tab title and logo
    handleReportActivation: function (component, event, helper) {
        const reportName = event.getParam("reportName");
        helper.updateConsoleTabTitle(component, reportName);
    },
    // Navigate to an SObject
    handleNavigateToRecord: function (component, event, helper) {
        if (event === null || !event.getParam("recordId"))
            return;

        const recordId = event.getParam("recordId");
        var redirectLink = $A.get("$Label.c.Figment_Org_Link");
        window.open(redirectLink + recordId);
    }
})