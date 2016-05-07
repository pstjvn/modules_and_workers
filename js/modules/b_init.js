/**
 * @fileoverview Provides the actual starting module for the app.
 * The main logic will be hodted here.
 *
 * @author PeterStJ (regardingscot@gmail.com)
 */
goog.provide('b_init');

goog.require('app');
goog.require('app.bindui');
goog.require('goog.Promise');
goog.require('goog.functions');
goog.require('goog.module.ModuleLoader');
goog.require('goog.module.ModuleManager');

b_init = function() {

  console.log('Second module, this one binds the actions');

  // Configure modules.
  var mm = goog.module.ModuleManager.getInstance();
  var ml = new goog.module.ModuleLoader();
  mm.setLoader(ml);
  mm.setAllModuleInfo(goog.global['MODULE_INFO']);
  mm.setModuleUris(goog.global['MODULE_URIS']);

  // Sets up the handler that will be executed when clicking on the
  // UI button.
  // Without modules this code should reside in 'main' to set things up in the
  // same fashion as this one, only whithout actually waiting on the module.
  app.bindui.internalHandler = function(url) {
    return new goog.Promise(function(resolve, reject) {
      mm.execOnLoad('c', function() {
        console.log('The third module has been loaded...');
        // Send to worker will available after the module loads.
        app.sendToWorker(url).then(resolve);
      });
    });
  };

  // Tell module manager that the scaffold module and the main app modules are
  // loaded
  mm.setLoaded('a');
  mm.setLoaded('b');
};

b_init();
