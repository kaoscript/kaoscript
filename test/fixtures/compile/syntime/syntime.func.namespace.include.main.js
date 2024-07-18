const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS1 = Helper.namespace(function() {
		let NS2 = Helper.namespace(function() {
			function foobar() {
				return foobar.__ks_rt(this, arguments);
			};
			foobar.__ks_0 = function() {
			};
			foobar.__ks_rt = function(that, args) {
				if(args.length === 0) {
					return foobar.__ks_0.call(that);
				}
				throw Helper.badArgs();
			};
			return {
				foobar
			};
		});
		return {
			NS2
		};
	});
	return {
		NS1
	};
};