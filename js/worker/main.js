/**
 * @fileoverview The main entry point for your worker application. Instanciates
 * your worker service and echoes back the messages from the main app. Edit this
 * file to suit your application's needs.
 *
 * Note that the namespace in this fill is expected to exist and be built if
 * using the worker app convenience method (see pstj.app.worker)
 */
goog.provide('worker');

goog.require('app.gen.dto.Test');
goog.require('ct.test');
goog.require('ct.shared.command');
goog.require('goog.events.EventType');
goog.require('pstj.worker.WorkerService');

var worker = new pstj.worker.WorkerService(
    /** @type {DedicatedWorkerGlobalScope} */ (self));

worker.listen(goog.events.EventType.MESSAGE, function(e) {
  if (e.data == ct.shared.command.Name.GET_CODE) {
    worker.send(ct.test.getBuffer().toString());
  }
  // Send back the data (echo service)
  // var a = new app.gen.dto.Test();
  // worker.send(e.data);
  // worker.send(JSON.stringify(a));
});


