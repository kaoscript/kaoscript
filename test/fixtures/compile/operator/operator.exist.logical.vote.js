const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Operator.or(foo.foo, Type.isValue(bar) ? bar.bar : null);
};