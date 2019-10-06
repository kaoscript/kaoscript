var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let key = "qux";
	let {[key]: foo} = (() => {
		const d = new Dictionary();
		d.qux = "bar";
		return d;
	})();
	console.log(foo);
};