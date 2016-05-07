goog.provide('ct.test');

goog.require('pstj.ds.dto.format');
goog.require('pstj.ds.dto.type');
goog.require('pstj.sourcegen.CodeBuffer');

/**  @return {!pstj.sourcegen.CodeBuffer} */
ct.test.getBuffer = function() {
  var buf = new pstj.sourcegen.CodeBuffer();
  buf.writeln('start');
  buf.lines(1);
  buf.indent.add();
  buf.write(ct.test.getInnerBuffer(buf))
  buf.lines(1);
  buf.indent.remove();
  buf.writeln('end');
  return buf;
};

/**
 * @param {!pstj.sourcegen.CodeBuffer} buffer
 * @return {!pstj.sourcegen.CodeBuffer}
 */
ct.test.getInnerBuffer = function(buffer) {
  var buf = buffer.clone();
  buf.writeln('inner');
  buf.lines(1);
  buf.writeln(ct.test.isAllowed(pstj.ds.dto.type.Type.STRING, 'datetime'));
  buf.lines(1);
  buf.writeln('inner end');
  return buf;
};

/**
 * @param {string} type
 * @param {string} format
 * @return {boolean}
 */
ct.test.isAllowed = function(type, format) {
  if (goog.isDefAndNotNull(type)) {
    switch (type) {
      case pstj.ds.dto.type.Type.INT:
        return goog.array.contains(pstj.ds.dto.format.allowedInInt, format);
      case pstj.ds.dto.type.Type.NUMBER:
        return goog.array.contains(pstj.ds.dto.format.allowedInNumber, format);
      case pstj.ds.dto.type.Type.STRING:
        return goog.array.contains(pstj.ds.dto.format.allowedInString, format);
      default: throw new Error(`Unknown type: ${type}`);
    }
  }
  return true;
};