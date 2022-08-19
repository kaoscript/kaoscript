const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Operator.or(foo, Operator.and(bar, Type.isValue(qux) ? qux.qux : null));
};