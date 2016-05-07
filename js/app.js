goog.provide('app');

goog.require('app.alias');
goog.require('app.bindui');
goog.require('app.setup');
goog.require('goog.Promise');

app.bindui.internalHandler = function(command) {
  return new goog.Promise(function(resolve, reject) {
    app.alias.sendToWorker(command).then(resolve);
  });
};
