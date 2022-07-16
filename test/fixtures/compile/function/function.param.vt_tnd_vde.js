const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isString;
				const t1 = value => Type.isString(value) || Type.isNull(value);
				if(args.length === 2) {
					if(t0(args[0])) {
						return __ks_rt.__ks_0.call(this, args[0], void 0, args[1]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x, y = null, z) => {
				if(z === void 0 || z === null) {
					z = false;
				}
				return [x, y, z];
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
	expect(foo("foo", true)).to.eql(["foo", null, true]);
	expect(foo("foo", 42)).to.eql(["foo", null, 42]);
	expect(foo("foo", "bar")).to.eql(["foo", null, "bar"]);
	expect(foo("foo", null)).to.eql(["foo", null, false]);
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true]);
	expect(foo("foo", "bar", "qux")).to.eql(["foo", "bar", "qux"]);
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", 42]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false]);
};