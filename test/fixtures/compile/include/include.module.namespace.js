const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let ns = Helper.namespace(function() {
		function foo() {
			return foo.__ks_rt(this, arguments);
		};
		foo.__ks_0 = function() {
		};
		foo.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return foo.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		const bar = 42;
		class Corge {
			static __ks_new_0() {
				const o = Object.create(Corge.prototype);
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
		class Qux extends Corge {
			static __ks_new_0() {
				const o = Object.create(Qux.prototype);
				o.__ks_init();
				return o;
			}
			__ks_cons_rt(that, args) {
				super.__ks_cons_rt.call(null, that, args);
			}
		}
		return {
			foo,
			bar,
			Qux
		};
	});
	const foo = ns.bar;
	console.log(ns.foo.__ks_0());
};