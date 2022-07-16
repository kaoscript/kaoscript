const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let T = Helper.namespace(function() {
		class FooX {
			static __ks_new_0() {
				const o = Object.create(FooX.prototype);
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
		const fox = FooX.__ks_new_0();
		return {
			FooX
		};
	});
	const fox = T.FooX.__ks_new_0();
	class FooY extends T.FooX {
		static __ks_new_0() {
			const o = Object.create(FooY.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	const foy = FooY.__ks_new_0();
};