const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let ns = Helper.namespace(function() {
		function foo() {
			return foo.__ks_rt(this, arguments);
		};
		foo.__ks_0 = function() {
			return 42;
		};
		foo.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return foo.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		return {
			foo
		};
	});
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		return true;
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};