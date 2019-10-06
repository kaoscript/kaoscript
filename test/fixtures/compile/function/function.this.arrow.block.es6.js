var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar() {
		this.foobar = true;
		return () => {
			this.arrow = true;
			return this;
		};
	}
	console.log(foobar.call(new Dictionary())());
};