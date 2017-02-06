var $ksType = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if($ksType.isObject(x)) {
			return $ksType.isEmptyObject(x);
		}
		else {
			return false;
		}
	}
}