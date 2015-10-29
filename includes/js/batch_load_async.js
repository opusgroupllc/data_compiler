
var objDataLoaderTemplate;

function setDataLoaderProgress(strDataLoaderId, intPercent, bolUsePercent) {
	if (typeof bolUsePercent == "undefined") {
		var bolUsePercent = true;
	}
	
	var aryDataLoaderId = strDataLoaderId.split("_");
	var intDataLoaderIdNumber = aryDataLoaderId[aryDataLoaderId.length - 1];
	
	if (intPercent >= 0 && intPercent < 100) {
		strProgressText = bolUsePercent ? String(intPercent) + "%" : "Loading...";
		$("#" + strDataLoaderId).find(".data_loader_progress_bar:first").addClass("progress-bar-striped").removeClass("progress-bar-success");
		$("#" + strDataLoaderId).find("a.data_loader_try_again:first").hide();
	} else if (intPercent == 100) {
		strProgressText = "Complete!";
		$("#" + strDataLoaderId).find(".data_loader_progress_bar:first").addClass("progress-bar-success").removeClass("progress-bar-striped").removeClass("progress-bar-danger");
		$("#" + strDataLoaderId).find("a.data_loader_try_again:first").hide();
	} else if (intPercent == -1) {
		strProgressText = "FAILURE "
			+ "(<a href=\"javascript: void(0); \" onClick=\"getDataSet('" + strDataLoaderId + "', " + String(intDataLoaderIdNumber) + "); \" class=\"data_loader_try_again\">Try Again</a>)";
		;
		//"getDataSet('data_loader_" + String(intPanelNumber) + "', " + String(intPanelNumber) + "; "
		//<a href="javascript: void(0); " class="data_loader_try_again" style="display: none; ">Try Again</a>
		$("#" + strDataLoaderId).find(".data_loader_progress_bar:first").addClass("progress-bar-danger").removeClass("progress-bar-striped");
		$("#" + strDataLoaderId).find("a.data_loader_try_again:first").show();
	}
	
	if (intPercent == 0) {
		$("#" + strDataLoaderId).find(".data_loader_status:first").html("Initializing...");
	} else {
		$("#" + strDataLoaderId).find(".data_loader_status:first").html("");
	}
	
	$("#" + strDataLoaderId).find(".data_loader_progress_bar:first")
		.css("width", String(intPercent >= 0 ? intPercent : 100) + "%")
		.children("span:first").html(strProgressText);
		
}

function loadData() {
	$.ajax({
		method: "post"
		, url: "/remote/DataProxy.cfc?method=initializeDataLoadProcess"
		, data: {}
		, beforeSend: function() {
			$("#data_loader_div").html("<span style='margin-left: 15px; '>Initializing process...</span>");
		}
		, success: function(data) {
			if (data == "true") {
				$("#data_loader_div").html("");
				var intRecordsFrom = 1;
				var intMilliseconds = 0;
				for (i = 1; i <= new Number($("#max_records").val()); i += 500) {
					intMilliseconds += 3000; 
					$("#data_loader_div").append(createDataPanel(i));
					setTimeout(
						function() {
							// console.log(String((i - 1) * 2));
							getDataSet("data_loader_" + String(intRecordsFrom), intRecordsFrom);
							intRecordsFrom += 500; 
						}
						, intMilliseconds
					);
				}
			} else {
				$("#data_loader_div").html("<span style='margin-left: 15px; '>Process initialization failed. Please try again.</span>");
			}
		}
		, error: function() {
			$("#data_loader_div").html("<span style='margin-left: 15px; '>Process initialization failed. Please try again.</span>");
		}
	});
}

//-------------------------------------------------------------------------------
function getDataSet(strDataLoaderId, intRecordsFrom) {
	$.ajax({
		method: "post"
		, url: "/remote/DataProxy.cfc?method=getDataSetAJAX"
		, data: {
			detail: $("#detail").val()
			, records_from: intRecordsFrom
			, max_records: 500  //$("#max_records").val()
			, stateCode: $("#stateCode").val()
			/*-- $("#agency_id").val() --*/
			, mod_agency: $("#mod_agency").val()
			, maj_agency_cat: $("#maj_agency_cat").val()
			, fiscal_year: $("#fiscal_year").val()
			//, generate_spreadsheet: $("#generate_spreadsheet").val()
		}
		, beforeSend: function() {
			console.log("Before send: " + String(intRecordsFrom));
			setDataLoaderProgress(strDataLoaderId, 50, false);			
		}
		, success: function(data) {
			console.log("Success: " + String(intRecordsFrom) + " " + data);
			if (data == "true") {
				setDataLoaderProgress(strDataLoaderId, 100, false);
			} else {
				setDataLoaderProgress(strDataLoaderId, -1, false);
			}
		}
		, error: function() {
			console.log("Error: " + String(intRecordsFrom));
			setDataLoaderProgress(strDataLoaderId, -1, false);
		}
	});
}

//-------------------------------------------------------------------------------
function createDataPanel(intPanelNumber) {
	var objCurrentDataLoader = $(objDataLoaderTemplate).clone();
	
	$(objCurrentDataLoader).attr(
		"id"
		, $(objCurrentDataLoader).attr("id") + String(intPanelNumber)
	);
	$(objCurrentDataLoader).find(".records_from_span:first").html(intPanelNumber);
	$(objCurrentDataLoader).find(".records_to_span:first").html(intPanelNumber + 499);
	$(objCurrentDataLoader).show();
	
	return objCurrentDataLoader;	
}

// $(document).on(
	// "click"
	// , "a.data_loader_try_again"
	// , function() {
		// $(this).
	// }
// );

$(document).on(
	"click"
	, "#btn_button"
	, function() {
		if (confirm("WARNING: This will delete the currently imported data before loading the requested data, and may take several minutes.\n\nAre you sure you want to proceed?")) {
			$("#data_loader_div").html("");
			loadData();
		}
	}
);


$(document).ready(
	function() {
		objDataLoaderTemplate = $("#data_loader_");
	}
);