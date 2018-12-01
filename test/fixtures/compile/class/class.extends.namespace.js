module.exports = function() {
	let T = (function() {
		class FooX {
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
		const fox = new FooX();
		return {
			FooX: FooX
		};
	})();
	const fox = new T.FooX();
	class FooY extends T.FooX {
		__ks_init() {
			T.FooX.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			T.FooX.prototype.__ks_cons.call(this, args);
		}
	}
	const foy = new FooY();
};