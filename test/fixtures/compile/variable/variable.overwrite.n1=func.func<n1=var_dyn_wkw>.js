const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function name() {
		return name.__ks_rt(this, arguments);
	};
	name.__ks_0 = function() {
	};
	name.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return name.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		let name = "foobar";
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};