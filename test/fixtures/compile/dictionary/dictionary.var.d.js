const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let d = 42;
	let foobar = (() => {
		const o = new Dictionary();
		o.x = d;
		return o;
	})();
};