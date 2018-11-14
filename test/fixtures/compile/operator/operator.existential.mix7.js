var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if((Type.isValue(foo) && Type.isFunction(foo.bar) && Type.isValue(foo) && Type.isFunction(foo.qux)) ? foo.bar() > foo.qux() : false) {
		console.log(foo);
	}
};