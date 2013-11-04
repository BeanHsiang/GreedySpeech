var GreedySpeech = {};

/*
 伪随机字符串，用于生成id
 */
GreedySpeech.createId = function () {
    return "gs" + ("" + 1e10).replace(/[018]/g, function (a) {
        return (a ^ Math.random() * 16 >> a / 4).toString(16)
    });
}

/*
 安装函数
 传入配置项，检测是否可用
 options:{
 id:"容器编号"
 }
 */
GreedySpeech.setup = function (options) {
    GreedySpeech.swfobject = GreedySpeech.swfobject || swfobject;
    if (!GreedySpeech.swfobject) {
        alert("缺少swfobject.js引用");
    }

    function embedSWF(id) {
        var swfVersionStr = "11.1.0";
        var xiSwfUrlStr = "greedyspeech/playerProductInstall.swf";
        var flashvars = {rate: GreedySpeech.options.rate, channels: GreedySpeech.options.channels, bit: GreedySpeech.options.bit};
        var params = {};
        params.quality = "high";
        //params.bgcolor = "#ffffff";
        params.allowscriptaccess = "samedomain";
        params.allowfullscreen = "false";
        params.wmode = "transparent";
        var attributes = {};
        attributes.id = GreedySpeech.options.sId;
        attributes.name = GreedySpeech.options.sId;
        //attributes.align = "middle";
        swfobject.embedSWF(GreedySpeech.options.swfUlr, id, GreedySpeech.options.width, GreedySpeech.options.height, swfVersionStr, xiSwfUrlStr, flashvars, params, attributes);
    }

    var swfId = GreedySpeech.createId();
    //设置配置项，合并默认值
    function setOptions(opts) {
        GreedySpeech.options = {
            swfUlr: "greedyspeech/GreedySpeech.swf",
            sId: swfId,
            id: opts.id,
            width: 320,
            height: 240,
            format: opts.format || "x-wav",
            uploadUrl: opts.uploadUrl,
            rate: opts.rate || 44,
            channels: opts.channels || 2,
            bit: opts.bit || 16
        };
        var swfdiv = document.createElement('div');
        var tmpId = GreedySpeech.createId();
        swfdiv.setAttribute('id', tmpId);
        var container = document.getElementById(GreedySpeech.options.id);
        container.innerHTML = "";
        container.appendChild(swfdiv);
        embedSWF(tmpId);
    }

    setOptions(options);

    //初始化接口定义
    function initAPI() {
        var recorder = document.getElementById(GreedySpeech.options.sId);

        function delegate(name) {
//			var outArgs=arguments;
            GreedySpeech[name] = function () {
                return recorder[name].apply(recorder, arguments);
            }
        }

        //delegate('stopPlaying');
        //delegate('startRecord');
        //delegate('stopRecord');
        //delegate('play');
        //delegate('stopPlayRecord');
//        delegate('set');
        delegate('setVolume');
        delegate('setGain');
        //delegate('upload');

        GreedySpeech.set = function () {
            recorder.set();
        }

        GreedySpeech.stopPlayRecord = function () {
            recorder.stopPlayRecord();
        }

        GreedySpeech.playAudio = function (url) {
            recorder.playAudio(url);
        }

        GreedySpeech.playRecord = function () {
            recorder.playRecord();
        }

        GreedySpeech.startRecord = function (onSuccess, onError) {
            GreedySpeech.startRecordCallback = onSuccess;
            GreedySpeech.startRecordErrorCallback = onError;
            recorder.startRecord("GreedySpeech.startRecordCallback", "GreedySpeech.startRecordErrorCallback");
        }

        GreedySpeech.stopRecord = function (onSuccess) {
            GreedySpeech.stopRecordCallback = onSuccess;
            recorder.stopRecord("GreedySpeech.stopRecordCallback");
        }

        GreedySpeech.upload = function (content, onSuccess) {
            var q = content ? GreedySpeech.options.uploadUrl + "?q=" + encodeURIComponent(content) : GreedySpeech.options.uploadUrl;
            GreedySpeech.uploadCallback = onSuccess;
            recorder.upload(q, GreedySpeech.options.format, "GreedySpeech.uploadCallback");
        }

        GreedySpeech.show = function () {
            var container = document.getElementById(GreedySpeech.options.id);
            container.style.zIndex = 50;
//            recorder.style.visibility = "visible";
        }

        GreedySpeech.hide = function () {
//            recorder.style.visibility = "hidden";
            var container = document.getElementById(GreedySpeech.options.id);
            container.style.zIndex = -50;
        }
    }

    initAPI();
}