var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = (() => {
			const d = new Dictionary();
			d.qux = function() {
				let i = 1;
			};
			return d;
		})();
		return d;
	})();
};