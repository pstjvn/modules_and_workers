/**
 * @fileoverview Generic entry point for your application. Require your actual
 * application namespace from here and instancite it accordingly.
 *
 * Note that no assumptions are made about your application. However if you
 * want to go with module system and loading indication - those are not
 * handled automatically and you need to use corresponding utilities.
 *
 * @author regardingscot@gmail.com (Peter StJ)
 */

goog.provide('app.alias');

// We only expose the send to worker and we expect a promise of the result.

/** @type {?function(string): !goog.Promise<!string>} */
app.alias.sendToWorker = null;
