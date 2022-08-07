const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	it("print", (() => {
		const __ks_rt = (done, ...args) => {
			args.unshift(done);
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return __ks_rt.__ks_0.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(done) {
			done();
		};
		return __ks_rt;
	})());
};