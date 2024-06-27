const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		let MD = Helper.namespace(function() {
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
		return {
			MD
		};
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
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
		return "42";
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		NS
	};
};