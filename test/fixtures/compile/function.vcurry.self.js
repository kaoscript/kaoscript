var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let log = Helper.vcurry(console.log, console, "hello: ");
	log("foo");
}