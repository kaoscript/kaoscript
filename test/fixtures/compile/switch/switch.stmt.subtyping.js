const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let view = null;
	if(Type.isClassInstance(view, UIImageView)) {
		console.log("It's an image view");
	}
	else if(Type.isClassInstance(view, UILabel)) {
		let label = view;
		console.log("It's a label");
	}
	else if(Type.isClassInstance(view, UITableView)) {
		let tblv = view;
		let sectionCount = tblv.numberOfSections();
		console.log(Helper.concatString("It's a table view with ", sectionCount, " sections"));
	}
	else {
		console.log("It's some other UIView or subclass");
	}
};