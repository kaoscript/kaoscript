const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = (foo.foo === true) || (Type.isValue(bar) ? bar.bar === true : false);
};