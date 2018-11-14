var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let view;
	if(Type.is(view, UIImageView)) {
		console.log("It's an image view");
	}
	else if(Type.is(view, UILabel)) {
		let label = view;
		console.log("It's a label");
	}
	else if(Type.is(view, UITableView)) {
		let tblv = view;
		let sectionCount = tblv.numberOfSections();
		console.log("It's a table view with " + sectionCount + " sections");
	}
	else {
		console.log("It's some other UIView or subclass");
	}
};