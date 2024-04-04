const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassB extends ClassA {
		constructor() {
			const __ks_cons_0 = (foobar) => {
				super();
				this.__ks_init();
				this.foobar = foobar;
			};
			const __ks_cons_1 = (foobar, quxbaz) => {
				super();
				this.__ks_init();
				this.foobar = foobar;
				this.quxbaz = quxbaz;
			};
			const __ks_cons_rt = (args) => {
				const t0 = Type.isString;
				const t1 = Type.isNumber;
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_cons_0(args[0]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_cons_1(args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_cons_rt(arguments);
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
			const __ks_cons_1 = (foobar) => {
				super(foobar);
			};
			const __ks_cons_2 = (foobar, quxbaz) => {
				super(foobar, quxbaz);
			};
			const __ks_cons_rt = (args) => {
				const t0 = Type.isString;
				const t1 = Type.isNumber;
				if(args.length === 0) {
					return __ks_cons_0();
				}
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_cons_1(args[0]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_cons_2(args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_cons_rt(arguments);
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