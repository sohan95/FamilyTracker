//
//  OnvifConstants.h
//  CiscoOnvifPlayer
//
//  Created by einfochips on 15/10/14.
//  Copyright (c) 2014 eInfochips. All rights reserved.
//

#ifndef CiscoOnvifPlayer_OnvifConstants_h
#define CiscoOnvifPlayer_OnvifConstants_h

#define SOAP_ENV_ENVELOPE @"SOAP-ENV:Envelope"
#define SOAP_ENV_BODY @"SOAP-ENV:Body"
#define PROBE_MATCHES @"ProbeMatches"
#define PROBE_MATCH @"ProbeMatch"
#define XADDRS @"XAddrs"
#define XADDR @"XAddr"
#define GET_SYSTEM_DATE_AND_TIME_RESPONSE @"GetSystemDateAndTimeResponse"
#define SYSTEM_DATE_AND_TIME @"SystemDateAndTime"
#define UTC_DATE_TIME @"UTCDateTime"
#define DATE @"Date"
#define TIME @"Time"
#define DAY @"Day"
#define MONTH @"Month"
#define YEAR @"Year"
#define HOUR @"Hour"
#define MINUTE @"Minute"
#define SECOND @"Second"

#define GET_PROFILES_RESPONSE @"GetProfilesResponse"
#define PROFILES @"Profiles"
#define GET_STREAM_URI_RESPONSE @"GetStreamUriResponse"
#define MEDIA_URI @"MediaUri"
#define MEDIA @"Media"
#define URI @"Uri"

#define RATE_CONTROL		@"RateControl"
#define BITRATE				@"BitRate"
#define BITRATE_LIMIT		@"BitrateLimit"
#define FRAME_RATE_LIMIT	@"FrameRateLimit"
#define RESOLUTION			@"Resolution"
#define HEIGHT				@"Height"
#define WIDTH				@"Width"
#define FPS					@"Fps"

//New Media URI changes
#define KEY_ENVELOPE		@"Envelope"
#define KEY_BODY			@"Body"
#define KEY_PROBEMATCHES	@"ProbeMatches"
#define KEY_PROBEMATCH		@"ProbeMatch"
#define KEY_XADDRS			@"XAddrs"

#define TDS_GET_CAPABILITIES_RESPONSE @"GetCapabilitiesResponse"
#define TDS_CAPABILITIES @"tds:Capabilities"
#define TT_MEDIA @"tt:Media"
#define TT_XADDR @"tt:XAddr"

#define VIDEO_ENCODER_CONFIGURATION @"VideoEncoderConfiguration"
#define PTZ_CONFIGURATION @"PTZConfiguration"

#define TOKEN @"_token"

#define SELECT @"Select"

#define SOAP_ENV_FAULT @"Fault"
#define SOAP_ENV_REASON @"Reason"
#define SOAP_ENV_TEXT @"Text"
#define TEXT @"__text"

#define GET_CAPABILITIES_RESPONSE @"GetCapabilitiesResponse"
#define CAPABILITIES @"Capabilities"
#define PTZ @"PTZ"

#define GET_CONFIGURATION_RESPONSE @"GetConfigurationsResponse"
#define PTZ_CONFIGURATION @"PTZConfiguration"
#define DEFAULT_PTZ_SPEED @"DefaultPTZSpeed"
#define PAN_TILT @"PanTilt"
#define ZOOM @"Zoom"
//#define X @"_x"
//#define Y @"_y"


#endif
