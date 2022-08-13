const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	const x = (() => {
		const d = new Dictionary();
		d.y = null;
		return d;
	})();
	x.y = 42;
};