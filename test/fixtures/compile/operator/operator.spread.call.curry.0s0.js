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
	let info = [machine, ":", directory, " ", user, ": "];
	let logHello = Helper.vcurry(log, null, ...info);
	logHello("foo");
};