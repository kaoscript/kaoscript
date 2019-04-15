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
	let info = (function() {
		return [machine, ":", directory, " "];
	})();
	let logHello = Helper.curry(log, null, [].concat(info, [user, ": "]));
	logHello("foo");
};