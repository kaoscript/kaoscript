const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isString;
				const t1 = value => Type.isString(value) || Type.isNull(value);
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x, y) => {
				if(y === void 0 || y === null) {
					y = "foobar";
				}
				return [x, y];
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
	expect(foo("foo", "bar")).to.eql(["foo", "bar"]);
	expect(foo("foo", null)).to.eql(["foo", "foobar"]);
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
};