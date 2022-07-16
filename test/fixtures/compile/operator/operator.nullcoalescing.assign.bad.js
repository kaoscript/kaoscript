const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = foo();
	Type.isValue(tt) ? tt : tt = bar();
};