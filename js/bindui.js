goog.provide('app.bindui');

goog.require('app.ui');
goog.require('ct.shared.command');
goog.require('goog.events');
goog.require('goog.events.EventType');

/**
 * Handles the click on the UI.
 * @param {goog.events.Event} e
 */
app.bindui.handleClick = function(e) {
  /** @type {HTMLInputElement} */
  var input = (/** @type {HTMLInputElement} */(document.querySelector('#url')));
  var url = input.value;
  url = ct.shared.command.Name.GET_CODE;

  // Check if we are a valid URL...
  // Skip it for now...

  // The third module is responsible for setting up the worker instance
  // on the app and wiring up the handler.
  // For now we send predefined command...
  if (app.bindui.internalHandler != null) {
    app.bindui.internalHandler(url).then(function(resp) {
      goog.dom.setTextContent(document.querySelector('#output'), resp);
    });
  }
};

/**
 * Exposed handler, allows external setting.
 * @type {?function(string): !goog.Promise<!string>}
 */
app.bindui.internalHandler = null;


goog.events.listen(document.querySelector('button'), goog.events.EventType.CLICK, app.bindui.handleClick);