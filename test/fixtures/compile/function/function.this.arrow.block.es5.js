var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar() {
		var __ks_000 = function() {
			this.arrow = true;
			return this;
		}
		this.foobar = true;
		return __ks_000.bind(this);
	}
	console.log(foobar.call(new Dictionary())());
};