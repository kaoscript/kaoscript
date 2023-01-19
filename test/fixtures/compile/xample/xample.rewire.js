const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function rewire() {
		return rewire.__ks_rt(this, arguments);
	};
	rewire.__ks_0 = function(option) {
		let files = [];
		for(let __ks_2 = option.split(","), __ks_1 = 0, __ks_0 = __ks_2.length, item; __ks_1 < __ks_0; ++__ks_1) {
			item = __ks_2[__ks_1];
			item = item.split("=");
			files.push((() => {
				const o = new OBJ();
				o.input = item[0];
				o.output = item[1];
				return o;
			})());
		}
		return files;
	};
	rewire.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return rewire.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};