var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_ClassA = {};
	class ClassB extends ClassA {
		constructor() {
			const __ks_cons_0 = (__ks_arguments) => {
				let __ks_i = -1;
				let foobar = __ks_arguments[++__ks_i];
				if(foobar === void 0 || foobar === null) {
					throw new TypeError("'foobar' is not nullable");
				}
				else if(!Type.isString(foobar)) {
					throw new TypeError("'foobar' is not of type 'String'");
				}
				super();
				this.__ks_init();
				this.foobar = foobar;
			};
			const __ks_cons_1 = (__ks_arguments) => {
				let __ks_i = -1;
				let foobar = __ks_arguments[++__ks_i];
				if(foobar === void 0 || foobar === null) {
					throw new TypeError("'foobar' is not nullable");
				}
				else if(!Type.isString(foobar)) {
					throw new TypeError("'foobar' is not of type 'String'");
				}
				let quxbaz = __ks_arguments[++__ks_i];
				if(quxbaz === void 0 || quxbaz === null) {
					throw new TypeError("'quxbaz' is not nullable");
				}
				else if(!Type.isNumber(quxbaz)) {
					throw new TypeError("'quxbaz' is not of type 'Number'");
				}
				super();
				this.__ks_init();
				this.foobar = foobar;
				this.quxbaz = quxbaz;
			};
			const __ks_cons = (__ks_arguments) => {
				if(__ks_arguments.length === 1) {
					__ks_cons_0(__ks_arguments);
				}
				else if(__ks_arguments.length === 2) {
					__ks_cons_1(__ks_arguments);
				}
				else {
					throw new SyntaxError("Wrong number of arguments");
				}
			};
			__ks_cons(arguments);
		}
		__ks_init_0() {
			this.foobar = "foobar";
			this.quxbaz = 42;
		}
		__ks_init() {
			ClassB.prototype.__ks_init_0.call(this);
		}
	}
	class ClassC extends ClassB {
		constructor() {
			const __ks_cons_0 = () => {
				super("foobar");
			};
			const __ks_cons_1 = (__ks_arguments) => {
				let __ks_i = -1;
				let foobar = __ks_arguments[++__ks_i];
				if(foobar === void 0 || foobar === null) {
					throw new TypeError("'foobar' is not nullable");
				}
				else if(!Type.isString(foobar)) {
					throw new TypeError("'foobar' is not of type 'String'");
				}
				super(foobar);
			};
			const __ks_cons_2 = (__ks_arguments) => {
				let __ks_i = -1;
				let foobar = __ks_arguments[++__ks_i];
				if(foobar === void 0 || foobar === null) {
					throw new TypeError("'foobar' is not nullable");
				}
				else if(!Type.isString(foobar)) {
					throw new TypeError("'foobar' is not of type 'String'");
				}
				let quxbaz = __ks_arguments[++__ks_i];
				if(quxbaz === void 0 || quxbaz === null) {
					throw new TypeError("'quxbaz' is not nullable");
				}
				else if(!Type.isNumber(quxbaz)) {
					throw new TypeError("'quxbaz' is not of type 'Number'");
				}
				super(foobar, quxbaz);
			};
			const __ks_cons = (__ks_arguments) => {
				if(__ks_arguments.length === 0) {
					__ks_cons_0(__ks_arguments);
				}
				else if(__ks_arguments.length === 1) {
					__ks_cons_1(__ks_arguments);
				}
				else if(__ks_arguments.length === 2) {
					__ks_cons_2(__ks_arguments);
				}
				else {
					throw new SyntaxError("Wrong number of arguments");
				}
			};
			__ks_cons(arguments);
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
		}
	}
	class ClassD extends ClassC {
		constructor() {
			super(...arguments);
		}
		__ks_init() {
			ClassC.prototype.__ks_init.call(this);
		}
	}
};