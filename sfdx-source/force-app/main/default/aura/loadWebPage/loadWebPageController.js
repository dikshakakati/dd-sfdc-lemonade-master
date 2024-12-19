/*
 * LEM-449,LEM-2505 product selection page to display in same tab
 */
({
  invoke: function (component) {
    var destUrl = component.get("v.url");

    //LEM-2505: trim trailing spaces
    destUrl = destUrl.trim();

    var pattern = new RegExp('^(http|https)://[^ "]+$');
    if (!pattern.test(destUrl)) {
      destUrl = "http://" + destUrl;
    }

    //LEM-2505: product selection page to display in same tab.
    window.location.assign(destUrl);
  }
});
