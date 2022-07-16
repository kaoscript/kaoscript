const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function $noop() {
		return $noop.__ks_rt(this, arguments);
	};
	$noop.__ks_0 = function() {
		return "";
	};
	$noop.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return $noop.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return $noop;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};