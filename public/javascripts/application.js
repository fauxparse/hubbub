$(document).ready(function() {
	$.facebox.settings['opacity'] = 0.5;
	rebind_handlers();
	redraw_tasks();

	$(document).bind('ajaxSuccess', function() {
	  rebind_handlers();
		redraw_tasks();
	});
	
	$(document).bind('reveal.facebox', function() {
		$('#facebox .footer').toggle($('#facebox ol.form li.buttons').length == 0);
		
		controls = $('#facebox :input:visible');
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
	$('.task-status').unbind('mouseover').unbind('mousemove').unbind('mouseout').hoverIntent({    
    sensitivity:3, interval: 200, timeout:500,
    over:function() {
      $(this).find('.details').fadeIn('fast');
    },
    out:function() {
      $(this).find('.details').fadeOut();
    }
  }).unbind('click.toggle').bind('click.toggle', function() { toggle_task_completion($(this).parent()); });
	$('.task-list .header a.toggle').unbind('click.toggle').bind('click.toggle', function() { var list = $(this.href.replace(/^[^#]+/,'')); $(this).css({ opacity:list.not(':visible').length * 0.5 + 0.5 }); list.toggle("blind"); return false; });
}

// TODO: replace with selector and cookie
var viewing_user_id = null;

var add_status_icons = function(task, ref) {
	recorded = parseFloat(ref.find('.recorded').html());
	task.removeClass('budgeted');
	task.removeClass('overbudget');
	if (ref != task) {
		ref.hasClass('completed') ? task.addClass('completed') : task.removeClass('completed');
	}
	for (i = 0; i <= 12; i++) { task.removeClass('p' + i); }
	if ((b = ref.find('.budget')).length > 0) {
		budget = parseFloat(b.html());
		task.addClass('budgeted');
		if (recorded > budget) {
			task.addClass('overbudget');
		} else if (recorded > 0) {
			p = Math.min(11, Math.max(1, Math.round(recorded * 12 / budget)));
			task.addClass('p' + p);
		}
	} else {
		if (recorded > 0) {
			task.addClass('p4');
		}
	}
}

function redraw_tasks() {
  redraw_task_lists();
  
	$('.task .task-status').each(function() {
		var task = $(this);
		t = (viewing_user_id && (u = task.find('.user-recorded-time.user_' + viewing_user_id)).length > 0) ? u : task.find('.task-recorded-time');
		add_status_icons(task, t);
		task.find('.assignment-recorded-time').map(function() { add_status_icons($(this), $(this)); });

    var project = $(this).parents('.project');
    if (project.length > 0) {
      $(this).parent().find('.' + project.attr('id')).hide();
    }
	});
}

function redraw_task_lists() {
  $('.task-list').each(function() {
    var task_list = $(this),
        open_tasks = task_list.find('.task.open'),
        completed_tasks = task_list.find('.task.completed');
        
    task_list.find('.header a.toggle').each(function() {
      $(this).html(($(this).hasClass('open') ? open_tasks : completed_tasks).length);
      var list = $(this.href.replace(/^[^#]+/,''));
      $(this).css({ opacity:list.filter(':visible').length * 0.5 + 0.5 })
    });
    
    (open_tasks.length == 0) ? task_list.find('.empty').show() : task_list.find('.empty').hide();
  });
}

function toggle_task_completion(task) {
  task = $(task);
  
  task.find('.task-status').toggleClass('completed').each(function() { clearTimeout(this.close_popup); clearTimeout(this.open_popup); }).find('.details').hide();
  task.toggleClass('completed')
  if (task.hasClass('completed')) {
    task.removeClass('open').fadeOut('fast', function() {
      $(this).prependTo($(this).parents('.task-list').find('.completed.tasks')).fadeIn('fast');
    });
  } else {
    task.addClass('open').fadeOut('fast', function() {
      $(this).prependTo($(this).parents('.task-list').find('.open.tasks')).fadeIn('fast');
    });
  }
  
  redraw_task_lists();
  
  task_id = task.attr('id').replace('task_', '');
  $.ajax({
    url:'/tasks/' + task_id + '/complete.js',
    type:'post',
    data:{ _method:'put' },
    dataType:'script'
  });
}
