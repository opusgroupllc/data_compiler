<cfoutput>
	<form
		name="data_form"
		id="data_form"
		action="#request.form_action#"
		method="post"
		<!--- class="form-inline" --->
	>
		<input type="hidden" name="data_form_submitted" id="data_form_submitted" value="1"/>
		<div>
			<div class="form-group form-group-half-width" style="padding-right: 10px; ">
				<label for="detail">Detail Level</label>
				<select name="detail" id="detail" class="form-control">
					<!--- <option value="s" #form.detail IS 's' ? 'selected' : ''#>Summary</option>
					<option value="l" #form.detail IS 'l' ? 'selected' : ''#>Low</option>
					<option value="m" #form.detail IS 'm' ? 'selected' : ''#>Medium</option>
					<option value="b" #form.detail IS 'b' ? 'selected' : ''#>Basic</option> --->
					<option value="c" #form.detail IS 'c' ? 'selected' : ''#>Complete</option>
				</select>
			</div>
			<div class="form-group form-group-half-width" style="">
				<label for="max_records">Max Records</label>
				<select name="max_records" id="max_records" class="form-control">
					<option value=""> - SELECT - </option>
					<cfloop list="10,25,50,100,250,500,750,1000,2500,5000,10000,25000,50000,100000,1000000,1000000000" index="variables.i">
						<option
							value="#variables.i#"
							#form.max_records IS '#variables.i#' ? 'selected' : ''#
						>#numberFormat(variables.i, "999,999")#</option>
					</cfloop>
				</select>
			</div>
		</div>
		<div class="form-group" style="">
			<label for="maj_agency_cat">Agency</label>
			<select name="maj_agency_cat" id="maj_agency_cat" class="form-control">
				<option
					value=""
					#NOT len(form.maj_agency_cat) ? 'selected' : ''#
					title="* All Agencies *"
				>* All Agencies *</option>
				<cfloop query="#request.qryAgencyCodes#">
					<option
						value="#request.qryAgencyCodes.treasury_agency_code_txt#00"
						#form.maj_agency_cat IS '#request.qryAgencyCodes.treasury_agency_code_txt#00' ? 'selected' : ''#
						title="#request.qryAgencyCodes.agency_name_txt#"
					>#request.qryAgencyCodes.agency_name_txt#</option>
				</cfloop>
			</select>
		</div>
		<div>
			<!--- <div class="form-group form-group-half-width" style="padding-right: 10px; ">
				<label for="mod_agency">Mod Agency</label>
				<input type="text" name="mod_agency" id="mod_agency" maxlength="4" size="4" value="#form.mod_agency#" class="form-control"/>
			</div> ---><!---
			<div class="form-group form-group-half-width" style="">
				<label for="maj_agency_cat">Major Agency</label>
				<input type="text" name="maj_agency_cat" id="maj_agency_cat" maxlength="2" size="2" value="#form.maj_agency_cat#" class="form-control"/>
			</div> --->
		</div>
		<div>
			<div class="form-group form-group-half-width" style="padding-right: 10px; ">
				<label for="stateCode">State Code</label>
				<input type="text" name="stateCode" id="stateCode" maxlength="2" size="2" value="#form.stateCode#" class="form-control"/>
			</div>
			<div class="form-group form-group-half-width" style="">
				<label for="fiscal_year">Fiscal Year</label>
				<input type="text" name="fiscal_year" id="fiscal_year" maxlength="4" size="4" value="#form.fiscal_year#" class="form-control"/>
			</div>
		</div>
		<div class="form-group">
			<input type="submit" name="btn_submit" id="btn_submit" value="Get Data" class="btn btn-primary" style="width: 100%; "/>
		</div>
	</form>
</cfoutput>