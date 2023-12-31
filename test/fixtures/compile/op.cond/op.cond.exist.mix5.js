const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	if((Type.isValue(foo) && Type.isValue(foo)) ? Helper.concatString(foo.bar(), "world") === Helper.concatString("hello", foo.qux()) : false) {
		console.log(foo);
	}
};