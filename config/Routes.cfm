<cfscript>
	// Allow unique URL or combination of URLs, we recommend both enabled
	setUniqueURLS(false);
	// Auto reload configuration, true in dev makes sense to reload the routes on every request
	//setAutoReload(false);
	// Sets automatic route extension detection and places the extension in the rc.format variable
	// setExtensionDetection(true);
	// The valid extensions this interceptor will detect
	// setValidExtensions('xml,json,jsont,rss,html,htm');
	// If enabled, the interceptor will throw a 406 exception that an invalid format was detected or just ignore it
	// setThrowOnInvalidExtension(true);

	// Base URL
	if( len(getSetting('AppMapping') ) lte 1){
		setBaseURL("http://#cgi.HTTP_HOST#/index.cfm");
	}
	else{
		setBaseURL("http://#cgi.HTTP_HOST#/#getSetting('AppMapping')#/index.cfm");
	}

	// MY Routes
	addRoute(pattern = "/openfda", handler = "openfda", action = "index");
	addRoute(pattern = "/fpds", handler = "fpds", action = "index");

	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "index");
	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "d3_individual");
	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "batch_load_setup");
	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "batch_load_process");
	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "batch_load_async");
	addRoute(pattern = "/usaspending/:action?", handler = "usaspending", action = "deliver_spreadsheet");

	addRoute(pattern = "/remote/:action?", remote = "DataProxy", action = "getDataSetJSON");

	// Your Application Routes
	addRoute(pattern=":handler/:action?");
</cfscript>