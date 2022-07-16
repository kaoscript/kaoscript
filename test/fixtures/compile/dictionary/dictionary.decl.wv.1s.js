const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		return d;
	})();
};