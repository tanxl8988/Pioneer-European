//
//  APKDVRInterface.h
//  DVRForRemoteControl
//
//  Created by Cong on 15-5-13.
//  Copyright (c) 2015年 Apical. All rights reserved.
//

#ifndef                                                               DVRForRemoteControl_APKDVRInterface_h
#define                                                               DVRForRemoteControl_APKDVRInterface_h
#define ap                                                            @"1122"
/*
*                                                                     文件默认目录
 */
#define AMBAKeyDefaultDirectory                                       @"/tmp/fuse_d/DCIM/100MEDIA"

/*
*                                                                     JSON格式的key
 */
#define AMBAKeyToken                                                  @"token"
#define AMBAKeyMSGID                                                  @"msg_id"
#define AMBAKeyType                                                   @"type"
#define AMBAKeyParam                                                  @"param"
#define AMBAKeyReturnValue                                            @"rval"
#define AMBAKeySettable                                               @"settable"
#define AMBAKeyReadOnly                                               @"readonly"
#define AMBAKeyLogo                                                   @"logo"
#define AMBAKeyPWD                                                    @"pwd"
#define AMBAKeyListing                                                @"listing"
#define AMBAKeyFetchSize                                              @"fetch_size"
#define AMBAKeyOffset                                                 @"offset"
#define AMBAKeyREMSize                                                @"rem_size"
#define AMBAKeyAmount                                                 @"Amount"
#define AMBAKeyListing                                                @"listing"


//device info
#define AMBAKeyDeviceInfoBrand                                        @"brand"
#define AMBAKeyDeviceInfoModel                                        @"model"
#define AMBAKeyDeviceInfoAPIVersion                                   @"api_ver"
#define AMBAKeyDeviceInfoFWVer                                        @"fw_ver"
#define AMBAKeyDeviceInfoAppType                                      @"app_type"
//media info
#define AMBAKeyMD5SUM                                                 @"md5sum"
#define AMBAKeyThumbFile                                              @"thumb_file"
#define AMBAKeySize                                                   @"size"
#define AMBAKeyDate                                                   @"date"
#define AMBAKeyResolution                                             @"resolution"
#define AMBAKeyDuration                                               @"duration"
#define AMBAKeyMediaType                                              @"media_type"

//files
#define APKKeyPhotoFile                                               @"photo"
#define APKKeyVideoFile                                               @"video"
#define APKKeyEventFile                                               @"event"
#define APKKeySecurityFile                                            @"parking"
#define APKKeyFileName                                                @"filename"

//settings
#define APKKeyClipDuration                                           @"clip_duration"
#define APKKeyVideoRes                                               @"Apk_video_res"
#define APKKeyTimeAsync                                              @"Apk_time_sync"
#define APKKeyFW                                                     @"Apk_fw"


/*
* msg_id                                                              命令序号
 */

// 图片记录文件
#define MSGID_AMBA_GET_PHOTOS_RECORD_FILE_PATH  0x08000000 +          3

// 记录图片
#define MSGID_AMBA_DOWNLOAD_A_RECORD_PHOTO_FILE_SUCCESS  0x08000000 + 1
#define MSGID_AMBA_DOWNLOAD_A_RECORD_PHOTO_FILE_FAILURE  0x08000000 + 2

// system
#define MSGID_AMBA_GET_SETTING                                        1
#define MSGID_AMBA_SET_SETTING                                        2
#define MSGID_AMBA_GET_ALL_CURRENT_SETTINGS                           3
#define MSGID_AMBA_FORMAT                                             4
#define MSGID_AMBA_GET_SPACE                                          5
#define MSGID_AMBA_GET_NUMB_FILES                                     6
#define MSGID_AMBA_NOTIFICATION                                       7
#define MSGID_AMBA_BURNIN_FW                                          8
#define MSGID_AMBA_GET_SINGLE_SETTING_OPTIONS                         9
#define MSGID_AMBA_PUT_GPS_INFO                                       10
#define MSGID_AMBA_GET_DEVICEINFO                                     11
#define MSGID_AMBA_POWER_MANAGE                                       12
#define MSGID_AMBA_GET_BATTERY_LEVEL                                  13
#define MSGID_AMBA_DIGITAL_ZOOM                                       14
#define MSGID_AMBA_DIGITAL_ZOOM_INFO                                  15
#define MSGID_AMBA_CHANGE_BITRATE                                     16

// Session Controls
#define MSGID_AMBA_START_SESSION                                      257
#define MSGID_AMBA_STOP_SESSION                                       258
#define MSGID_AMBA_RESETVF                                            259
#define MSGID_AMBA_STOP_VF                                            260
//Video Commands
#define MSGID_AMBA_RECORD_START                                       513
#define MSGID_AMBA_RECORD_STOP                                        514
#define MSGID_AMBA_GET_RECORD_TIME                                    515
#define MSGID_AMBA_FORCE_SPLIT                                        516
//Photo Commands
#define MSGID_AMBA_TAKE_PHOTO                                         769
#define MSGID_CONTINUE_BURST_COMPLETE                                 7                                    //特别值，此命令无token
#define MSGID_AMBA_CONTINUE_CAPTURE_STOP                              770
//File System Commands
#define MSGID_AMBA_DEL_FILE                                           1281
#define MSGID_AMBA_LS                                                 1282
#define MSGID_AMBA_CD                                                 1283
#define MSGID_AMBA_PWD                                                1284
#define MSGID_AMBA_GET_FILE                                           1285

