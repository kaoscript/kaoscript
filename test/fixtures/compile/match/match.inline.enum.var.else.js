const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Accessibility = Helper.enum(Number, 0, "Internal", 1, "Private", 2, "Protected", 3, "Public", 4);
	function isLessAccessibleThan() {
		return isLessAccessibleThan.__ks_rt(this, arguments);
	};
	isLessAccessibleThan.__ks_0 = function(source, target) {
		let result;
		if(source === Accessibility.Protected) {
			result = target === Accessibility.Public;
		}
		else if(source === Accessibility.Private) {
			result = target === Accessibility.Protected || target === Accessibility.Public;
		}
		else if(source === Accessibility.Internal) {
			result = target === Accessibility.Private || target === Accessibility.Protected || target === Accessibility.Public;
		}
		else {
			result = false;
		}
		return result;
	};
	isLessAccessibleThan.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Accessibility);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return isLessAccessibleThan.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};