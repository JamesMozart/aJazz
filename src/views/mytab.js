// Generated by CoffeeScript 1.7.1
define(function(require, exports, module) {
  var MsgView, TabView;
  TabView = require("views/TabView");
  MsgView = require("views/msg");
  return TabView.extend({
    template: template(require("templates/mytab.html")),
    events: {
      "click|.role-remove-all": function(e) {
        this.removeTab();
      },
      "click|.role-move": function(e) {
        this.moveTab(this.tabs.length - 1, 0);
      },
      "click|.role-add": function(e) {
        var i;
        this._i++;
        i = this._i;
        this.addTab("tab" + this._i, function() {
          return new MsgView({
            msg: "tab" + i
          });
        });
      }
    },
    init: function(options) {
      TabView.prototype.init.call(this, options);
      this._i = 0;
    }
  });
});
