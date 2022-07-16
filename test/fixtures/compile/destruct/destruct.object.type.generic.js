const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const d = new Dictionary();
		d.bar = 1;
		d.baz = 3;
		return d;
	})();
	const {bar, baz} = foo;
	console.log(bar + baz, baz + 1);
};