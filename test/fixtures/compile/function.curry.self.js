var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let log = Helper.curry(console.log, console, ["hello: "]);
	log("foo");
}