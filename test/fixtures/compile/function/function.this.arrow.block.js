const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		this.foobar = true;
		return Helper.function(() => {
			this.arrow = true;
			return this;
		}, (fn, ...args) => {
			if(args.length === 0) {
				return fn.call(this);
			}
			throw Helper.badArgs();
		});
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(foobar.__ks_0.call(new Dictionary())());
};