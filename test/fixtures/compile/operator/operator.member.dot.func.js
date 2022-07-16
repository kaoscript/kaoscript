const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let qux = Type.isValue(foo) ? foo.bar() : null;
};