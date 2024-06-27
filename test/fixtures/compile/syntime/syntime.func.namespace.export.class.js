const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		class Foobar {
			static __ks_new_0() {
				const o = Object.create(Foobar.prototype);
				o.__ks_init();
				return o;
			}
			constructor() {
				this.__ks_init();
				this.__ks_cons_rt.call(null, this, arguments);
			}
			__ks_init() {
			}
			__ks_cons_rt(that, args) {
				if(args.length !== 0) {
					throw Helper.badArgs();
				}
			}
		}
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
			Foobar
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
	return {
		NS
	};
};