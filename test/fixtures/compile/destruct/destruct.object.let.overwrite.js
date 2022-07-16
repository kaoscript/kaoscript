const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let {bar, baz} = foo;
	bar = "foo";
	console.log(bar, baz);
};