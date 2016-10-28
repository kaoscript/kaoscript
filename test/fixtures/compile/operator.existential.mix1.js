var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if(Type.isValue(foo) ? foo.length > 10 : false) {
		console.log(foo);
	}
}