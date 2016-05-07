goog.provide('app.ui');

goog.require('app.template');
goog.require('goog.dom');

document.body.appendChild(
    goog.dom.safeHtmlToNode(app.template.Test(null).toSafeHtml()));