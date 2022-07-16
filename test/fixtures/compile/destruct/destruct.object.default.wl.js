const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let {bar, baz} = foo;
	console.log(bar);
	console.log(baz);
};