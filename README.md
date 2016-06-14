# iOS随心播
因GitHub有文件大小限制，以及微云限制，现将IMSDK以及AVSDK上传到腾讯云COS上。
更新时，请到对应的地址进行更新，并添加到工程下面对应的目录下

IMSDK : http://tcshowsdks-10022853.file.myqcloud.com/20160608/IMSDK.zip 下载后解压，然后再放至对应放到工程目录  TCShow/TCAdapter/TIMAdapter/Framework/IMSDK

AVSDK : http://tcshowsdks-10022853.file.myqcloud.com/20160608/Libs.zip  下载后解压，然后再放至对应放到工程目录  TCShow/TCAdapter/TCAVIMAdapter/Libs

新版本随心播经过重构，完善了功能，处理了大量的异常情况，请开发者在编码过程中注意，异常情况包括如下：

1.退后台恢复 ：iOS后台进程不被杀掉，可正常恢复，画面/声音正常；

2.闹钟 ：iOS直播过程中有闹钟，关闭闹钟返回直播，观众和主播画面/声音正常

3.播放音频中断：使用QQ音乐后台播放，再进入，声音正常

4.后台播放视频中断：优酷播放视频，然后再进随心播，正常

5.视频通话中断 ：中断后可正常恢复直播

6.语音电话中断：ＱＱ语音电话，进入直播正常

7.电话中断: 手机通话中断，前台挂接电话，后台挂接电话均正常

8.iOS杀掉进程后，<90S,再创建直播，在直播间的观众可以正常恢复声音/画面

9.iOS杀掉进程后，>90S，后台自动关闭房间

##随心播的Spear的配置
因随心播的参数配置较高，因此对主播上行带宽有要求
现提供随心播中主播配置：
![spear配置](https://raw.githubusercontent.com/zhaoyang21cn/iOS_Suixinbo/master/LiveHost.jpeg)
观众配置：
![spear配置](https://raw.githubusercontent.com/zhaoyang21cn/iOS_Suixinbo/master/NormalGuest.jpeg)
互动观众配置：
![spear配置](https://raw.githubusercontent.com/zhaoyang21cn/iOS_Suixinbo/master/InteractUser.jpeg)
