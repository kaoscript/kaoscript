const {Helper, Type} = require("@kaoscript/runtime");
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
		return {
			Foobar
		};
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, NS.Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};