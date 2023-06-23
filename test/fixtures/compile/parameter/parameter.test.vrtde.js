const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x) => {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [x];
		}, (fn, ...args) => {
			const t0 = value => Type.isNumber(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(null)).to.eql([42]);
	expect(foo(1)).to.eql([1]);
	expect(Helper.function(() => {
		return foo("foobar");
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};