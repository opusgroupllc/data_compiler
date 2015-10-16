
<cfif isDefined("request.stcSpreadsheetError") AND request.stcSpreadsheetError.bolSpreadsheetError>
	<div class="alert alert-danger" role="alert">#request.stcSpreadsheetError.strSpreadsheetErrorMessage#</div>
<cfelse>
	<script>
		window.close();
	</script>
</cfif>
