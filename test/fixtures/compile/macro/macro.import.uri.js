require("kaoscript/register");
module.exports = function() {
	var URI = require("./.macro.export.uri.ks.j5k8r9.ksb")().URI;
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