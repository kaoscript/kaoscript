require("kaoscript/register");
module.exports = function() {
	var URI = require("./macro.export.uri.ks")().URI;
	class FileURI extends URI {
		__ks_init_0() {
			this._e = 3.14;
		}
		__ks_init() {
			URI.prototype.__ks_init.call(this);
			FileURI.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			URI.prototype.__ks_cons.call(this, args);
		}
	}
};