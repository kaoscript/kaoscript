const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const foobar = Helper.function(() => {
		return "foobar";
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	});
	console.log(foobar.__ks_0());
	return {
		foobar
	};
};