const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Type.isFunction(foo) ? foo(1, 2, 3) : null;
	let uu = Type.isFunction(foo) ? foo(1) : null;
};