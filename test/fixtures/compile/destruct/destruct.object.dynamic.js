const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let key = "qux";
	let {[key]: foo} = (() => {
		const d = new Dictionary();
		d.qux = "bar";
		return d;
	})();
	console.log(foo);
};