module.exports = function() {
	let ns = (function() {
		function foo() {
		}
		const bar = 42;
		class Corge {
			constructor() {
				this.__ks_init();
				this.__ks_cons(arguments);
			}
			__ks_init() {
			}
			__ks_cons(args) {
				if(args.length !== 0) {
					throw new SyntaxError("wrong number of arguments");
				}
			}
		}
		class Qux extends Corge {
			__ks_init() {
				Corge.prototype.__ks_init.call(this);
			}
			__ks_cons(args) {
				Corge.prototype.__ks_cons.call(this, args);
			}
		}
		return {
			foo: foo,
			bar: bar,
			Qux: Qux
		};
	})();
	const foo = ns.bar;
	console.log(ns.foo());
};