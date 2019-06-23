var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	const original = {
		a: 1,
		b: 2
	};
	const copy = Helper.concatObject(original, {c: 3});
};