const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class URI {
		static __ks_new_0() {
			const o = Object.create(URI.prototype);
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
	class FileURI extends URI {
		static __ks_new_0() {
			const o = Object.create(FileURI.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._e = 3.14;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
};