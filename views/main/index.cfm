<h1>Welcome to the Opus Group, LLC Data Compiler Test Site</h1>

<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
<cflocation url="#variables.form_action#" addtoken="false"/>