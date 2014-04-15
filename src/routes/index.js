// Generated by CoffeeScript 1.7.1
define(function(require, exports, module) {
  var IndexView;
  IndexView = require("views/index");
  return new aJazz.Route({
    enter: function(app, query, forward) {
      var view;
      view = app.getView("index");
      if (view == null) {
        view = new IndexView();
        app.setView("index", view);
      }
      return app.bindView("page", view, {
        forward: forward
      });
    },
    level: 1
  });
});