//angular.element("document").ready(function () {
angular.module("greedySlideButton", [])
    .directive("greedySlideButton", ['$window', '$rootScope', '$document', function ($window, $rootScope, $document) {
        return{
            replace: true,
            restrict: 'E',
            link: function ($scope, $element, $attrs) {
                var startX = 0;
                var lastX = 125;
                var min = 0;
                var max = 255;
                $scope.slideNum = 125;
                $scope.slideNumRate = $scope.slideNum / max * 10;
                $element.bind('mousedown', function (event) {
                    // Prevent default dragging of selected content
                    startX = event.pageX;
                    console.log("mousedown:" + startX);
                    event.preventDefault();
//                    startY = event.pageY - y;
                    $document.bind('mousemove', mousemove);
                    $document.bind('mouseup', mouseup);
                });

                function mousemove(event) {
                    $scope.slideNum = lastX + event.pageX - startX;
                    if ($scope.slideNum > max) {
                        $scope.slideNum = max;
                    } else if ($scope.slideNum <= min) {
                        $scope.slideNum = min;
                    }
                    if (!$scope.$$phase) {
                        $scope.slideNumRate = $scope.slideNum / max;
                        $scope.$apply();
                    }
                }

                function mouseup(event) {
                    lastX = $scope.slideNum;
                    startX = event.pageX;
                    console.log("mouseup:" + startX);
                    $document.unbind('mousemove', mousemove);
                    $document.unbind('mouseup', mouseup);
                }
            },
            template: '<div class="scheduleSlider" ng-style="{ left: (slideNum-1) + \'px\' }"></div>'
        };
    }]);

angular.module("greedySlide", ["greedySlideButton"])
    .directive("greedySlide", ['$window', '$rootScope', function ($window, $rootScope) {
        return {
            replace: true,
            restrict: 'E',
            template: '<div class="fr schedulebox">'
                + '<div class="scheduleBg"></div>'
                + '<!-- 灰色的背景 -->'
                + '<div class="scheduleUpper" ng-style="{width: slideNum +\'px\'}"></div>'
                + '<!-- 黑色的进度，范围是0px - 260px 也可以用百分比 -->'
                + '<!-- 根据滑块位置 计算进度条的公式为：滑块left值+1px 即：width:51px=50px+1px -->'
                + '<greedy-Slide-Button></greedy-Slide-Button>'
//                + '<div class="scheduleSlider" style="left:{{260*slideNum/100-1}}px;"></div>'
                + '<!-- 滑块宽度是10px，需定义滑块初始位置 范围是-1px - 259px  原因：若两者值相等，则会留有空隙，因为是圆角 -->'
                + '<div class="clearfix scheduleTips">'
                + '<div class="fl">Min</div>'
                + '<div class="fr">Max</div>'
                + '</div>'
                + '</div>'
        };
    }]);

angular.module("greedyProgress", [])
    .directive("greedyProgress", ['$window', '$rootScope', function ($window, $rootScope) {
        return {
            replace: true,
            restrict: 'E',
            template: '<div class="fr schedulebox"><div class="scheduleBg"></div>' +
                '<!-- 灰色的背景 --><div class="scheduleUpper" ng-style="{width:progressCount+\'%\'}"></div>' +
                '<div class="scheduleTips">{{info}}</div>' +
                '<!-- 黑色的进度，范围是0px - 260px 也可以用百分比 --></div>'
        };
    }])
    .provider("greedyProgress.provider", function () {
        'use strict';

        this.$get = ['$rootScope', '$timeout', function ($scope, $timeout) {
            var intervalId = 0;
            var totalTime = 10000;//总时长
            var intervalTime = 1000;//间隔时间 ms
            var currentCount = 0;//当前计数的值，表示第几次触发
            var currentTime = 0;
            return {
                start: function (fnStart, fnStop) {
                    var self = this;
                    var intFunc = function () {
                        if (isNaN(currentCount) || currentTime >= totalTime) {
                            fnStop();
                            self.reset();
                            $timeout.cancel(intervalId);
                        } else {
                            currentCount++;
                            currentTime = currentCount * intervalTime;
//                            console.log(currentTime);
                            self.updateCount(currentTime / totalTime * 100);
                            intervalId = $timeout(intFunc, intervalTime);
                        }
                    };
                    intervalId = $timeout(intFunc, intervalTime);
                    fnStart();
                },
                updateCount: function (newCount) {
                    $scope.progressCount = newCount;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                },
                reset: function () {
                    var self = this;
                    $timeout.cancel(intervalId);
                    currentCount = 0;
                    currentTime = 0;
                    self.updateCount(currentCount);
                }
            };
        }];
    });