#define MSGID_AMBA_PUT_FILE                                           1286
#define MSGID_AMBA_CANCEL_GET_FILE                                    1287
//WiFi Commands
#define MSGID_AMBA_MODIFY_WIFI_SETTING                                1538
#define MSGID_AMBA_WIFI_RESTART                                       1537
#define MSGID_AMBA_STOP_WIFI                                          1540
#define MSGID_AMBA_START_WIFI                                         1541
#define MSGID_AMBA_GET_WIFI_SETTING                                   1539

//Media Commands
#define MSGID_AMBA_GET_THUMB                                          1025
#define MSGID_AMBA_GET_MEDIAINFO                                      1026
#define MSGID_AMBA_SET_MEDIA_ATTRIBUTE                                1027
//Query Commands
#define MSGID_AMBA_QUERY_SESSION_HOLDER                               1793

///*
// * 命令类型
// */
//System Commands
#define AMBATypeAppStatus                                             @"app_status"
#define AMBATypeCameraClock                                           @"camera_clock"
#define AMBATypeMultiChannel                                          @"multi_channel"
#define AMBATypePhotoCaptureMode                                      @"photo_capture_mode"
#define AMBATypePhotoQuqlity                                          @"photo_quality"
#define AMBATypePhotoStamp                                            @"photo_stamp"
#define AMBATypeSTD_DEF_Video                                         @"std_def_video"
#define AMBATypeStreamType                                            @"dual_streaming"
#define AMBATypePhotoLog                                              @"photo_log"
#define AMBATypePhotoLogInterval                                      @"photo_log_interval"
#define AMBATypeVideoLog                                              @"video_log"
#define AMBATypeVideoLogInterval                                      @"video_log_interval"
#define AMBATypeVideoLogDuration                                      @"video_log_duration"
#define AMBATypeTimelapsePhoto                                        @"timelapse_photo"
#define AMBATypeTimelapsePhotoInterval                                @"timelapse_photo_interval"
#define AMBATypeVideoQuality                                          @"video_quality"
#define AMBATypeVideoResolution                                       @"video_resolution"
#define AMBATypeStreamWhileRecord                                     @"stream_while_record"
#define AMBATypeVideoWDR                                              @"video_WDR"
#define AMBATypeVideoStamp                                            @"video_stamp"
#define AMBATypeEXT_GPS                                               @"ext_gps"
#define AMBATypePhotoSize                                             @"photo_size"
#define AMBATypeEventDir                                              @"event_dir"
#define AMBATypeTotalSpace                                            @"total"
#define AMBATypeFreeSpace                                             @"free"
#define AMBATypeStreamOutType                                         @"stream_out_type"
//Media
#define AMBATypeThumb                                                 @"thumb"
#define AMBATypeIDR                                                   @"IDR"
#define AMBATypeFullView                                              @"Fullview"
#define AMBAMediaThumbFile                                            @"thumb_file"
#define AMBAMediaDate                                                 @"date"
#define AMBAMediaResolution                                           @"resolution"
#define AMBAMediaDuration                                             @"duration"
#define AMBAMediaType                                                 @"media_type"


// App_status值
#define AMBAValueAppStatusRecord                                      @"record"
//
////Notification
#define AMBATypeConnectToPC                                           @"camera_connect_to_pc"
#define AMBATypeCaptureMode                                           @"capture_mode"
#define AMBATypeDisconnectHDMI                                        @"disconnect_HDMI"
#define AMBATypeDisconnectShutdown                                    @"disconnect_shutdown"
#define AMBATypeFW_UpgradeComplete                                    @"fw_upgrade_complete"
#define AMBATypeLowBatteryWarning                                     @"low_battery_warning"
#define AMBATypeLowStorageWarning                                     @"low_storage_warning"
#define AMBATypePhotoTaken                                            @"photo_taken"
#define AMBATypeStartingVideoRecord                                   @"starting_video_record"
#define AMBATypeTimelapsePhotoStatus                                  @"timelapse_photo_status"
#define AMBATypeVideoRecordComplete                                   @"video_record_complete"
#define AMBATypeDVRInterruptVf_stop                                   @"vf_stop"
#define AMBATypeGetFileComplete                                       @"get_file_complete"
#define AMBAAddNewFile                                                @"File_Added"
#define AMBARemovedNewFile                                            @"File_Reovmed"
#define AMBAStorageChannel                                            @"Storage Channel"

//Notification param
#define AMBAParamBytesSent  @"bytes                                   sent"
#define AMBAParamMD5SUM                                               @"md5sum"
//⚠️新添加的
#define AMBATypeSmart_rf_Send_Picture                                 @"smart_rf_send_picture"

