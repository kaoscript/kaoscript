var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	const foo = [1, 2];
	const bar = [];
	bar.push(0, ...foo);
	function log(...args) {
		console.log(...args);
	}
	let machine = "tesla";
	let directory = "xfer";
	let user = "john";
	const info = [directory, " ", user, ": "];
	const logHello = Helper.vcurry(log, null, machine, ":", ...info);
	logHello("foo");
};