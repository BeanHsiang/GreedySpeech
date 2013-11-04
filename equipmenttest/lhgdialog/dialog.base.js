var greedyint = greedyint || {};

greedyint.dialog = {};
//greedyint.dialog = $.noConflict(true);
//if (typeof $ == "undefined")
//    $ = greedyint.dialog;
//if (typeof jQuery == "undefined")
//    jQuery = greedyint.dialog;

greedyint.dialog.config = {
    time: 5,
    max: false,
    min: false
}

//greedyint.dialog.title('标题', '内容');
greedyint.dialog.alert = function (title, content, time, closeCallBack, id) {
    var thisDialog = $.dialog({
        id: id || '_alert_' + content,
        title: title || false,
        content: content || '内容',
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        time: time || greedyint.dialog.config.time,
        close: closeCallBack,
        icon: 'alert.gif'
    });

    thisDialog = greedyint.dialog.resize(thisDialog);
    return thisDialog;
}

//greedyint.dialog.error('错误', '系统异常,请联系管理员！', 3);
greedyint.dialog.error = function (title, content, time, closeCallBack) {

    var thisDialog = $.dialog({
        id: '_error_' + content,
        title: title || false,
        content: content || '系统异常,请联系管理员',
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        time: time || greedyint.dialog.config.time,
        close: closeCallBack,
        icon: 'error.gif'
    });

    thisDialog = greedyint.dialog.resize(thisDialog);
    return thisDialog;
}


//greedyint.dialog.success('成功', '保存成功！', 3);
greedyint.dialog.success = function (title, content, time, closeCallBack) {
    var thisDialog = $.dialog({
        id: '_success_' + content,
        title: title || false,
        content: content || '保存成功',
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        time: time || greedyint.dialog.config.time,
        close: closeCallBack,
        icon: 'success.gif'
    });

    thisDialog = greedyint.dialog.resize(thisDialog);
    return thisDialog;
}

greedyint.dialog.confirm = function (content, yes, no, parent, okVal, cancelVal, cancel, zIndex) {
    var thisDialog = $.dialog({
        title: '提醒',
        icon: 'confirm.gif',
        fixed: true,
        lock: true,
        content: content,
        resize: false,
        parent: parent || null,
        ok: yes,
        cancel: no || function () { },
        okVal: okVal || '确定',
        cancelVal: cancelVal || '取消',
        zIndex: zIndex
    });
    thisDialog = greedyint.dialog.resize(thisDialog);
    return thisDialog;
}

greedyint.dialog.info = function (content, yes) {
    var thisDialog = $.dialog({
        title: '提醒',
        icon: 'confirm.gif',
        fixed: true,
        lock: true,
        content: content,
        resize: false,
        ok: yes,
        okVal: '确定'
    });
    thisDialog = greedyint.dialog.resize(thisDialog);
    return thisDialog;
}

//greedyint.dialog.load('id','标题','/200801/1.html')
greedyint.dialog.load = function (id, title, url, islock, closeCallBack, successCallBack, parentId, zIndex) {
    var parent = greedyint.dialog.get(parentId);
    var api = $.dialog({
        title: title || false,
        fixed: true,
        id: id,
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        lock: islock || false,
        close: closeCallBack,
        parent: parent,
        zIndex: zIndex
    });
    if (url.indexOf('?') >= 0) {
        url += '&r=' + Math.random();
    }
    else {
        url += '?r=' + Math.random();
    }

    /* jQuery ajax */
    $.ajax({
        url: url,
        success: function (data) {
            api.content(data);
            greedyint.dialog.loadresize(api);
            if (successCallBack) {
                successCallBack();
            }
        },
        cache: false,
        error: greedyint.common.DealStatus
    });



    return api;
}


//greedyint.dialog.load('id','标题','/200801/1.html')
greedyint.dialog.loadcontent = function (id, title, html, islock, closeCallBack, successCallBack) {
    var api = $.dialog({
        title: title || false,
        fixed: true,
        id: id,
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        lock: islock || false,
        close: closeCallBack
    });

    api.content(html);
    return api;
}

greedyint.dialog.loadresize = function (api) {
    var _obj = api.DOM.content;

    _obj.height('auto');
    _obj.width('auto');

    if (_obj.height() >= $(window).height() - 70) {
        _obj.height($(window).height() - 70);
        _obj.width(_obj.width() + 50);
        _obj.css('overflow', 'auto');
        greedyint.dialog.DOMMouseScroll(_obj);
    }
    else {
        if (_obj.height() >= $(window).height() - 70) {
            _obj.height($(window).height() - 70);
            _obj.width(_obj.width() + 50);
            _obj.css('overflow', 'auto');
            greedyint.dialog.DOMMouseScroll(_obj);
        }
    }
    api._reset();
}

greedyint.dialog.loadframe = function (id, title, url, width, height, islock, closeCallBack, successCallBack, zIndex) {

    if (url.indexOf('?') >= 0) {
        url += '&r=' + Math.random();
    }
    else {
        url += '?r=' + Math.random();
    }

    var api = $.dialog({
        width: width || 500,
        height: height || 400,
        title: title || false,
        fixed: true,
        id: id,
        max: greedyint.dialog.config.max,
        min: greedyint.dialog.config.min,
        lock: islock || false,
        close: closeCallBack,
        content: 'url:' + url,
        zIndex: zIndex
    });
    var _obj = api.DOM.content;
    greedyint.dialog.DOMMouseScroll(_obj);
    if (successCallBack) {
        successCallBack();
    }
    return api;
}



