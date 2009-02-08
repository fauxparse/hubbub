$(document).ready(function() {
	$.facebox.settings['opacity'] = 0.5;
	rebind_handlers();

	$(document).bind('ajaxSuccess', function() {
	  rebind_handlers();
	});
	
	$(document).bind('reveal.facebox', function() {
		$('#facebox .footer').toggle($('#facebox ol.form li.buttons').length == 0);
		
		controls = $('#facebox input:visible, #facebox textarea:visible');
		if (controls.length > 0) {
		  controls[0].focus();
		}
		rebind_handlers();
	});

	$(document).ajaxSend(function(event, request, settings) {
	  if (typeof(AUTH_TOKEN) == "undefined") return;
	  settings.data = settings.data || "";
		switch (typeof(settings.data)) {
		case 'string':
			settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
			break;
		default:
			settings.data['authenticity_token'] = AUTH_TOKEN;
			break;
		}
	});
})

function rebind_handlers() {
  $('a[rel*=facebox]').unbind('click.facebox').facebox();
  $('input.date').datepicker('destroy').datepicker({ dateFormat:'D, d M yy' });
}
