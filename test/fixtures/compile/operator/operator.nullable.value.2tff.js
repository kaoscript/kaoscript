const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Type.isFunction(foo) ? foo().bar() : null;
};