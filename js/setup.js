/**
 * @fileoverview The namespace is provided only to test the seed project.
 *
 * @author PeterStJ (regardingscot@gmail.com)
 */
goog.provide('app.setup');

goog.require('app.alias');
goog.require('goog.Promise');
goog.require('goog.events');
goog.require('goog.events.EventType');
goog.require('pstj.app.worker');


// Wire up sending data to the worker.
app.alias.sendToWorker = function(data) {
  return new goog.Promise(function(resolve, reject) {
    goog.events.listenOnce(pstj.app.worker.getInstance(), goog.events.EventType.MESSAGE, function(e) {
      console.log('Raw worker response, trasnfering to handler...');
      resolve(e.data);
    });
    pstj.app.worker.getInstance().send(data);
  });
};
