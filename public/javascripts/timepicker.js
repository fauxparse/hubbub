(function($) {
	$.fn.time_picker = function() {
		return this.each(function() {
			new $.TimePicker(this);
		})
	}
})(jQuery);

$.TimePicker = function(input) {
	var KEY = {
		UP: 38,
		DOWN: 40,
		TAB: 9,
		RETURN: 13,
		ESC: 27,
		PAGEUP: 33,
		PAGEDOWN: 34,
		BACKSPACE: 8,
		FULLSTOP: 46,
		COLON: 58
	};
	
	var block_submit;
	var list_showing = false;
	var timeout;
			
	list_contents = '';
	for (i = 15; i <= 480; i += 15) {
		m = Math.floor(i / 60) + ':' + (i % 60 < 10 ? '0' : '') + (i % 60);
		list_contents += '<li><a href="#" title="'+m+'">'+m+'</a></li>';
	}

	var selector = $('<div><ul>' + list_contents + '</ul></div>')
	.hide()
	.css({ position:'absolute', opacity:0.9, display:'none' })
	.addClass('time-picker-select')
	.appendTo(document.body);
	
	$(selector).find('a')
	.bind('click.time_picker', function() {
		$(input).val($(this).text()).blur();
		return false;
	})
	.bind('mousedown.time_picker', function() {
		input._mouse_down_on_item = true;
	})
	.bind('mouseup.time_picker', function() {
		input._mouse_down_on_item = false;
	})
	.bind('mouseover.time_picker', function() {
		input.set_selected_item(this);
	});
	
	$(input)
	.attr('autocomplete', 'off')
	.bind('focus.time_picker', function() {
		input.show_list();
		input.select();
	})
	.bind('blur.time_picker', function() {
		input.hide_list();
	})
	.bind(($.browser.opera || $.browser.mozilla ? 'keypress' : 'keydown') + '.time_picker', function(event) {
		lastKeyPressCode = event.keyCode;
		switch(event.keyCode) {
			case KEY.UP:
				event.preventDefault();
				selector.prev();
				return false;
			case KEY.DOWN:
				event.preventDefault();
				selector.next();
				return false;
			case KEY.PAGEUP:
				event.preventDefault();
				selector.page_up();
				return false;
			case KEY.PAGEDOWN:
				event.preventDefault();
				selector.page_down();
				return false;
			case KEY.RETURN:
			case KEY.ESC:
				if (list_showing) {
					if (event.keyCode == KEY.RETURN && ((str = $(selector).find('a.selected').text()) != '')) {
						$(input).val(str);
					}
					input.hide_list();
					block_submit = true;
					return false;
				} else {
					block_submit = false;
				}
				break;
			case 0:
				switch(event.which) {
					case KEY.FULLSTOP:
						selector.switch_to_fractions_of_hours();
						break;
					case KEY.COLON:
						selector.switch_to_hours_and_minutes();
						break;
				}
			default:
				clearTimeout(timeout);
				timeout = setTimeout(input.changed, 100);
				break;
		}
	});
	
	// prevent form submit in opera when selecting with return key
	$.browser.opera && $(input.form).bind("submit.time_picker", function() {
		if (block_submit) {
			block_submit = false;
			return false;
		}
	});

	input.show_list = function() {
		var offset = $(input).offset();
		selector.css({
			top: offset.top + $(input).height() + 5,
			left: offset.left,
			width: $(input).width() + 5
		}).show();
		
		this.set_selected_item($(input).val());
		list_showing = true;
		$(document).unbind('keydown.facebox');
	}
	
	input.hide_list = function() {
		if (!input._mouse_down_on_item) {
			selector.hide();
			block_submit = false;
			list_showing = false;
			$(document).bind('keydown.facebox', function(e) {
        if (e.keyCode == 27) $.facebox.close();
        return true;
      });
		}
	}
	
	input.items = function() {
		if (typeof(input._items) == 'undefined') {
			input._items = $(selector).find('a');
		}
		return input._items;
	}

	input.set_selected_item = function(index_or_string, keep_input_value) {
		if (typeof(index_or_string) == 'object') {
			input.selected_index = $(index_or_string).parent().prevAll('li').length;
		} else if (typeof(index_or_string) == 'string') {
			var new_index = 0;
			var str = $(input).val(), items = input.items();
			for (j = str.length; j >= 0; j--) {
				var set = false, sub = str.substr(0, j);
				for (i = 0; i < items.length; i++) {
					if ($(items[i]).text().substr(0, j) == sub) {
						set = i;
						break;
					}
				}
				if (set != false) {
					new_index = set;
					break;
				}
			}
			input.selected_index = new_index;
		} else {
			input.selected_index = index_or_string;
		}
		top = 0;
		if (input.selected_index > -1) {
			for (i = 0, items = input.items(); i < input.selected_index; i++) {
				top += items[i].offsetHeight;
			}
			str = selector.find('a:eq(' + input.selected_index + ')').text();
			if (!keep_input_value && $(input).val() != str) {
				$(input).val(str);
			}
		}
		selector
		.find('a').removeClass('selected').end()
		.find('a:eq(' + input.selected_index + ')').addClass('selected').end();
		if (typeof(index_or_string) != 'object') {
			selector.scrollTop(top);
		}
	}
	
	selector.switch_to_hours_and_minutes = function() {
		var items = input.items();
		for (i = 1; i <= items.length; i++) {
			h = Math.floor(i / 4);
			m = (i % 4) * 15;
			str = h + ':' + (m < 10 ? '0' : '') + m;
			$(items[i - 1]).attr('title', str).text(str);
		}
	}
			
	selector.switch_to_fractions_of_hours = function() {
		var items = input.items();
		for (var i = 1; i <= items.length; i++) {
			h = Math.floor(i / 4);
			m = (i % 4) * 25;
			str = h + '.' + (m < 10 ? '0' : '') + m;
			$(items[i - 1]).attr('title', str).text(str);
		}
	}

	selector.next = function() {
		var list_was_showing = list_showing;
		input.show_list();
		if (typeof(input.selected_index) == 'undefined') { input.selected_index = -1; }
		input.set_selected_item(list_was_showing ? (input.selected_index + 1) % input.items().length : input.selected_index);
		input.changed(true);
	}

	selector.prev = function() {
		var list_was_showing = list_showing;
		input.show_list();
		if (typeof(input.selected_index) == 'undefined') { input.selected_index = 0; }
		input.set_selected_item(list_was_showing ? (input.selected_index + input.items().length - 1) % input.items().length : input.selected_index);
		input.changed(true);
	}

	selector.page_down = function() {
		var list_was_showing = list_showing;
		input.show_list();
		if (typeof(input.selected_index) == 'undefined') { input.selected_index = -1; }
		input.set_selected_item(list_was_showing ? (input.selected_index + 4) % input.items().length : input.selected_index);
		input.changed(true);
	}

	selector.page_up = function() {
		var list_was_showing = list_showing;
		input.show_list();
		if (typeof(input.selected_index) == 'undefined') { input.selected_index = 0; }
		input.set_selected_item(list_was_showing ? (input.selected_index + input.items().length - 4) % input.items().length : input.selected_index);
		input.changed(true);
	}

	input.changed = function(skip_update) {
		if (!skip_update) {
			var str = $(input).val();
			if (str.indexOf('.') > -1) {
				selector.switch_to_fractions_of_hours();
			} else {
				selector.switch_to_hours_and_minutes();
			}
			input.set_selected_item(str, true);
		}
	}
	
}

