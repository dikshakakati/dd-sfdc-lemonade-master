({
    updateConsoleTabTitle: function(component, title) {
        var workspaceAPI = component.find("workspace");
        if (!workspaceAPI)
            return;

        // If console - then set the tab label and icon
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
            if (isConsole) {
                workspaceAPI.getFocusedTabInfo().then(function(tabInfo) {
                    workspaceAPI.setTabLabel({
                        tabId: tabInfo.tabId,
                        label: title
                    });
                    workspaceAPI.setTabIcon({
                        tabId: tabInfo.tabId,
                        icon: "standard:service_report",
                        iconAlt: "Report"
                    });
                })
                .catch(function(error) {
                    console.log('****workspaceAPI getFocusedTabInfo Error',error);
                });
            }
        });
    }
})