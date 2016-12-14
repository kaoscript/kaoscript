var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let foo = [1, 2];
	let bar = [];
	bar.push.apply(bar, [].concat(0, foo));
	function log(...args) {
		console.log.apply(console, args);
	}
	let machine = "tesla";
	let directory = "xfer";
	let user = "john";
	let info = [machine, ":", directory, " ", user, ": "];
	let logHello = Helper.curry(log, null, info);
	logHello("foo");
}