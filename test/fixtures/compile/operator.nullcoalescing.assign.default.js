var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = foo();
	if(!Type.isValue(tt)) {
		tt = bar;
	}
};