//greedyint.dialog.get('id');
greedyint.dialog.get = function (id) {
    return lhgdialog.list[id];
}


//greedyint.dialog.close('id');
greedyint.dialog.close = function (id) {

    var $this = greedyint.dialog.get(id);

    if ($this) {
        $this.close();
    }
}

//greedyint.dialog.hide('id');
greedyint.dialog.hide = function (id) {
    var $this = greedyint.dialog.get(id);

    if ($this) {
        $this.hide();
    }
}

//greedyint.dialog.show('id');
greedyint.dialog.show = function (id) {
    var $this = greedyint.dialog.get(id);

    if ($this) {
        $this.show();
    }
}


greedyint.dialog.get = function (id) {
    return lhgdialog.list[id];
}

greedyint.dialog.loadHtml = '<div style="height:50px; line-height:50px; font-size:20px; font-weight:bold">'
 + '处理中,请稍等片刻...'
 + '</div>';

greedyint.dialog.loading = function (url) {
    var api = $.dialog({
        title: false,
        fixed: true,
        id: 'loading',
        lock: true,
        content: greedyint.dialog.loadHtml,
        width: 'auto',
        height: 'auto'
    });

    greedyint.dialog.resize(api);
    return api;
}


greedyint.dialog.tipHtml = '<div class="popup_errorMessage2 clearfix"><span class="fl">{0}</span><span class="IconClose3" onclick="javascript:greedyint.dialog.close(\'tip\');"></span></div>';
/**
msg:提示消息文本
top:高度
fixed:是否浮动，相对定位属性，true时跟随页面滚动滚动
time:关闭等待时间
**/
greedyint.dialog.tip = function (msg, top, fixed, time) {
    //    if (target) {
    //        top = $(target).offset().top;
    //    }
    if (fixed)
        fixed = true;

    var api = $.dialog({
        title: false,
        fixed: fixed,
        id: 'tip',
        lock: false,
        content: greedyint.dialog.tipHtml.format(msg),
        time: time || 3,
        padding: 0,
        top: top || '20%'
    });
    return api;
};

greedyint.dialog.uploadHTML = '<div style="height:50px; line-height:50px; font-size:20px; font-weight:bold">'
 + '{0}...'
 + '</div>';
//  close: closeCallBack,
greedyint.dialog.uploading = function (msg) {
    var api = $.dialog({
        title: false,
        fixed: true,
        id: 'uploading',
        lock: true,

        content: greedyint.dialog.uploadHTML.format(msg)
    });

    greedyint.dialog.resize(api);
    return api;
};

greedyint.dialog.uploadingWithCallback = function (msg, cb) {
    var api = $.dialog({
        title: false,
        fixed: true,
        id: 'uploading',
        lock: true,
        close: cb,
        content: greedyint.dialog.uploadHTML.format(msg)
    });

    greedyint.dialog.resize(api);
    return api;
};

//锁屏
greedyint.dialog.lock = function () {
    var html = '<div id="lockMask" class="lockMask">' +
	        '<div class="waitingbox">请稍候&nbsp;……</div>' +
            '</div>';
    $("body").append($(html));

    $("#lockMask").height($(window).height());
}

//关闭锁屏
greedyint.dialog.unLock = function () {
    $("#lockMask").remove();
}


greedyint.dialog.resize = function (that) {
    var _obj = that.DOM.content;
    _obj.height('auto');
    _obj.width('auto');
    that.position('50%', '38.2%');
}

greedyint.dialog.focus = function (that) {
    that.focus();
}
greedyint.dialog.zindex = function (that) {
    that.zindex();
}
greedyint.dialog.tipAbsoluteHtml = '<div id="tipAbsolute" class="popup_errorMessage2 clearfix" style=" position:absolute; top:40px; left:50%;">'
    + '<span class="fl">{0}</span>'
   + '<span class="IconClose3" onclick="tipAbsoluteClose(this)"></span>'
+ '</div>';
greedyint.dialog.tipAbsolute = function (msg, top, time) {

    if (!top) {
        top = '50%';
    }
    if (typeof top === 'number') {
        top = top + 'px';
    }
    if (!time) {
        time = 2000;
    }

    greedyint.dialog.tipAbsoluteHtml2 = greedyint.dialog.tipAbsoluteHtml.format(msg);

    var newTipAbsolute = $(greedyint.dialog.tipAbsoluteHtml2).css("top", top);
    if ($("#tipAbsolute")) {
        $("#tipAbsolute").remove();
    }
    newTipAbsolute.appendTo('body').html();
    var marginLeft = -newTipAbsolute.width() / 2 + 'px';
    $("#tipAbsolute").css("margin-left", marginLeft);
    setTimeout(function () { $("#tipAbsolute").remove(); }, time);
}

function tipAbsoluteClose(obj) {
    $("#tipAbsolute").remove();
}

greedyint.dialog.DOMMouseScroll = function (_div) {
    $(_div).bind('mousewheel', function (event) {
        //阻止冒泡
        var t = $(this).scrollTop() + (event.wheelDelta > 0 ? -60 : 60);
        $(this).scrollTop(t);
        return false;
    });

    $(_div).bind('DOMMouseScroll', function (event) {
        var t = $(this).scrollTop() + (event.detail > 0 ? 60 : -60);
        $(this).scrollTop(t);
        event.preventDefault();
    });
}


