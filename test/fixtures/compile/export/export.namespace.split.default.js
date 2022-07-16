const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
			return foo.__ks_rt(this, arguments);
		};
		foo.__ks_0 = function() {
			return "foo";
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
			return "bar";
		};
		bar.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return bar.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		function qux() {
			return qux.__ks_rt(this, arguments);
		};
		qux.__ks_0 = function() {
			return "aux";
		};
		qux.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return qux.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		return {
			foo,
			bar,
			qux
		};
	});
	return {
		NS,
		foobar: NS.foo
	};
};