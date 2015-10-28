
<cfinclude template="../includes/beta_warning.cfm"/>

<cfoutput>
	<cfinclude template="../includes/data_form.cfm"/>
</cfoutput>

<div id="data_loader_div">
	<!--- <cfloop from="1" to="7" index="i">
		<cfoutput> --->
			<div id="data_loader_" class="data_loader" style="display: none; ">
				Records <span class="records_from_span">1</span> to <span class="records_to_span">2</span> status:
				<div class="progress">
					<div
						class="data_loader_progress_bar progress-bar progress-bar-striped active"
						role="progressbar"
						aria-valuenow="0"
						aria-valuemin="0"
						aria-valuemax="0" style="width: 0%"
					>
						<span class="<!--- sr-only --->">
							0%
						</span>
					</div>
					<span class="data_loader_status">Initializing...</span>
				</div>
			</div>
		<!--- </cfoutput>
	</cfloop> --->
</div>