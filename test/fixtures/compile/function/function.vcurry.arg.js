const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let log = Helper.vcurry(console.log, console, "hello: ");
	log("foo");
};