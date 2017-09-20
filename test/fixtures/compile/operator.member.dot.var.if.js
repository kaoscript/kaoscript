var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let b;
	if(Type.isValue((b = a.b).c)) {
		console.log(b);
	}
};