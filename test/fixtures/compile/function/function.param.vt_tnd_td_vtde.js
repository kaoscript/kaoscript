const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isString;
				const t1 = value => Type.isNumber(value) || Type.isNull(value);
				const t2 = value => Type.isBoolean(value) || Type.isNull(value);
				const t3 = value => Type.isString(value) || Type.isNull(value);
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_rt.__ks_0.call(this, args[0], void 0, void 0, args[1]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t0(args[0])) {
						if(t2(args[1])) {
							if(t1(args[2])) {
								return __ks_rt.__ks_0.call(this, args[0], void 0, args[1], args[2]);
							}
							throw Helper.badArgs();
						}
						if(t3(args[1]) && t1(args[2])) {
							return __ks_rt.__ks_0.call(this, args[0], args[1], void 0, args[2]);
						}
						throw Helper.badArgs();
					}
					throw Helper.badArgs();
				}
				if(args.length === 4) {
					if(t0(args[0]) && t3(args[1]) && t2(args[2]) && t1(args[3])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1], args[2], args[3]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x, y = null, z, a) => {
				if(z === void 0 || z === null) {
					z = false;
				}
				if(a === void 0 || a === null) {
					a = 0;
				}
				return [x, y, z, a];
			};
			return __ks_rt;
		})();
	})();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo();
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo");
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo(true);
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo(42);
		};
		return __ks_rt;
	})()).to.throw();
	expect(foo("foo", 42)).to.eql(["foo", null, false, 42]);
	expect(foo("foo", null)).to.eql(["foo", null, false, 0]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar");
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", true);
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", []);
		};
		return __ks_rt;
	})()).to.throw();
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", false, 42]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false, 0]);
	expect(foo("foo", null, null)).to.eql(["foo", null, false, 0]);
	expect(foo("foo", null, 42)).to.eql(["foo", null, false, 42]);
	expect(foo("foo", true, 42)).to.eql(["foo", null, true, 42]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar", true);
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar", "qux");
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar", []);
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", 42, "qux");
		};
		return __ks_rt;
	})()).to.throw();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", true, "qux");
		};
		return __ks_rt;
	})()).to.throw();
	expect(foo("foo", "bar", true, 42)).to.eql(["foo", "bar", true, 42]);
	expect(foo("foo", "bar", true, null)).to.eql(["foo", "bar", true, 0]);
	expect(foo("foo", null, null, null)).to.eql(["foo", null, false, 0]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar", true, "qux");
		};
		return __ks_rt;
	})()).to.throw();
};