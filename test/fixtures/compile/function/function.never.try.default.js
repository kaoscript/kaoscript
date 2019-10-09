var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foobar() {
		Helper.try(() => quxbaz(), null);
	}
	function quxbaz() {
		throw new Error();
	}
};