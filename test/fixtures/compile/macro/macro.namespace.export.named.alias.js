const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return "42";
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function() {
		return "42";
	};
	qux.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return qux.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		NS
	};
};