sap.ui.define(["sap/ui/core/UIComponent","skillfinder/model/models"], function(UIComponent, models) {
  "use strict";
  return UIComponent.extend("skillfinder.Component", {
    metadata: { manifest: "json" },
    init: function() {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createSessionModel(), "session");
      this.getRouter().initialize();
    }
  });
});