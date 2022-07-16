const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const original = (() => {
		const d = new Dictionary();
		d.a = 1;
		d.b = 2;
		return d;
	})();
	const copy = Helper.concatDictionary(original, {c: 3});
};