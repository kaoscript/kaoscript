var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Master {
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
	class SubClassA extends Master {
		__ks_init() {
			Master.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Master.prototype.__ks_cons.call(this, args);
		}
	}
	class SubClassB extends Master {
		__ks_init() {
			Master.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Master.prototype.__ks_cons.call(this, args);
		}
	}
	class Disturb {
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
	function foobar() {
		if(arguments.length === 1 && Type.isInstance(arguments[0], SubClassA)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isInstance(x, SubClassA)) {
				throw new TypeError("'x' is not of type 'SubClassA'");
			}
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isInstance(x, Master)) {
				throw new TypeError("'x' is not of type 'Master'");
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	function quxbaz() {
		if(arguments.length === 1 && Type.isInstance(arguments[0], SubClassA)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isInstance(x, SubClassA)) {
				throw new TypeError("'x' is not of type 'SubClassA'");
			}
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!(Type.isInstance(x, Master) || Type.isInstance(x, Disturb))) {
				throw new TypeError("'x' is not of type 'Master' or 'Disturb'");
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};