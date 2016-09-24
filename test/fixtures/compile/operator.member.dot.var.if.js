var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let b;
	if(Type.isValue((b = a.b, b.c)) ? b.c : false) {
		console.log(b);
	}
}