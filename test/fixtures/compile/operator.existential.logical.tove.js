var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = (Type.isValue(foo) ? foo.foo : false) || bar.bar;
}