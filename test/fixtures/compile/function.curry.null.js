var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function log(...args) {
		console.log.apply(console, args);
	}
	let logHello = Helper.curry(log, null, ["hello: "]);
	logHello("foo");
}