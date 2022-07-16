const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let d = "foo";
	let u = 42;
	console.log((Helper.concatString(d, u)).toUpperCase());
};