angular.module('equipmenttest', ["greedyProgress", "greedySlide"])
    .factory('stepSvc', ['$location', function ($loc) {
        return {
            next: function (step) {
                $loc.path('/' + step);
            }
        };
    }])
    .controller('step1Ctrl', ['$scope', 'stepSvc', function ($scope, stepSvc) {
        $scope.next = function () {
            stepSvc.next("step2");
        };
    }])
    .controller('step2Ctrl', ['$scope', 'stepSvc', '$timeout', function ($scope, stepSvc, $timeout) {
        GreedySpeech.setup({
            id: "SpeechContainer",
            uploadUrl: "http://localhost:13810/home/audio",
            format: "audio/x-wav",
            rate: 44,
            channels: 1,
            bit: 16
        });
        GreedySpeech.hide();
        $scope.next = function () {
            GreedySpeech.hide();
            $timeout(function () {
                stepSvc.next("step3");
            }, 100);
        };
        $scope.setFlash = function () {
            GreedySpeech.show();
            $timeout(GreedySpeech.set, 100);
        };
    }])
    .controller('step3Ctrl', ['$scope', 'stepSvc', 'greedyProgress.provider', function ($scope, stepSvc, provider) {
        provider.reset();
        $scope.flag = 0;
        $scope.cancel = function () {
            $scope.flag = 2;
        };
        $scope.play = function () {
            if ($scope.flag === 0 || $scope.flag === 2) {
                provider.reset();
                provider.start(function () {
                        if ($scope.flag === 0 || $scope.flag === 2) {
                            $scope.flag += 1;
                        }
                        GreedySpeech.stopPlayRecord();
                        GreedySpeech.playAudio("http://greedyint-1test.oss.aliyuncs.com/XTHZ2/20130816133117-7bf2e.mp3");
                    },
                    function () {
                        $scope.flag = 4;
                        GreedySpeech.stopPlayRecord();
                    });
            }
        };
        $scope.next = function () {
            stepSvc.next("step4");
        };
        $scope.$watch("slideNumRate", function (newValue, oldValue) {
//            console.log(newValue);
            GreedySpeech.setVolume(newValue);
        });
    }])
    .controller('step4Ctrl', ['$scope', 'stepSvc', 'greedyProgress.provider', '$timeout', function ($scope, stepSvc, provider, $timeout) {
        provider.reset();
        $scope.flag = 0;
        $scope.info = "";
        $scope.cancel = function () {
            $scope.flag = 0;
        };
        $scope.record = function () {
            if ($scope.flag === 0) {
                provider.reset();
                provider.start(function () {
                        $scope.flag = 1;
                        $scope.info = "Recording...";
                        GreedySpeech.stopRecord();
                        GreedySpeech.startRecord("", function () {
                            stepSvc.next("steperror");
                        });
                    },
                    function () {
                        $scope.flag = 2;
                        $timeout(function () {
                            GreedySpeech.stopRecord(function () {
                                provider.reset();
                                provider.start(function () {
                                        $scope.flag = 3;
                                        $scope.info = "Playing...";
                                        GreedySpeech.playRecord();
                                    },
                                    function () {
                                        $scope.flag = 4;
                                        $scope.info = "";
                                        GreedySpeech.stopPlayRecord();
                                    });
                            });
                        }, 50);
                    });
            }
        };
        $scope.next = function () {
            stepSvc.next("step5");
        };
        $scope.$watch("slideNumRate", function (newValue, oldValue) {
            GreedySpeech.setGain(newValue * 100);
        });
    }])
    .controller('step5Ctrl', ['$scope', 'stepSvc', function ($scope, stepSvc) {
        $scope.next = function () {

        }
    }])
    .controller('stepErrorCtrl', ['$scope', 'stepSvc', function ($scope, stepSvc) {
        $scope.next = function () {
            stepSvc.next("step2");
        };
    }])
    .config(function ($routeProvider) {
        $routeProvider
            .when('/', {controller: 'step1Ctrl', templateUrl: 'step1.html'})
            .when('/step2', {controller: 'step2Ctrl', templateUrl: 'step2.html'})
            .when('/step3', {controller: 'step3Ctrl', templateUrl: 'step3.html'})
            .when('/step4', {controller: 'step4Ctrl', templateUrl: 'step4.html'})
            .when('/step5', {controller: 'step5Ctrl', templateUrl: 'step5.html'})
            .when('/steperror', {controller: 'stepErrorCtrl', templateUrl: 'steperror.html'})
    });
//});