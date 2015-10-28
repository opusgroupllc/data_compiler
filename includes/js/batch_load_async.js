
var objDataLoader;

function setDataLoaderProgress(strDataLoaderId, intPercent, bolUsePercent) {
	if (typeof bolUsePercent == "undefined") {
		var bolUsePercent = true;
	}
	
	if (intPercent < 100) {
		strProgressText = bolUsePercent ? String(intPercent) + "%" : "Loading...";
		$("#" + strDataLoaderId).find(".data_loader_progress_bar:first").addClass("progress-bar-striped").removeClass("progress-bar-success");
	} else {
		strProgressText = "Complete!";
		$("#" + strDataLoaderId).find(".data_loader_progress_bar:first").addClass("progress-bar-success").removeClass("progress-bar-striped");
	}
	
	if (intPercent == 0) {
		$("#" + strDataLoaderId).find(".data_loader_status:first").html("Initializing...");
	} else {
		$("#" + strDataLoaderId).find(".data_loader_status:first").html("");
	}
	
	$("#" + strDataLoaderId).find(".data_loader_progress_bar:first")
		.css("width", String(intPercent) + "%")
		.children("span:first").html(strProgressText);
		
}

function loadData() {
	var objCurrentDataLoader;
	for (i = 1; i <= new Number($("#max_records").val()); i += 500) {
		objCurrentDataLoader = $(objDataLoader).clone();
		$(objCurrentDataLoader).attr(
			"id"
			, $(objCurrentDataLoader).attr("id") + String(i)
		);
		$(objCurrentDataLoader).find(".records_from_span:first").html(i);
		$(objCurrentDataLoader).find(".records_to_span:first").html(i + 499);
		$(objCurrentDataLoader).show();
			
		$("#data_loader_div").append(objCurrentDataLoader);
	}
}

$(document).ready(
	function() {
		objDataLoader = $("#data_loader_");
	}
);

$(document).on(
	"click"
	, "#btn_button"
	, function() {
		loadData();
		// setDataLoaderProgress("data_loader_1", 0);
		// setDataLoaderProgress("data_loader_501", 50);
		// setDataLoaderProgress("data_loader_1001", 50, false);
		// setDataLoaderProgress("data_loader_1501", 100);
	}
);
