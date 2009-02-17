$(document).ready(function() {
	$.facebox.settings['opacity'] = 0.5;
	rebind_handlers();

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
	
	load_user_selection();

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

var viewing_user_id = $.cookie('selected_user');

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
		t = (viewing_user_id && (u = task.find('.assignment-recorded-time.user_' + viewing_user_id)).length > 0) ? u : task.find('.task-recorded-time');
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
        open_tasks = task_list.find('.task.open:visible'),
        completed_tasks = task_list.find('.task.completed:visible');
        
    task_list.find('.header a.toggle').each(function() {
			if ($(this).hasClass('open')) {
	      $(this).html('<strong>' + open_tasks.length + '</strong> open');
			} else {
	      $(this).html('<strong>' + completed_tasks.length + '</strong> completed');
			}
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

function load_user_selection() {
  if ((select_tag = $('select#viewing-user')).length > 0) {
    var v = '<div id="viewing-user" class="user-selector">';
    v += '<a href="#" class="arrow">▼</a>';
    v += '<span class="current"></span>';
    v += '<ul class="options" style="display: none;">';
    $.each(select_tag[0].options, function() {
      u = (this.value == '' ? 'anybody' : 'user_' + this.value)
      v += '<li><a class="' + u + '" href="#' + u + '" style="background-image: url(' + (this.value == '' ? '/images/select-anybody.png' : '/images/avatars/' + this.value + '/tiny.jpg') + ')"><strong>' + this.text + '</strong></a></li>';
    });
    v += '</ul>';
    v += '</div>';
    select_tag.replaceWith(v);
    $('#viewing-user .arrow, #viewing-user .current').click(function(e) {
      $(this).parent().find('.options').slideToggle('fast');
      e.stopPropagation();
      return false;
    });
    $('#viewing-user .options a').click(function(e) {
      set_selected_user(this.className == 'anybody' ? '' : this.className.replace('user_', ''));
      e.stopPropagation();
      return false;
    });
    $(document).click(function() { $('#viewing-user .options:visible').hide('slide', { direction:'up' }, 'fast'); });
  }
  set_selected_user(viewing_user_id);
}

function set_selected_user(v) {
  $.cookie('selected_user', v);
  var u = (v == null || v == 0 || v == '' ? 'anybody' : 'user_' + v);
  var a = $('#viewing-user .options .' + u);
  $('#viewing-user .current').html(a.find('strong').html()).css('background-image', a.css('background-image'));
  $('#viewing-user .options:visible').hide('slide', { direction:'up' }, 'fast');
  var tasks = $('li.task');
  if (u == 'anybody') {
		viewing_user_id = null;
    tasks.show();
  } else {
		viewing_user_id = u.replace(/^[^0-9]+/, '');
    tasks.hide().filter('.' + u + ', .anybody, .unassigned').show();
  }
  redraw_tasks();
  return false;
}

function reorder_task_lists() {
	$('#sidebar .actions a.button, .task-list .header small').toggle();
	$('#sidebar #new-task-list-form').hide();
	var reordering = $('#sidebar .actions .reorder.done:visible').length > 0;
	$('.task-list .contents').slideToggle('fast');
	if (reordering) {
		$('.project .lists').sortable({ items:'.task-list', axis:'y', forceHelperSize:true });
	} else {
		$.ajax({
			url:'/lists/reorder.js',
			type:'post',
			data:'_method=put&' + $('.project .lists').sortable('serialize'),
			dataType:'script'
		});
		$('.project .lists').sortable('destroy');
	}
}

