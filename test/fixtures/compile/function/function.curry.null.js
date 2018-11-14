var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function log(...args) {
		console.log(...args);
	}
	let logHello = Helper.vcurry(log, null, ...["hello: "]);
	logHello("foo");
};