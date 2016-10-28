var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if(Type.isValue(foo) && Type.isValue(foo) ? foo.bar > foo.qux : false) {
		console.log(foo);
	}
}