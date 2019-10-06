var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.foo = function() {
			let i = 0;
		};
		return d;
	})();
	function bar() {
		for(let i = 0; i < 10; ++i) {
			console.log(i);
		}
	}
};