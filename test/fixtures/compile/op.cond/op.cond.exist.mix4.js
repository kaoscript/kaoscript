const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	if(Type.isValue(foo) ? Helper.concatString(foo.bar(), "world") === "hello world" : false) {
		console.log(foo);
	}
};