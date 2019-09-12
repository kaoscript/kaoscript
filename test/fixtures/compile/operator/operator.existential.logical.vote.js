var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = (foo.foo === true) || (Type.isValue(bar) ? bar.bar === true : false);
};