/*
*                                                                     命令参数(type)
 */

/*
*                                                                     命令正确响应
 */
#define AMBA_CORRET_RREUTN                                            0
/*
*                                                                     响应错误类型
 */
#define AMBA_ERROR_UNKNOWN_ERROR                                      -1
#define AMBA_ERROR_SESSION_START_FAIL                                 3
#define AMBA_ERROR_INVALID_TOKEN                                      -4
#define AMBA_ERROR_REACH_MAX_CLNT                                     -5
#define AMBA_ERROR_JSON_PACKAGE_ERROR                                 -7
#define AMBA_ERROR_JSON_PACKAGE_TIMEOUT                               -8
#define AMBA_ERROR_JSON_SYNTAX_ERROR                                  -9
#define AMBA_ERROR_INVALID_OPTION_VALUE                               -13
#define AMBA_ERROR_INVALID_OPERATION                                  -14
#define AMBA_ERROR_HDMI_INSERTED                                      -16
#define AMBA_ERROR_NO_MORE_SPACE                                      -17
#define AMBA_ERROR_CARD_PROTECTED                                     -18
#define AMBA_ERROR_NO_MORE_MEMORY                                     -19
#define AMBA_ERROR_PIV_NOT_ALLOWED                                    -20
#define AMBA_ERROR_SYSTEM_BUSY                                        -21
#define AMBA_ERROR_APP_NOT_READY                                      -22
#define AMBA_ERROR_OPERATION_UNSUPPORTED                              -23
#define AMBA_ERROR_INVALID_TYPE                                       -24
#define AMBA_ERROR_INVALID_PARAM                                      -25
#define AMBA_ERROR_INVALID_PATH                                       -26

//自定义错误类型]
#define APK_ERROR_TIME_OUT                                             -100
#define APK_ERROR_DVR_BUSY                                             -101
#define APK_ERROR_DVR_LOSE_CONNECT                                     -102
#define APK_ERROR_BROKEN_SD_CARD                                       -126
#define APK_ERROR_NO_SD_CARD                                           -125

//自定义命令
#define APK_AMBA_START_MSG                                            (0x08000000)
#define APK_AMBA_SET_AP_SSID_AND_PASSWD                               (APK_AMBA_START_MSG+10)
#define APK_AMBA_SET_AP_SSID                                          (APK_AMBA_START_MSG+11)              //设置 名称
#define APK_AMBA_SET_AP_PASSWD                                        (APK_AMBA_START_MSG+12)              //设置密码
#define APK_AMBA_DELETE_MICRO_VIDEO                                   (APK_AMBA_START_MSG+13)
#define APK_AMBA_GET_SD_STATUS                                        (APK_AMBA_START_MSG+14)
#define APK_AMBA_GET_NORMAL_FILE_LIST                                 (APK_AMBA_START_MSG+15)
#define APK_AMBA_GET_EVENT_FILE_LIST                                  (APK_AMBA_START_MSG+16)
#define APK_AMBA_GET_PHOTO_FILE_LIST                                  (APK_AMBA_START_MSG+17)
#define APK_AMBA_GET_MICRO_FILE_LIST                                  (APK_AMBA_START_MSG+18)
//开始下载固件，发生该命令后手机端开始往sd卡写文件
#define APK_AMBA_START_UPDATE_FIRMWARE                                (APK_AMBA_START_MSG+19)
//dvr写固件更新完成，dvr收到该命令后重启
#define APK_AMBA_START_UPDATE_FIRMWARE_DONE                           (APK_AMBA_START_MSG+20)

#define APK_AMBA_GET_GPS_TRACK_LIST                                    (APK_AMBA_START_MSG+21)//获取GPS文件列表

//将wifi  切换到STA  模式
#define APK_AMBA_SWITCH_WIFI_2_STA_MODE					(APK_AMBA_START_MSG+23)//将WIFI  切换到STA  模式
#define APK_AMBA_SWITCH_WIFI_2_AP_MODE					(APK_AMBA_START_MSG+24)//将WIFI  切换到AP  模式
//手机APP  心跳通知-- 手机APP  在连接上DVR  之后必须每隔5  秒向DVR传递一次心跳
#define APK_AMBA_HEART_NOTIFY							(APK_AMBA_START_MSG+25)//手机APP 的心跳通知
//车道重新校正
#define APK_AMBA_ADAS_LANE_RE_CALIB						(APK_AMBA_START_MSG+26)
//恢复出厂设置
#define APK_AMBA_RESTORE_DEFAULT	                    (APK_AMBA_START_MSG+27)

//A12
#define APK_AMBA_GET_FILE_LIST                          268435458
#define APK_AMBA_NONE                                   1000000
#define AMBA_GET_ALL_CURRENT_SETTINGS                   0x10000800
#define APK_AMBA_GET_SD_CARD_INFO                       268435459
#define APK_AMBA_CAPTURE_EVENT                          268435461


#endif
