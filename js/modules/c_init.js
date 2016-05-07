goog.provide('c_init');

goog.require('app.setup');
goog.require('goog.module.ModuleManager');


c_init = function() {
  console.log('Code executed in third module');
  goog.module.ModuleManager.getInstance().setLoaded('c');
};

c_init();
