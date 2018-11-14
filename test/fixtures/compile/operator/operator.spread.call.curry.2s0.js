var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let foo = [1, 2];
	let bar = [];
	bar.push(0, ...foo);
	function log(...args) {
		console.log(...args);
	}
	let machine = "tesla";
	let directory = "xfer";
	let user = "john";
	let info = [directory, " ", user, ": "];
	let logHello = Helper.vcurry(log, null, machine, ":", ...info);
	logHello("foo");
};