module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
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
}