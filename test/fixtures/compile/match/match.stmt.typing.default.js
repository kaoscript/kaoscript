const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(view) {
		if(Type.isClassInstance(view, UIImageView)) {
			console.log("It's an image view");
		}
		else if(Type.isClassInstance(view, UILabel)) {
			let label = view;
			console.log("It's a label");
		}
		else if(Type.isClassInstance(view, UITableView)) {
			let tblv = view;
			const sectionCount = tblv.numberOfSections();
			console.log(Helper.concatString("It's a table view with ", sectionCount, " sections"));
		}
		else {
			console.log("It's some other UIView or subclass");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, UIView);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};