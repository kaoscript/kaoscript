const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Type.isValue(foo.bar) ? foo.bar.qux : null;
};