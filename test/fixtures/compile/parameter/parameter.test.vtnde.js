const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x = null) => {
			return [x];
		}, (that, fn, ...args) => {
			const t0 = value => Type.isNumber(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return fn.call(null, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
	expect(Helper.function(() => {
		return foo("foo");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(1, 2);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", 1);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};