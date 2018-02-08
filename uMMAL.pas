unit uMMAL;

{$mode objfpc}{$H+}
(*
Copyright (c) 2012, Broadcom Europe Ltd
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

interface

uses
  Classes, SysUtils, VC4;

const
  MMAL_VERSION_MAJOR                       = 0;
  MMAL_VERSION_MINOR                       = 1;
  MMAL_VERSION                             = (MMAL_VERSION_MAJOR shl 16) or MMAL_VERSION_MINOR;

  MMAL_FALSE                               = 0;
  MMAL_TRUE                                = 1;

  MMAL_DRIVER_BUFFER_SIZE                  = 32;

  MMAL_BUFFER_HEADER_FLAG_EOS              = 1 shl 0;
  {* Signals that the start of the current payload starts a frame  }
  MMAL_BUFFER_HEADER_FLAG_FRAME_START      = 1 shl 1;
  {* Signals that the end of the current payload ends a frame  }
  MMAL_BUFFER_HEADER_FLAG_FRAME_END        = 1 shl 2;
  {* Signals that the current payload contains only complete frames (1 or more)  }
  MMAL_BUFFER_HEADER_FLAG_FRAME            = MMAL_BUFFER_HEADER_FLAG_FRAME_START or MMAL_BUFFER_HEADER_FLAG_FRAME_END;
  {* Signals that the current payload is a keyframe (i.e. self decodable)  }
  MMAL_BUFFER_HEADER_FLAG_KEYFRAME         = 1 shl 3;
  {* Signals a discontinuity in the stream of data (e.g. after a seek).
  * Can be used for instance by a decoder to reset its state  }
  MMAL_BUFFER_HEADER_FLAG_DISCONTINUITY    = 1 shl 4;
  {* Signals a buffer containing some kind of config data for the component
  * (e.g. codec config data)  }
  MMAL_BUFFER_HEADER_FLAG_CONFIG           = 1 shl 5;
  {* Signals an encrypted payload  }
  MMAL_BUFFER_HEADER_FLAG_ENCRYPTED        = 1 shl 6;
  {* Signals a buffer containing side information  }
  MMAL_BUFFER_HEADER_FLAG_CODECSIDEINFO    = 1 shl 7;
  {* Signals a buffer which is the snapshot/postview image from a stills capture  }
  MMAL_BUFFER_HEADER_FLAGS_SNAPSHOT        = 1 shl 8;
  {* Signals a buffer which contains data known to be corrupted  }
  MMAL_BUFFER_HEADER_FLAG_CORRUPTED        = 1 shl 9;
  {* Signals that a buffer failed to be transmitted  }
  MMAL_BUFFER_HEADER_FLAG_TRANSMISSION_FAILED = 1 shl 10;
  {* Signals the output buffer won't be used, just update reference frames  }
  MMAL_BUFFER_HEADER_FLAG_DECODEONLY       = 1 shl 11;
  {* User flags - can be passed in and will get returned  }
  MMAL_BUFFER_HEADER_FLAG_USER0            = 1 shl 28;
  MMAL_BUFFER_HEADER_FLAG_USER1            = 1 shl 29;
  MMAL_BUFFER_HEADER_FLAG_USER2            = 1 shl 30;
  MMAL_BUFFER_HEADER_FLAG_USER3            = 1 shl 31;

  MMAL_BUFFER_HEADER_FLAG_FORMAT_SPECIFIC_START = 1 shl 16;
  {* Signals an interlaced video frame  }
  MMAL_BUFFER_HEADER_VIDEO_FLAG_INTERLACED = MMAL_BUFFER_HEADER_FLAG_FORMAT_SPECIFIC_START shl 0;
  {* Signals that the top field of the current interlaced frame should be displayed first  }
  MMAL_BUFFER_HEADER_VIDEO_FLAG_TOP_FIELD_FIRST = MMAL_BUFFER_HEADER_FLAG_FORMAT_SPECIFIC_START shl 1;
  {* Signals that the buffer should be displayed on external display if attached.  }
  MMAL_BUFFER_HEADER_VIDEO_FLAG_DISPLAY_EXTERNAL = MMAL_BUFFER_HEADER_FLAG_FORMAT_SPECIFIC_START shl 3;
  {* Signals that contents of the buffer requires copy protection.  }
  MMAL_BUFFER_HEADER_VIDEO_FLAG_PROTECTED  = MMAL_BUFFER_HEADER_FLAG_FORMAT_SPECIFIC_START shl 4;

  MMAL_SUCCESS                             = 0;
  MMAL_ENOMEM                              = 1;
  MMAL_ENOSPC                              = 2;
  MMAL_EINVAL                              = 3;
  MMAL_ENOSYS                              = 4;
  MMAL_ENOENT                              = 5;
  MMAL_ENXIO                               = 6;
  MMAL_EIO                                 = 7;
  MMAL_ESPIPE                              = 8;
  MMAL_ECORRUPT                            = 9;
  MMAL_ENOTREADY                           = 10;
  MMAL_ECONFIG                             = 11;
  MMAL_EISCONN                             = 12;
  MMAL_ENOTCONN                            = 13;
  MMAL_EAGAIN                              = 14;
  MMAL_EFAULT                              = 15;
  MMAL_STATUS_MAX                          = $7FFFFFFF;

  MMAL_ES_TYPE_UNKNOWN                     = 0;
  MMAL_ES_TYPE_CONTROL                     = 1;
  MMAL_ES_TYPE_AUDIO                       = 2;
  MMAL_ES_TYPE_VIDEO                       = 3;
  MMAL_ES_TYPE_SUBPICTURE                  = 4;

  MMAL_ES_FORMAT_FLAG_FRAMED               = $1;
  MMAL_ENCODING_UNKNOWN                    = 0;
  MMAL_ENCODING_VARIANT_DEFAULT            = 0;

  MMAL_ES_FORMAT_COMPARE_FLAG_TYPE         = $01;
  MMAL_ES_FORMAT_COMPARE_FLAG_ENCODING     = $02;
  MMAL_ES_FORMAT_COMPARE_FLAG_BITRATE      = $04;
  MMAL_ES_FORMAT_COMPARE_FLAG_FLAGS        = $08;
  MMAL_ES_FORMAT_COMPARE_FLAG_EXTRADATA    = $10;
  MMAL_ES_FORMAT_COMPARE_FLAG_VIDEO_RESOLUTION = $0100;
  MMAL_ES_FORMAT_COMPARE_FLAG_VIDEO_CROPPING = $0200;
  MMAL_ES_FORMAT_COMPARE_FLAG_VIDEO_FRAME_RATE = $0400;
  MMAL_ES_FORMAT_COMPARE_FLAG_VIDEO_ASPECT_RATIO = $0800;
  MMAL_ES_FORMAT_COMPARE_FLAG_VIDEO_COLOR_SPACE = $1000;
  MMAL_ES_FORMAT_COMPARE_FLAG_ES_OTHER     = $10000000;

  MMAL_PORT_TYPE_UNKNOWN                   = 0;
  MMAL_PORT_TYPE_CONTROL                   = 1;
  MMAL_PORT_TYPE_INPUT                     = 2;
  MMAL_PORT_TYPE_OUTPUT                    = 3;
  MMAL_PORT_TYPE_CLOCK                     = 4;
  MMAL_PORT_TYPE_INVALID                   = $FFFFFFFF;
  {* The port wants to allocate the buffer payloads. This signals a preference that
   * payload allocation should be done on this port for efficiency reasons.  }
  MMAL_PORT_CAPABILITY_PASSTHROUGH         = $01;
  {* The port supports format change events. This applies to input ports and is used
   * to let the client know whether the port supports being reconfigured via a format
   * change event (i.e. without having to disable the port).  }
  MMAL_PORT_CAPABILITY_ALLOCATION          = $02;
  MMAL_PORT_CAPABILITY_SUPPORTS_EVENT_FORMAT_CHANGE = $04;

  MMAL_FIXED_16_16_ONE                     = 1 shl 16;


  MMAL_PARAMETER_GROUP_COMMON              = 0 shl 16;
  MMAL_PARAMETER_GROUP_CAMERA              = 1 shl 16;
  MMAL_PARAMETER_GROUP_VIDEO               = 2 shl 16;
  MMAL_PARAMETER_GROUP_AUDIO               = 3 shl 16;
  MMAL_PARAMETER_GROUP_CLOCK               = 4 shl 16;
  MMAL_PARAMETER_GROUP_MIRACAST            = 5 shl 16;


  MMAL_CORE_STATS_RX                       = 0;
  MMAL_CORE_STATS_TX                       = 1;
  MMAL_CORE_STATS_MAX                      = $7fffffff;

  MMAL_PARAM_MIRROR_NONE                   = 0;
  MMAL_PARAM_MIRROR_VERTICAL               = 1;
  MMAL_PARAM_MIRROR_HORIZONTAL             = 2;
  MMAL_PARAM_MIRROR_BOTH                   = 3;

  MMAL_PARAM_EXPOSUREMODE_OFF              = 0;
  MMAL_PARAM_EXPOSUREMODE_AUTO             = 1;
  MMAL_PARAM_EXPOSUREMODE_NIGHT            = 2;
  MMAL_PARAM_EXPOSUREMODE_NIGHTPREVIEW     = 3;
  MMAL_PARAM_EXPOSUREMODE_BACKLIGHT        = 4;
  MMAL_PARAM_EXPOSUREMODE_SPOTLIGHT        = 5;
  MMAL_PARAM_EXPOSUREMODE_SPORTS           = 6;
  MMAL_PARAM_EXPOSUREMODE_SNOW             = 7;
  MMAL_PARAM_EXPOSUREMODE_BEACH            = 8;
  MMAL_PARAM_EXPOSUREMODE_VERYLONG         = 9;
  MMAL_PARAM_EXPOSUREMODE_FIXEDFPS         = 10;
  MMAL_PARAM_EXPOSUREMODE_ANTISHAKE        = 11;
  MMAL_PARAM_EXPOSUREMODE_FIREWORKS        = 12;
  MMAL_PARAM_EXPOSUREMODE_MAX              = $7fffffff;

  MMAL_PARAM_EXPOSUREMETERINGMODE_AVERAGE  = 0;
  MMAL_PARAM_EXPOSUREMETERINGMODE_SPOT     = 1;
  MMAL_PARAM_EXPOSUREMETERINGMODE_BACKLIT  = 2;
  MMAL_PARAM_EXPOSUREMETERINGMODE_MATRIX   = 3;
  MMAL_PARAM_EXPOSUREMETERINGMODE_MAX      = $7fffffff;

  MMAL_CONNECTION_FLAG_TUNNELLING          = $1;
  MMAL_CONNECTION_FLAG_ALLOCATION_ON_INPUT = $2;
  MMAL_CONNECTION_FLAG_ALLOCATION_ON_OUTPUT = $4;
  MMAL_CONNECTION_FLAG_KEEP_BUFFER_REQUIREMENTS = $8;
  MMAL_CONNECTION_FLAG_DIRECT              = $10;

  MMAL_PARAMETER_CAMERA_INFO_MAX_CAMERAS   = 4;
  MMAL_PARAMETER_CAMERA_INFO_MAX_FLASHES   = 2;
  MMAL_PARAMETER_CAMERA_INFO_MAX_STR_LEN   = 16;

  MMAL_COMPONENT_DEFAULT_VIDEO_DECODER     = 'ril.video_decode';
  MMAL_COMPONENT_DEFAULT_VIDEO_ENCODER     = 'ril.video_encode';
  MMAL_COMPONENT_DEFAULT_VIDEO_RENDERER    = 'ril.video_render';
  MMAL_COMPONENT_DEFAULT_IMAGE_DECODER     = 'ril.image_decode';
  MMAL_COMPONENT_DEFAULT_IMAGE_ENCODER     = 'ril.image_encode';
  MMAL_COMPONENT_DEFAULT_CAMERA            = 'ril.camera';
  MMAL_COMPONENT_DEFAULT_VIDEO_CONVERTER   = 'video_convert';
  MMAL_COMPONENT_DEFAULT_SPLITTER          = 'splitter';
  MMAL_COMPONENT_DEFAULT_SCHEDULER         = 'scheduler';
  MMAL_COMPONENT_DEFAULT_VIDEO_INJECTER    = 'video_inject';
  MMAL_COMPONENT_DEFAULT_VIDEO_SPLITTER    = 'ril.video_splitter';
  MMAL_COMPONENT_DEFAULT_AUDIO_DECODER     = 'none';
  MMAL_COMPONENT_DEFAULT_AUDIO_RENDERER    =' ril.audio_render' ;
  MMAL_COMPONENT_DEFAULT_MIRACAST          = 'miracast';
  MMAL_COMPONENT_DEFAULT_CLOCK             = 'clock';
  MMAL_COMPONENT_DEFAULT_CAMERA_INFO       = 'camera_info';

type
  // basic types
  uint8_t                                  = uint8;
  Puint8_t                                 = ^uint8_t;
  uint16_t                                 = uint16;
  uint32_t                                 = LongWord;
  int32_t                                  = integer;
  int64_t                                  = int64;
  uint64_t                                 = uint64;
  MMAL_BOOL_T                              = int32_t;
  (* Unsigned 16.16 fixed point value, also known as Q16.16 *)
  MMAL_FIXED_16_16_T                       = uint32_t;
  MMAL_STATUS_T                            = uint32_t;
  MMAL_FOURCC_T                            = uint32_t;
  MMAL_ES_TYPE_T                           = LongWord;
  MMAL_PORT_TYPE_T                         = LongWord;
  MMAL_PARAM_EXPOSUREMETERINGMODE_T        = LongWord;
  MMAL_PARAM_EXPOSUREMODE_T                = LongWord;
  MMAL_PARAM_MIRROR_T                      = LongWord;
  MMAL_CORE_STATS_DIR                      = LongWord;
  VCOS_UNSIGNED                            = LongWord;

// forward definitions

  PMMAL_PORT_T                             = ^MMAL_PORT_T;
  PPMMAL_PORT_T                            = ^PMMAL_PORT_T;

  PMMAL_CLOCK_BUFFER_INFO_T                = ^MMAL_CLOCK_BUFFER_INFO_T;
  PMMAL_CLOCK_DISCONT_THRESHOLD_T          = ^MMAL_CLOCK_DISCONT_THRESHOLD_T;
  PMMAL_CLOCK_EVENT_T                      = ^MMAL_CLOCK_EVENT_T;
  PMMAL_CLOCK_REQUEST_THRESHOLD_T          = ^MMAL_CLOCK_REQUEST_THRESHOLD_T;
  PMMAL_CLOCK_UPDATE_THRESHOLD_T           = ^MMAL_CLOCK_UPDATE_THRESHOLD_T;

  PMMAL_PARAMETER_HEADER_T                 = ^MMAL_PARAMETER_HEADER_T;

  PMMAL_BUFFER_HEADER_T                    = ^MMAL_BUFFER_HEADER_T;
  PPMMAL_BUFFER_HEADER_T                   = ^PMMAL_BUFFER_HEADER_T;
  PMMAL_BUFFER_HEADER_PRIVATE_T            = ^MMAL_BUFFER_HEADER_PRIVATE_T;

  PMMAL_COMPONENT_T                        = ^MMAL_COMPONENT_T;
  PPMMAL_COMPONENT_T                       = ^PMMAL_COMPONENT_T;
  PMMAL_COMPONENT_PRIVATE_T                = ^MMAL_COMPONENT_PRIVATE_T;
  PMMAL_COMPONENT_USERDATA_T               = ^MMAL_COMPONENT_USERDATA_T;

  PMMAL_BUFFER_HEADER_TYPE_SPECIFIC_T      = ^MMAL_BUFFER_HEADER_TYPE_SPECIFIC_T;

  PMMAL_ES_FORMAT_T                        = ^MMAL_ES_FORMAT_T;

  PMMAL_QUEUE_T                            = ^MMAL_QUEUE_T;
  PMMAL_CLOCK_T                            = ^MMAL_CLOCK_T;
  PMMAL_POOL_T                             = ^MMAL_POOL_T;
  PMMAL_CONNECTION_T                       = ^MMAL_CONNECTION_T;
  PPMMAL_CONNECTION_T                      = ^PMMAL_CONNECTION_T;


  {$PACKRECORDS C}

// callbacks
  MMAL_BH_PRE_RELEASE_CB_T                 = function (header : PMMAL_BUFFER_HEADER_T; userdata : pointer) : MMAL_BOOL_T; cdecl;
  MMAL_PORT_BH_CB_T                        = procedure (port : PMMAL_PORT_T; buffer : PMMAL_BUFFER_HEADER_T); cdecl;
  MMAL_PORT_CLOCK_EVENT_CB                 = procedure (port : PMMAL_PORT_T; event : PMMAL_CLOCK_EVENT_T); cdecl;
  MMAL_PORT_CLOCK_REQUEST_CB               = procedure (port : PMMAL_PORT_T; media_time : int64_t; cb_data : pointer); cdecl;
  MMAL_CONNECTION_CALLBACK_T               = procedure (connection : PMMAL_CONNECTION_T); cdecl;

  // records
  MMAL_CORE_STATISTICS_T = record
    buffer_count : uint32_t;        (* Total buffer count on this port *)
    first_buffer_time : uint32_t;   (* Time (us) of first buffer seen on this port *)
    last_buffer_time : uint32_t;    (* Time (us) of most recently buffer on this port *)
    max_delay : uint32_t;           (* Max delay (us) between buffers, ignoring first few frames *)
  end;

  (* Statistics collected by the core on all ports, if enabled in the build. *)
  MMAL_CORE_PORT_STATISTICS_T = record
    rx : MMAL_CORE_STATISTICS_T;
    tx : MMAL_CORE_STATISTICS_T;
  end;

  MMAL_RECT_T = record
    x : int32_t;
    y : int32_t;
    width : int32_t;
    height : int32_t;
  end;

  MMAL_RATIONAL_T = record
    num : int32_t;
    den : int32_t;
  end;

  MMAL_BUFFER_HEADER_PRIVATE_T = record
    pf_pre_release : MMAL_BH_PRE_RELEASE_CB_T;
    pre_release_userdata : pointer;
    pf_release : procedure (header : PMMAL_BUFFER_HEADER_T); cdecl;
    owner : pointer;
    refcount : int32_t;
    reference : PMMAL_BUFFER_HEADER_T;
    pf_payload_free : procedure (payload_context : pointer; payload : pointer); cdecl;
    payload : pointer;
    payload_context : pointer;
    payload_size : uint32_t;
    component_data : pointer;
    payload_handle : pointer;
    driver_area : array [0 .. MMAL_DRIVER_BUFFER_SIZE - 1] of uint8_t;
  end;

  MMAL_BUFFER_HEADER_T = record
    next : PMMAL_BUFFER_HEADER_T;
    priv : PMMAL_BUFFER_HEADER_PRIVATE_T;
    cmd : uint32_t;
    data : Puint8_t;
    alloc_size : uint32_t;
    length : uint32_t;
    offset : uint32_t;
    flags : uint32_t;
    pts : int64_t;
    dts : int64_t;
    _type : PMMAL_BUFFER_HEADER_TYPE_SPECIFIC_T;
    user_data : pointer;
  end;

  MMAL_BUFFER_HEADER_VIDEO_SPECIFIC_T = record
    planes : uint32_t;
    offset : array [0 .. 3] of uint32_t;
    pitch : array [0 .. 3] of uint32_t;
    flags : uint32_t;
  end;

  MMAL_BUFFER_HEADER_TYPE_SPECIFIC_T = record
    case longint of
      0 : ( video : MMAL_BUFFER_HEADER_VIDEO_SPECIFIC_T );
    end;

  MMAL_VIDEO_FORMAT_T = record
    width : uint32_t;
    height : uint32_t;
    crop : MMAL_RECT_T;
    frame_rate : MMAL_RATIONAL_T;
    par : MMAL_RATIONAL_T;
    color_space : MMAL_FOURCC_T;
  end;

  MMAL_AUDIO_FORMAT_T = record
    channels : uint32_t;
    sample_rate : uint32_t;
    bits_per_sample : uint32_t;
    block_align : uint32_t;
  end;

  MMAL_SUBPICTURE_FORMAT_T = record
    x_offset : uint32_t;
    y_offset : uint32_t;
  end;

  MMAL_ES_SPECIFIC_FORMAT_T = record
    case longint of
      0 : ( audio : MMAL_AUDIO_FORMAT_T );
      1 : ( video : MMAL_VIDEO_FORMAT_T );
      2 : ( subpicture : MMAL_SUBPICTURE_FORMAT_T );
    end;

  MMAL_ES_FORMAT_T = record
    _type : MMAL_ES_TYPE_T;
    encoding : MMAL_FOURCC_T;
    encoding_variant : MMAL_FOURCC_T;
    es : ^MMAL_ES_SPECIFIC_FORMAT_T;
    bitrate : uint32_t;
    flags : uint32_t;
    extradata_size : uint32_t;
    extradata : ^uint8_t;
  end;

  MMAL_PORT_PRIVATE_CORE_T = record     // check
  end;

  MMAL_PORT_MODULE_T = record     // check
  end;

  MMAL_PORT_USERDATA_T = record     // check
  end;

  MMAL_PORT_PRIVATE_T = record
    core : ^MMAL_PORT_PRIVATE_CORE_T;
    module : ^MMAL_PORT_MODULE_T;
    clock : ^MMAL_PORT_CLOCK_T;
    pf_set_format : function (port : PMMAL_PORT_T) : MMAL_STATUS_T; cdecl;
    pf_enable : function (port : PMMAL_PORT_T; _para2 : MMAL_PORT_BH_CB_T) : MMAL_STATUS_T; cdecl;
    pf_disable : function (port : PMMAL_PORT_T) : MMAL_STATUS_T;cdecl;
    pf_send : function (port : PMMAL_PORT_T; _para2 : PMMAL_BUFFER_HEADER_T) : MMAL_STATUS_T; cdecl;
    pf_flush : function (port : PMMAL_PORT_T) : MMAL_STATUS_T; cdecl;
    pf_parameter_set : function (port : PMMAL_PORT_T; param : PMMAL_PARAMETER_HEADER_T) : MMAL_STATUS_T; cdecl;
    pf_parameter_get : function (port : PMMAL_PORT_T; param : PMMAL_PARAMETER_HEADER_T) : MMAL_STATUS_T; cdecl;
    pf_connect : function (port : PMMAL_PORT_T; other_port : PMMAL_PORT_T) : MMAL_STATUS_T; cdecl;
    pf_payload_alloc : function (port : PMMAL_PORT_T; payload_size : uint32_t) : Puint8_t; cdecl;
    pf_payload_free : procedure (port : PMMAL_PORT_T; payload : Puint8_t); cdecl;
  end;

  MMAL_PORT_T = record
    priv : ^MMAL_PORT_PRIVATE_T;
    name : ^char;
    _type : MMAL_PORT_TYPE_T;
    index : uint16_t;
    index_all : uint16_t;
    is_enabled : uint32_t;
    format : ^MMAL_ES_FORMAT_T;
    buffer_num_min : uint32_t;
    buffer_size_min : uint32_t;
    buffer_alignment_min : uint32_t;
    buffer_num_recommended : uint32_t;
    buffer_size_recommended : uint32_t;
    buffer_num : uint32_t;
    buffer_size : uint32_t;
    component : ^MMAL_COMPONENT_T;
    userdata : ^MMAL_PORT_USERDATA_T;
    capabilities : uint32_t;
  end;

  MMAL_COMPONENT_PRIVATE_T = record
    {undefined structure}
  end;

  MMAL_COMPONENT_USERDATA_T = record      // check

  end;

  MMAL_COMPONENT_T = record
    priv : PMMAL_COMPONENT_PRIVATE_T;
    userdata : PMMAL_COMPONENT_USERDATA_T;
    name : Pchar;
    is_enabled : uint32_t;
    control : PMMAL_PORT_T;
    input_num : uint32_t;
    input : PPMMAL_PORT_T;
    output_num : uint32_t;
    output : PPMMAL_PORT_T;
    clock_num : uint32_t;
    clock : PPMMAL_PORT_T;
    port_num : uint32_t;
    port : PPMMAL_PORT_T;
    id : uint32_t;
  end;

  MMAL_PARAMETER_HEADER_T = record
    id : uint32_t;
    size : uint32_t;
  end;

  MMAL_PARAMETER_CHANGE_EVENT_REQUEST_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    change_id : uint32_t;
    enable : MMAL_BOOL_T;
  end;

  MMAL_PARAMETER_BUFFER_REQUIREMENTS_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    buffer_num_min : uint32_t;
    buffer_size_min : uint32_t;
    buffer_alignment_min : uint32_t;
    buffer_num_recommended : uint32_t;
    buffer_size_recommended : uint32_t;
  end;

  MMAL_PARAMETER_SEEK_T = record
  end;

  MMAL_PARAMETER_STATISTICS_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    buffer_count : uint32_t;
    frame_count : uint32_t;
    frames_skipped : uint32_t;
    frames_discarded : uint32_t;
    eos_seen : uint32_t;
    maximum_frame_bytes : uint32_t;
    total_bytes : int64_t;
    corrupt_macroblocks : uint32_t;
  end;

  MMAL_PARAMETER_CORE_STATISTICS_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    dir : MMAL_CORE_STATS_DIR;
    reset : MMAL_BOOL_T;
    stats : MMAL_CORE_STATISTICS_T;
  end;

  MMAL_PARAMETER_MEM_USAGE_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    pool_mem_alloc_size : uint32_t;
  end;

  MMAL_PARAMETER_LOGGING_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    set_ : uint32_t;
    clear : uint32_t;
  end;

  MMAL_PARAMETER_THUMBNAIL_CONFIG_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    enable : uint32_t;
    width : uint32_t;
    height : uint32_t;
    quality : uint32_t;
  end;

  MMAL_PARAMETER_EXIF_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    keylen : uint32_t;
    value_offset : uint32_t;
    valuelen : uint32_t;
    data : array[0..0] of uint8_t;
  end;

  MMAL_PARAMETER_EXPOSUREMODE_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : MMAL_PARAM_EXPOSUREMODE_T;
  end;

  MMAL_PARAMETER_UINT64_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : uint64_t;
  end;

  MMAL_PARAMETER_INT64_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : int64_t;
  end;

  MMAL_PARAMETER_UINT32_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : uint32_t;
  end;

  MMAL_PARAMETER_INT32_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : int32_t;
  end;

  MMAL_PARAMETER_RATIONAL_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : MMAL_RATIONAL_T;
  end;

  MMAL_PARAMETER_BOOLEAN_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    enable : MMAL_BOOL_T;
  end;

  MMAL_PARAMETER_STRING_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    str : array [0 .. 0] of char;
  end;

  MMAL_PARAMETER_BYTES_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    data : array [0 .. 0] of uint8_t;
  end;

  MMAL_PARAMETER_SCALEFACTOR_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    scale_x : MMAL_FIXED_16_16_T;
    scale_y : MMAL_FIXED_16_16_T;
  end;

  MMAL_PARAMETER_MIRROR_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    value : MMAL_PARAM_MIRROR_T;
  end;

  MMAL_PARAMETER_URI_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    uri : array[0 .. 0] of char;
  end;

  MMAL_PARAMETER_ENCODING_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    encoding : array [0 .. 0] of uint32_t;
  end;

  MMAL_PARAMETER_FRAME_RATE_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    frame_rate : MMAL_RATIONAL_T;
  end;

  MMAL_PARAMETER_CONFIGFILE_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    file_size : uint32_t;
  end;

  MMAL_PARAMETER_CONFIGFILE_CHUNK_T = record
    hdr : MMAL_PARAMETER_HEADER_T;
    size : uint32_t;
    offset : uint32_t;
    data : array [0 .. 0] of char;
  end;

  MMAL_CLOCK_T = record
    user_data : pointer;
  end;

  MMAL_PORT_CLOCK_T = record
    event_cb : MMAL_PORT_CLOCK_EVENT_CB;
    queue : PMMAL_QUEUE_T;
    clock : PMMAL_CLOCK_T;
    is_reference : MMAL_BOOL_T;
    buffer_info_reporting : MMAL_BOOL_T;
  end;

  MMAL_CLOCK_UPDATE_THRESHOLD_T = record
    threshold_lower : int64_t;
    threshold_upper : int64_t;
  end;

  MMAL_CLOCK_DISCONT_THRESHOLD_T = record
    threshold : int64_t;
    duration : int64_t;
  end;

  MMAL_CLOCK_REQUEST_THRESHOLD_T = record
    threshold : int64_t;
    threshold_enable : MMAL_BOOL_T;
  end;


  MMAL_CLOCK_BUFFER_INFO_T = record
    time_stamp : int64_t;
    arrival_time : uint32_t;
  end;

  MMAL_CLOCK_LATENCY_T = record
    target : int64_t;
    attack_period : int64_t;
    attack_rate : int64_t;
  end;

  MMAL_CLOCK_EVENT_T = record
    id : uint32_t;
    magic : uint32_t;
    buffer : PMMAL_BUFFER_HEADER_T;
    padding0 : uint32_t;
    data : record
      case longint of
        0 : ( enable : MMAL_BOOL_T );
        1 : ( scale : MMAL_RATIONAL_T );
        2 : ( media_time : int64_t );
        3 : ( update_threshold : MMAL_CLOCK_UPDATE_THRESHOLD_T );
        4 : ( discont_threshold : MMAL_CLOCK_DISCONT_THRESHOLD_T );
        5 : ( request_threshold : MMAL_CLOCK_REQUEST_THRESHOLD_T );
        6 : ( buffer : MMAL_CLOCK_BUFFER_INFO_T );
        7 : ( latency : MMAL_CLOCK_LATENCY_T );
      end;
    padding1 : uint64_t;
  end;

  MMAL_QUEUE_T = record
  end;

  MMAL_POOL_T = record
    queue : PMMAL_QUEUE_T;
    headers_num : uint32_t;
    header : PPMMAL_BUFFER_HEADER_T;
  end;

  MMAL_CONNECTION_T = record
    user_data : pointer;
    callback : MMAL_CONNECTION_CALLBACK_T;
    is_enabled : uint32_t;
    flags : uint32_t;
    in_ : PMMAL_PORT_T;
    out_ : PMMAL_PORT_T;
    pool : PMMAL_POOL_T;
    queue : PMMAL_QUEUE_T;
    name : Pchar;
    time_setup : int64_t;
    time_enable : int64_t;
    time_disable : int64_t;
  end;

// macros
(*
function MMAL_COUNTOF (x) (sizeof((x))/sizeof((x)[0]))
function MMAL_MIN (a, b : integer) : integer;
Result := Min (a, b);
#define MMAL_MAX(a,b) ((a)<(b)?(b):(a))

( *  FIXME: should be different for big endian * )
function MMAL_FOURCC (a, b, c, d : char) : uint32_t;
Result := ord (a) or (ord (b) shl 8) or (ord (c) shl 16) or (ord (d) shl 24))
function MMAL_PARAM_UNUSED (a) (void)(a)
function MMAL_MAGIC : uint32_t;
Result := MMAL_FOURCC ('m', 'm', 'a', 'l');
*)


// macros
function MMAL_VERSION_TO_MAJOR (a : Longword) : Word;
function MMAL_VERSION_TO_MINOR (a : LongWord) : Word;
//function MMAL_TIME_UNKNOWN : longint;

// externals
procedure mmal_buffer_header_acquire (header : PMMAL_BUFFER_HEADER_T); cdecl; external;
procedure mmal_buffer_header_reset (header : PMMAL_BUFFER_HEADER_T); cdecl; external;
procedure mmal_buffer_header_release (header : PMMAL_BUFFER_HEADER_T); cdecl; external;
procedure mmal_buffer_header_release_continue (header : PMMAL_BUFFER_HEADER_T); cdecl; external;
procedure mmal_buffer_header_pre_release_cb_set (header : PMMAL_BUFFER_HEADER_T; cb : MMAL_BH_PRE_RELEASE_CB_T; userdata : pointer); cdecl; external;
function mmal_buffer_header_replicate (dest : PMMAL_BUFFER_HEADER_T; src : PMMAL_BUFFER_HEADER_T) : MMAL_STATUS_T; cdecl; external;
function mmal_buffer_header_mem_lock (header : PMMAL_BUFFER_HEADER_T) : MMAL_STATUS_T; cdecl; external;
procedure mmal_buffer_header_mem_unlock (header : PMMAL_BUFFER_HEADER_T); cdecl; external;

function mmal_format_alloc : PMMAL_ES_FORMAT_T; cdecl; external;
procedure mmal_format_free (format : PMMAL_ES_FORMAT_T); cdecl; external;
function mmal_format_extradata_alloc (format : PMMAL_ES_FORMAT_T; size : dword) : MMAL_STATUS_T; cdecl; external;
procedure mmal_format_copy (format_dest : PMMAL_ES_FORMAT_T; format_src : PMMAL_ES_FORMAT_T); cdecl; external;
function mmal_format_full_copy (format_dest : PMMAL_ES_FORMAT_T; format_src : PMMAL_ES_FORMAT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_format_compare (format_1 : PMMAL_ES_FORMAT_T; format_2 : PMMAL_ES_FORMAT_T) : uint32_t; cdecl; external;

procedure mmal_port_buffer_header_callback (port : PMMAL_PORT_T; buffer : PMMAL_BUFFER_HEADER_T); cdecl; external;
procedure mmal_port_event_send (port : PMMAL_PORT_T; buffer : PMMAL_BUFFER_HEADER_T); cdecl; external;
function mmal_port_alloc (_para1 : PMMAL_COMPONENT_T; _type : MMAL_PORT_TYPE_T; extra_size:dword) : PMMAL_PORT_T;  cdecl; external;
procedure mmal_port_free (port : PMMAL_PORT_T); cdecl; external;
function mmal_ports_alloc (_para1 : PMMAL_COMPONENT_T; ports_num:dword; _type:MMAL_PORT_TYPE_T; extra_size:dword) : PPMMAL_PORT_T;  cdecl; external;
procedure mmal_ports_free (ports : PPMMAL_PORT_T; ports_num:dword); cdecl; external;
procedure mmal_port_acquire (port : PMMAL_PORT_T); cdecl; external;
function mmal_port_release (port : PMMAL_PORT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_pause (port : PMMAL_PORT_T; pause : MMAL_BOOL_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_is_connected (port : PMMAL_PORT_T) : MMAL_BOOL_T; cdecl; external;

function mmal_port_clock_alloc (component : PMMAL_COMPONENT_T; extra_size : dword; event_cb : MMAL_PORT_CLOCK_EVENT_CB) : PMMAL_PORT_T;  cdecl; external;
procedure mmal_port_clock_free (port : PMMAL_PORT_T); cdecl; external;
function mmal_ports_clock_alloc (component : PMMAL_COMPONENT_T; ports_num : dword; extra_size : dword; event_cb:MMAL_PORT_CLOCK_EVENT_CB) : PPMMAL_PORT_T;  cdecl; external;
procedure mmal_ports_clock_free (ports : PPMMAL_PORT_T; ports_num : dword);  cdecl; external;

function mmal_port_clock_request_add (port : PMMAL_PORT_T; media_time : int64_t; cb : MMAL_PORT_CLOCK_REQUEST_CB; cb_data:pointer) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_request_flush (port : PMMAL_PORT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_reference_set (port : PMMAL_PORT_T; reference:MMAL_BOOL_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_reference_get (port : PMMAL_PORT_T) : MMAL_BOOL_T; cdecl; external;
function mmal_port_clock_active_set (port : PMMAL_PORT_T; active:MMAL_BOOL_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_active_get (port : PMMAL_PORT_T) : MMAL_BOOL_T; cdecl; external;
function mmal_port_clock_scale_set (port : PMMAL_PORT_T; scale : MMAL_RATIONAL_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_scale_get (port : PMMAL_PORT_T) : MMAL_RATIONAL_T; cdecl; external;
function mmal_port_clock_media_time_set (port:PMMAL_PORT_T; media_time : int64_t) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_media_time_get (port:PMMAL_PORT_T) : int64_t; cdecl; external;
function mmal_port_clock_update_threshold_set (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_UPDATE_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_update_threshold_get (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_UPDATE_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_discont_threshold_set (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_DISCONT_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_discont_threshold_get (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_DISCONT_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_request_threshold_set (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_REQUEST_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
function mmal_port_clock_request_threshold_get (port : PMMAL_PORT_T; threshold : PMMAL_CLOCK_REQUEST_THRESHOLD_T) : MMAL_STATUS_T; cdecl; external;
procedure mmal_port_clock_input_buffer_info (port : PMMAL_PORT_T; info : PMMAL_CLOCK_BUFFER_INFO_T); cdecl; external;
procedure mmal_port_clock_output_buffer_info (port : PMMAL_PORT_T; info : PMMAL_CLOCK_BUFFER_INFO_T); cdecl; external;

function mmal_component_create (name : PChar; component : PPMMAL_COMPONENT_T) : MMAL_STATUS_T; cdecl; external;
procedure mmal_component_acquire (component : PMMAL_COMPONENT_T); cdecl; external;
function mmal_component_release (component : PMMAL_COMPONENT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_component_destroy (component : PMMAL_COMPONENT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_component_enable (component : PMMAL_COMPONENT_T) : MMAL_STATUS_T; cdecl; external;
function mmal_component_disable (component : PMMAL_COMPONENT_T) : MMAL_STATUS_T; cdecl; external;

function mmal_queue_create : PMMAL_QUEUE_T; cdecl; external;
procedure mmal_queue_put (queue : PMMAL_QUEUE_T; buffer : PMMAL_BUFFER_HEADER_T);  cdecl; external;
procedure mmal_queue_put_back (queue : PMMAL_QUEUE_T; buffer : PMMAL_BUFFER_HEADER_T); cdecl; external;
function mmal_queue_get (queue : PMMAL_QUEUE_T) : PMMAL_BUFFER_HEADER_T; cdecl; external;
function mmal_queue_wait (queue : PMMAL_QUEUE_T) : PMMAL_BUFFER_HEADER_T; cdecl; external;
function mmal_queue_timedwait (queue : PMMAL_QUEUE_T; timeout : VCOS_UNSIGNED) : PMMAL_BUFFER_HEADER_T; cdecl; external;
function mmal_queue_length (queue : PMMAL_QUEUE_T) : dword; cdecl; external;
procedure mmal_queue_destroy (queue : PMMAL_QUEUE_T); cdecl; external;

function mmal_connection_create (connection : PPMMAL_CONNECTION_T; out_ : PMMAL_PORT_T; in_ : PMMAL_PORT_T; flags : uint32_t) : MMAL_STATUS_T; cdecl; external;
procedure mmal_connection_acquire (connection : PMMAL_CONNECTION_T); cdecl; external;
function mmal_connection_release (connection : PMMAL_CONNECTION_T) : MMAL_STATUS_T; cdecl; external;
function mmal_connection_destroy (connection : PMMAL_CONNECTION_T) : MMAL_STATUS_T; cdecl; external;
function mmal_connection_enable (connection : PMMAL_CONNECTION_T) : MMAL_STATUS_T; cdecl; external;
function mmal_connection_disable (connection : PMMAL_CONNECTION_T) : MMAL_STATUS_T; cdecl; external;
function mmal_connection_event_format_changed (connection : PMMAL_CONNECTION_T; buffer : PMMAL_BUFFER_HEADER_T) : MMAL_STATUS_T; cdecl; external;


(*
#include "mmal_common.h"
#include "mmal_types.h"
#include "mmal_port.h"
#include "mmal_component.h"
#include "mmal_parameters.h"
#include "mmal_metadata.h"
#include "mmal_queue.h"
#include "mmal_pool.h"
#include "mmal_events.h"
*)

implementation
// macros
function MMAL_VERSION_TO_MAJOR (a : Longword) : Word;
begin
  Result := a shr 16;
end;

function MMAL_VERSION_TO_MINOR (a : LongWord) : Word;
begin
  Result := a and $FFFF;
end;

end.

