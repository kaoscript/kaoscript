module.exports = function() {
	class URI {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class FileURI extends URI {
		__ks_init_1() {
			this._e = 3.14;
		}
		__ks_init() {
			URI.prototype.__ks_init.call(this);
			FileURI.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			URI.prototype.__ks_cons.call(this, args);
		}
	}
};