$.timer = function() {
  return self;
}

$.extend($.timer, {
  properties:{
    _running:false,
  },
  
  init: function() {
    $.timer.load_from_cookie();
    $.timer.run();
  },
  
  start:function(task) {
		if ($.timer.properties._running && $.timer.properties._current_task == task) {
			$.timer.stop();
			return false;
		} else if ($.timer.paused()) {
      $.timer.properties._started_at += (new Date().valueOf() - $.timer.properties._paused_at);
      $.timer.properties._paused_at = null;
    } else {
	    $.timer.current_task(task || null);
      $.timer.properties._started_at = new Date().valueOf();
    }
    
    $.timer.properties._running = true;
    $.timer.run();
    $.timer.save_to_cookie();
  },
  
  run:function(task) {
    if ($.timer.properties._running) {
      $.timer._interrupt = window.setInterval('$.timer.update_counter()', 100);
			$('#header #timer').unbind('mouseover.timer').bind('mouseover.timer', function() {
				$('#timer-hint').show();
			});
			$('#header #timer').unbind('mouseout.timer').bind('mouseout.timer', function() {
				$('#timer-hint').hide();
			});
		}
		if ($.timer.properties._current_task) {
			$('#task_' + $.timer.properties._current_task + ' .start-timer').addClass('timing');
		}
    $.timer.update_counter();
  },
  
  stop:function() {
    window.clearInterval($.timer._interrupt);
    
    // clean up, save, etc
		now = new Date().valueOf();
    minutes = Math.round((($.timer.paused() ? $.timer.properties._paused_at : now) - $.timer.properties._started_at) / 60000);

		if ($.timer.properties._current_task) {
			$('#task_' + $.timer.properties._current_task + ' .start-timer').removeClass('timing');
			/*
			$.ajax({
				type:'post',
				url:'/tasks/' + $.timer.properties._current_task + '/time_slices.js',
				data:'time_slice[user_id]=' + $('#current_user_id').val() + '&time_slice[minutes]=' + minutes,
				dataType:'script'
			});
			$.notify(minutes + ' minute(s) recorded against ‘' + $.timer.properties._current_task_name + '’.');
			*/
			$.ajax({
				url:'/tasks/' + $.timer.properties._current_task + '/time_slices/new?time_slice[minutes]=' + minutes,
				type:'get',
				success:function(data) {
					$.facebox(data);
				}
			});
		} else {
			//console.log('no current task');
		}
    $.timer.properties = { _running:false };
    
    $.timer.update_counter();
    $.timer.save_to_cookie();
  },
  
  pause:function() {
    $.timer.properties._paused_at = new Date().valueOf();
    $.timer.update_counter();
    $.timer.save_to_cookie();
  },
  
  paused:function() {
    return $.timer.properties._paused_at;
  },
  
  current_task:function(task) {
    if (typeof(task) != 'undefined') {
      if ($.timer.properties._current_task && task != $.timer.properties._current_task) {
        $.timer.stop();
      }
      $.timer.properties._current_task = task;
			$.get('/tasks/' + task + '.json', function(data) {
				data = $.evalJSON(data).task;
				$.timer.properties._current_task_name = data.name;
				$.timer.properties._current_task_theme = data.theme.name;
				$.timer.properties._current_task_project = data.theme.project.name;
				$.timer.properties._current_task_client = data.theme.project.client.name;
				$('#timer-current-task-name').html($.timer.properties._current_task_name);
				$('#timer-current-task-crumbs').html($.timer.properties._current_task_client + ' » ' + $.timer.properties._current_task_project);
				$.timer.save_to_cookie();
			});
    }
    return $.timer.properties._current_task || null;
  },
  
  save_to_cookie:function() {
    $.cookie('timer', $.toJSON($.timer.properties), { path:'/' });
  },
  
  load_from_cookie:function() {
    properties = $.cookie('timer');
    if (properties) {
      $.timer.properties = $.evalJSON(properties);
			$('#timer-current-task-name').html($.timer.properties._current_task_name);
			$('#timer-current-task-crumbs').html($.timer.properties._current_task_client + ' » ' + $.timer.properties._current_task_project);
    }
  },
  
  update_counter:function() {
    if ($.timer.properties._running) {
      now = new Date().valueOf();
      if ($.timer.paused()) {
        s = Math.floor(($.timer.properties._paused_at - $.timer.properties._started_at) / 1000);
        $('#timer').addClass('paused');
        $('#timer .start, #timer .stop').removeClass('disabled');
        $('#timer .pause').addClass('disabled');
				$('#timer-current-task-status').html('Paused:');
      } else {
        s = Math.floor((now - $.timer.properties._started_at) / 1000);
        $('#timer').removeClass('paused');
        $('#timer .pause, #timer .stop').removeClass('disabled');
        $('#timer .start').addClass('disabled');
				$('#timer-current-task-status').html('Timing:');
      }
      m = Math.floor(s / 60) % 60; m = (m < 10 ? '0' : '') + m;
      h = Math.floor(s / 3600); h = (h < 10 ? '0' : '') + h;
      s = s % 60; s = (s < 10 ? '0' : '') + s;
      $('#timer-display').html('<div class="counter">' + h + '<span class="colon">:</span>' + m + '</div>');
      if (!$.timer.paused()) {
        $('#timer-display .counter .colon').css('opacity', Math.sin(now / 250) / 4 + 0.75);
      }
      $('#timer-controls').show();
    } else {
      $('#timer-display').html('');//'<p>No timers running. <a href="#" onclick="$.timer.start(null); return false;">Start one?</a>');
      $('#timer-controls').hide();
    }
  }
});
