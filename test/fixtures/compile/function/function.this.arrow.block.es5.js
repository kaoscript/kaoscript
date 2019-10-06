var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar() {
		this.foobar = true;
		return (function() {
			this.arrow = true;
			return this;
		}).bind(this);
	}
	console.log(foobar.call(new Dictionary())());
};