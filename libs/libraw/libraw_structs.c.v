// @[translated]
module libraw

// -* C++ -*
// *File: libraw_types.h
// *Copyright 2008-2024 LibRaw LLC (info@libraw.org)
// *Created: Sat Mar  8 , 2008
// *
// *LibRaw C data structures
// *
//
// LibRaw is free software; you can redistribute it and/or modify
// it under the terms of the one of two licenses as you choose:
//
// 1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
//   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).
//
// 2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
//   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).
//
//
// WIN32, but not old MSVC
// _WIN32
// VS2010+ : OpenMP works OK, VS2008: have tested by cgilles
//  Have not tested on 9.x and 10.x, but Intel documentation claims OpenMP 2.5
// *support in 9.1
// Not Win32
// Latest XCode works with OpenMP, need to recheck here
type UINT64 = i64
type Uchar = u8
type Ushort = u16

// type INT64 = i64
@[typedef]
struct C.libraw_decoder_info_t {
	decoder_name  &i8
	decoder_flags u32
}

type Libraw_decoder_info_t = C.libraw_decoder_info_t

struct Libraw_internal_output_params_t {
	mix_green   u32
	raw_color   u32
	zero_is_bad u32
	shrink      Ushort
	fuji_width  Ushort
}

type Memory_callback = fn (voidptr, &i8, &i8)

type Exif_parser_callback = fn (voidptr, int, int, int, u32, voidptr, INT64)

type Data_callback = fn (voidptr, &i8, int)

type Progress_callback = fn (voidptr, LibRaw_progress, int, int) int

type Pre_identify_callback = fn (voidptr) int

type Post_identify_callback = fn (voidptr)

type Process_step_callback = fn (voidptr)

struct Libraw_callbacks_t {
	data_cb               Data_callback
	datacb_data           voidptr
	progress_cb           Progress_callback
	progresscb_data       voidptr
	exif_cb               Exif_parser_callback
	exifparser_data       voidptr
	pre_identify_cb       Pre_identify_callback
	post_identify_cb      Post_identify_callback
	pre_subtractblack_cb  Process_step_callback
	pre_scalecolors_cb    Process_step_callback
	pre_preinterpolate_cb Process_step_callback
	pre_interpolate_cb    Process_step_callback
	interpolate_bayer_cb  Process_step_callback
	interpolate_xtrans_cb Process_step_callback
	post_interpolate_cb   Process_step_callback
	pre_converttorgb_cb   Process_step_callback
	post_converttorgb_cb  Process_step_callback
}

@[typedef]
struct C.libraw_processed_image_t {
	// type_ LibRaw_image_formats
	height    Ushort
	width     Ushort
	colors    Ushort
	bits      Ushort
	data_size u32
	data      [1]u8
}

type Libraw_processed_image_t = C.libraw_processed_image_t

@[typedef]
struct C.libraw_iparams_t {
	guard            [4]i8
	make             [64]i8
	model            [64]i8
	software         [64]i8
	normalized_make  [64]i8
	normalized_model [64]i8
	maker_index      u32
	raw_count        u32
	dng_version      u32
	is_foveon        u32
	colors           int
	filters          u32
	xtrans           [6][6]i8
	xtrans_abs       [6][6]i8
	cdesc            [5]i8
	xmplen           u32
	xmpdata          &i8
}

type Libraw_iparams_t = C.libraw_iparams_t

struct Libraw_raw_inset_crop_t {
	cleft   Ushort
	ctop    Ushort
	cwidth  Ushort
	cheight Ushort
}

struct Libraw_image_sizes_t {
	raw_height      Ushort
	raw_width       Ushort
	height          Ushort
	width           Ushort
	top_margin      Ushort
	left_margin     Ushort
	iheight         Ushort
	iwidth          Ushort
	raw_pitch       u32
	pixel_aspect    f64
	flip            int
	mask            [8][4]int
	raw_aspect      Ushort
	raw_inset_crops [2]Libraw_raw_inset_crop_t
}

// top, left, bottom, right pixel coordinates, (0,0) is top left pixel;
struct Libraw_area_t {
	t i16
	l i16
	b i16
	r i16
}

struct Ph1_t {
	format    int
	key_off   int
	tag_21a   int
	t_black   int
	split_col int
	black_col int
	split_row int
	black_row int
	tag_210   f32
}

struct Libraw_dng_color_t {
	parsedfields  u32
	illuminant    Ushort
	calibration   [4][4]f32
	colormatrix   [4][3]f32
	forwardmatrix [3][4]f32
}

struct Libraw_dng_levels_t {
	parsedfields   u32
	dng_cblack     [4104]u32
	dng_black      u32
	dng_fcblack    [4104]f32
	dng_fblack     f32
	dng_whitelevel [4]u32
	default_crop   [4]Ushort

	// Origin and size
	user_crop [4]f32

	// top-left-bottom-right relative to default_crop
	preview_colorspace    u32
	analogbalance         [4]f32
	asshotneutral         [4]f32
	baseline_exposure     f32
	linear_response_limit f32
}

struct Libraw_P1_color_t {
	romm_cam [9]f32
}

struct Libraw_canon_makernotes_t {
	color_data_ver       int
	color_data_sub_ver   int
	specular_white_level int
	normal_white_level   int
	channel_black_level  [4]int
	average_black_level  int

	// multishot_
	multishot [4]u32

	// metering
	metering_mode       i16
	spot_metering_mode  i16
	flash_metering_mode Uchar
	flash_exposure_lock   i16
	exposure_mode        i16
	ae_setting           i16

	// stabilization
	image_stabilization i16

	// flash
	flash_mode         i16
	flash_activity     i16
	flash_bits         i16
	manual_flash_output i16
	flash_output       i16
	flash_guide_number  i16

	// drive
	continuous_drive i16

	// sensor
	sensor_width           i16
	sensor_height          i16
	af_micro_adj_mode        int
	af_micro_adj_value       f32
	// makernotesFlip        i16
	// recordMode            i16
	// sRAWQuality           i16
	// wbi                   u32
	// rF_lensID             i16
	// autoLightingOptimizer int
	// highlightTonePriority int

	// -1 = n/a            1 = Economy
	//        2 = Normal         3 = Fine
	//        4 = RAW            5 = Superfine
	//        7 = CRAW         130 = Normal Movie, CRM LightRaw
	//      131 = CRM  StandardRaw
	quality i16

	// data compression curve
	//        0 = OFF  1 = CLogV1 2 = CLogV2? 3 = CLogV3
	// canonLog             int
	// defaultCropAbsolute  Libraw_area_t
	// recommendedImageArea Libraw_area_t

	// contains the image in proper aspect ratio?
	// leftOpticalBlack Libraw_area_t

	// use this, when present, to estimate black levels?
	// upperOpticalBlack Libraw_area_t
	// activeArea        Libraw_area_t
	// iSOgain           [2]i16
}

// AutoISO & BaseISO per ExifTool
struct Libraw_hasselblad_makernotes_t {
	base_iso   int
	gain       f64
	sensor     [8]i8
	// sensorUnit [64]i8 // SU
	// hostBody [64]i8 // HB
	// sensorCode    int
	// sensorSubCode int
	// coatingCode   int
	// uncropped     int

	// CaptureSequenceInitiator is based on the content of the 'model' tag
	//  - values like 'Pinhole', 'Flash Sync', '500 Mech.' etc in .3FR 'model' tag
	//    come from MAIN MENU > SETTINGS > Camera;
	//  - otherwise 'model' contains:
	//    1. if CF/CFV/CFH, SU enclosure, can be with SU type if '-' is present
	//    2. else if '-' is present, HB + SU type;
	//    3. HB;
	//
	// captureSequenceInitiator [32]i8

	// SensorUnitConnector, makernotes 0x0015 tag:
	// - in .3FR - SU side
	// - in .FFF - HB side
	//
	// sensorUnitConnector [64]i8
	format              int

	// 3FR, FFF, Imacon (H3D-39 and maybe others), Hasselblad/Phocus DNG, Adobe DNG
	// nIFD_CM [2]int

	// number of IFD containing CM
	// recommendedCrop [2]int

	// mnColorMatrix is in makernotes tag 0x002a;
	//  not present in .3FR files and Imacon/H3D-39 .FFF files;
	//  when present in .FFF and Phocus .DNG files, it is a copy of CM1 from .3FR;
	//  available samples contain all '1's in the first 3 elements
	//
	// mnColorMatrix [4][3]f64
}

struct Libraw_fuji_info_t {
	// expoMidPointShift       f32
	// dynamicRange            Ushort
	// filmMode                Ushort
	// dynamicRangeSetting     Ushort
	// developmentDynamicRange Ushort
	// autoDynamicRange        Ushort
	// dRangePriority          Ushort
	// dRangePriorityAuto      Ushort
	// dRangePriorityFixed     Ushort
	// fujiModel               [33]i8
	// fujiModel2              [33]i8

	//
	//    tag 0x9200, converted to BrightnessCompensation
	//    F700, S3Pro, S5Pro, S20Pro, S200EXR
	//    E550, E900, F810, S5600, S6500fd, S9000, S9500, S100FS
	//
	// brightnessCompensation f32

	// in EV, if =4, raw data *2^4
	// focusMode          Ushort
	// aFMode             Ushort
	// focusPixel         [2]Ushort
	// prioritySettings   Ushort
	// focusSettings      u32
	// aF_C_Settings      u32
	// focusWarning       Ushort
	// imageStabilization [3]Ushort
	// flashMode          Ushort
	// wB_Preset          Ushort

	// ShutterType:
	//       0 - mechanical
	//       1 = electronic
	//       2 = electronic, long shutter speed
	//       3 = electronic, front curtain
	//
	shutter_type Ushort
	// exrMode      Ushort
	macro        Ushort
	rating       u32

	// CropMode:
	//       1 - FF on GFX,
	//       2 - sports finder (mechanical shutter),
	//       4 - 1.25x crop (electronic shutter, continuous high)
	//
	// cropMode          Ushort
	// serialSignature   [13]i8
	// sensorID          [5]i8
	// rAFVersion        [5]i8
	// rAFDataGeneration int
	// // 0 (none), 1..4, 4096
	// rAFDataVersion Ushort
	// isTSNERDTS     int

	// DriveMode:
	//       0 - single frame
	//       1 - continuous low
	//       2 - continuous high
	//
	// driveMode i16

	//
	//    tag 0x4000 BlackLevel:
	//    S9100, S9000, S7000, S6000fd, S5200, S5100, S5000,
	//    S5Pro, S3Pro, S2Pro, S20Pro,
	//    S200EXR, S100FS,
	//    F810, F700,
	//    E900, E550,
	//    DBP, and aliases for all of the above
	//
	// blackLevel             [9]Ushort
	// rAFData_ImageSizeTable [32]u32
	// autoBracketing         int
	// sequenceNumber         int
	// seriesLength           int
	// pixelShiftOffset       [2]f32
	// imageCount             int
}

struct Libraw_sensor_highspeed_crop_t {
	cleft   Ushort
	ctop    Ushort
	cwidth  Ushort
	cheight Ushort
}

struct Libraw_nikon_makernotes_t {
	// exposureBracketValue f64
	// activeDLighting      Ushort
	// shootingMode         Ushort

	// // stabilization
	// imageStabilization [7]Uchar
	// vibrationReduction Uchar
	// vRMode             Uchar

	// // flash
	// flashSetting                    [13]i8
	// flashType                       [20]i8
	// flashExposureCompensation       [4]Uchar
	// externalFlashExposureComp       [4]Uchar
	// flashExposureBracketValue       [4]Uchar
	// flashMode                       Uchar
	// flashExposureCompensation2      i8
	// flashExposureCompensation3      i8
	// flashExposureCompensation4      i8
	// flashSource                     Uchar
	// flashFirmware                   [2]Uchar
	// externalFlashFlags              Uchar
	// flashControlCommanderMode       Uchar
	// flashOutputAndCompensation      Uchar
	// flashFocalLength                Uchar
	// flashGNDistance                 Uchar
	// flashGroupControlMode           [4]Uchar
	// flashGroupOutputAndCompensation [4]Uchar
	// flashColorFilter                Uchar

	// NEF compression, comments follow those for ExifTool tag 0x0093:
	//	 1: Lossy (type 1)
	//	 2: Uncompressed
	//	 3: Lossless
	//	 4: Lossy (type 2)
	//	 5: Striped packed 12-bit
	//	 6: Uncompressed (14-bit reduced to 12-bit)
	//	 7: Unpacked 12-bit
	//	 8: Small raw
	//	 9: Packed 12-bit
	//	10: Packed 14-bit
	//	13: High Efficiency  (HE)
	//	14: High Efficiency*(HE*
	//
	// nEFCompression      Ushort
	// exposureMode        int
	// exposureProgram     int
	// nMEshots            int
	// mEgainOn            int
	// mE_WB               [4]f64
	// aFFineTune          Uchar
	// aFFineTuneIndex     Uchar
	// aFFineTuneAdj       u8
	// lensDataVersion     u32
	// flashInfoVersion    u32
	// colorBalanceVersion u32
	// key                 Uchar
	// nEFBitDepth         [4]Ushort
	// highSpeedCropFormat Ushort

	// // 1 -> 1.3x; 2 -> DX; 3 -> 5:4; 4 -> 3:2; 6 ->
	// //                                   16:9; 11 -> FX uncropped; 12 -> DX uncropped;
	// //                                   17 -> 1:1
	// sensorHighSpeedCrop   Libraw_sensor_highspeed_crop_t
	// sensorWidth           Ushort
	// sensorHeight          Ushort
	// active_D_Lighting     Ushort
	// pictureControlVersion u32
	// pictureControlName    [20]i8
	// pictureControlBase    [20]i8
	// shotInfoVersion       u32
	// makernotesFlip        i16
	// rollAngle             f64
	// // positive is clockwise, CW
	// pitchAngle f64
	// // positive is upwords
	// yawAngle f64
	// // positive is to the right
}

struct Libraw_olympus_makernotes_t {
	// cameraType2       [6]i8
	// validBits         Ushort
	// sensorCalibration [2]int
	// driveMode         [5]Ushort
	// colorSpace        Ushort
	// focusMode         [2]Ushort
	// autoFocus         Ushort
	// aFPoint           Ushort
	// aFAreas           [64]u32
	// aFPointSelected   [5]f64
	// aFResult          Ushort
	// aFFineTune        Uchar
	// aFFineTuneAdj     [3]i16
	// specialMode       [3]u32
	// zoomStepCount     Ushort
	// focusStepCount    Ushort
	// focusStepInfinity Ushort
	// focusStepNear     Ushort
	// focusDistance     f64
	// aspectFrame       [4]Ushort

	// left, top, width, height
	// stackedImage      [2]u32
	// isLiveND          Uchar
	// liveNDfactor      u32
	// panorama_mode     Ushort
	// panorama_frameNum Ushort
}

struct Libraw_panasonic_makernotes_t {
	// Compression:
	//     34826 (Panasonic RAW 2): LEICA DIGILUX 2;
	//     34828 (Panasonic RAW 3): LEICA D-LUX 3; LEICA V-LUX 1; Panasonic DMC-LX1;
	//     Panasonic DMC-LX2; Panasonic DMC-FZ30; Panasonic DMC-FZ50; 34830 (not in
	//     exiftool): LEICA DIGILUX 3; Panasonic DMC-L1; 34316 (Panasonic RAW 1):
	//     others (LEICA, Panasonic, YUNEEC);
	//
	// compression   Ushort
	// blackLevelDim Ushort
	// blackLevel    [8]f32
	// multishot     u32

	// 0 is Off, 65536 is Pixel Shift
	gamma             f32
	// highISOMultiplier [3]int

	// 0->R, 1->G, 2->B
	// focusStepNear    i16
	// focusStepCount   i16
	// zoomPosition     u32
	// lensManufacturer u32
}

struct Libraw_pentax_makernotes_t {
	// driveMode               [4]Uchar
	// focusMode               [2]Ushort
	// aFPointSelected         [2]Ushort
	// aFPointSelected_Area    Ushort
	// aFPointsInFocus_version int
	// aFPointsInFocus         u32
	// focusPosition           Ushort
	// aFAdjustment            i16
	// aFPointMode             Uchar
	// multiExposure           Uchar

	// last bit is not "1" if ME is not used
	quality Ushort
	// 4 is raw, 7 is raw w/ pixel shift, 8 is raw w/ dynamic
}

struct Libraw_ricoh_makernotes_t {
	// aFStatus           Ushort
	// aFAreaXPosition    [2]u32
	// aFAreaYPosition    [2]u32
	// aFAreaMode         Ushort
	// sensorWidth        u32
	// sensorHeight       u32
	// croppedImageWidth  u32
	// croppedImageHeight u32
	// wideAdapter        Ushort
	// cropMode           Ushort
	// nDFilter           Ushort
	// autoBracketing     Ushort
	// macroMode          Ushort
	// flashMode          Ushort
	// flashExposureComp  f64
	// manualFlashOutput  f64
}

struct Libraw_samsung_makernotes_t {
	// imageSizeFull [4]u32
	// imageSizeCrop [4]u32
	// colorSpace    [2]int
	// key           [11]u32
	// digitalGain   f64

	// PostAEGain, digital stretch
	// deviceType   int
	// lensFirmware [32]i8
}

struct Libraw_kodak_makernotes_t {
	// blackLevelTop    Ushort
	// blackLevelBottom Ushort
	offset_left      i16
	offset_top       i16

	// KDC files, negative values or zeros
	// clipBlack Ushort
	// clipWhite Ushort

	// valid for P712, P850, P880
	// romm_camDaylight    [3][3]f32
	// romm_camTungsten    [3][3]f32
	// romm_camFluorescent [3][3]f32
	// romm_camFlash       [3][3]f32
	// romm_camCustom      [3][3]f32
	// romm_camAuto        [3][3]f32
	val018percent       Ushort
	val100percent       Ushort
	val170percent       Ushort
	// makerNoteKodak8a    i16
	// iSOCalibrationGain  f32
	// analogISO           f32
}

struct Libraw_p1_makernotes_t {
	software [64]i8

	// tag 0x0203
	// systemType [64]i8

	// tag 0x0204
	// firmwareString [256]i8

	// tag 0x0301
	// systemModel [64]i8
}

struct Libraw_sony_info_t {
	// afdata:
	//  0x0010 CameraInfo
	//  0x2020 AFPointsUsed
	//  0x2022 FocalPlaneAFPointsUsed
	//  0x202a Tag202a
	//  0x940e AFInfo
	//
	// cameraType Ushort

	// init in 0xffff
	sony0x9400_version Uchar

	// 0 if not found/deciphered,
	//                                    0xa, 0xb, 0xc following exiftool convention
	// sony0x9400_ReleaseMode2        Uchar
	// sony0x9400_SequenceImageNumber u32
	// sony0x9400_SequenceLength1     Uchar
	// sony0x9400_SequenceFileNumber  u32
	// sony0x9400_SequenceLength2     Uchar
	// aFAreaModeSetting              u8

	// init in 0xff; +
	// aFAreaMode u16

	// init in 0xffff; +
	// flexibleSpotPosition [2]Ushort

	// init in (0xffff, 0xffff)
	// aFPointSelected u8

	// init in 0xff
	// aFPointSelected_0x201e u8

	// init in 0xff
	// nAFPointsUsed i16
	// aFPointsUsed  [10]u8
	// aFTracking    u8

	// init in 0xff
	// aFType        u8
	// focusLocation [4]Ushort
	// focusPosition Ushort

	// init in 0xffff
	// aFMicroAdjValue u8

	// init in 0x7f
	// aFMicroAdjOn u8

	// init in -1
	// aFMicroAdjRegisteredLenses Uchar

	// init in 0xff
	// variableLowPassFilter      Ushort
	// longExposureNoiseReduction u32

	// init in 0xffffffff
	// highISONoiseReduction Ushort

	// init in 0xffff
	hdr           [2]Ushort
	group2010     Ushort
	group9050     Ushort
	len_group9050 Ushort

	// currently, for debugging only
	real_iso_offset Ushort

	// init in 0xffff
	// meteringMode_offset    Ushort
	// exposureProgram_offset Ushort
	// releaseMode2_offset    Ushort
	// minoltaCamID           u32

	// init in 0xffffffff
	firmware           f32
	// imageCount3_offset Ushort

	// init in 0xffff
	// imageCount3                   u32
	// electronicFrontCurtainShutter u32

	// init in 0xffffffff
	// meteringMode2           Ushort
	// sonyDateTime            [20]i8
	// shotNumberSincePowerUp  u32
	// pixelShiftGroupPrefix   Ushort
	// pixelShiftGroupID       u32
	// nShotsInPixelShiftGroup i8
	// numInPixelShiftGroup    i8

	// '0' if ARQ, first shot in the group has '1'
	//                                  here
	// prd_ImageHeight   Ushort
	// prd_ImageWidth    Ushort
	// prd_Total_bps     Ushort
	// prd_Active_bps    Ushort
	// prd_StorageMethod Ushort

	// 82 -> Padded; 89 -> Linear
	// prd_BayerPattern Ushort

	// 0 -> not valid; 1 -> RGGB; 4 -> GBRG
	// sonyRawFileType Ushort

	// init in 0xffff
	//                               valid for ARW 2.0 and up (FileFormat >= 3000)
	//                               takes precedence over RAWFileType and Quality:
	//                               0  for uncompressed 14-bit raw
	//                               1  for uncompressed 12-bit raw
	//                               2  for compressed raw (lossy)
	//                               3  for lossless compressed raw
	//                               4  for lossless compressed raw v.2 (ILCE-1)
	//
	// rAWFileType Ushort

	// init in 0xffff
	//                               takes precedence over Quality
	//                               0 for compressed raw,
	//                               1 for uncompressed;
	//                               2 lossless compressed raw v.2
	//
	// rawSizeType Ushort

	// init in 0xffff
	//                               1 - large,
	//                               2 - small,
	//                               3 - medium
	//
	quality u32

	// init in 0xffffffff
	//                               0 or 6 for raw, 7 or 8 for compressed raw
	// fileFormat Ushort

	//  1000 SR2
	//                                2000 ARW 1.0
	//                                3000 ARW 2.0
	//                                3100 ARW 2.1
	//                                3200 ARW 2.2
	//                                3300 ARW 2.3
	//                                3310 ARW 2.3.1
	//                                3320 ARW 2.3.2
	//                                3330 ARW 2.3.3
	//                                3350 ARW 2.3.5
	//                                4000 ARW 4.0
	//                                4010 ARW 4.0.1
	//
	// metaVersion [16]i8
	// aspectRatio f32
}

struct Libraw_colordata_t {
	curve        [65536]Ushort
	cblack       [4104]u32
	black        u32
	data_maximum u32
	maximum      u32

	// Canon (SpecularWhiteLevel)
	// Kodak (14N, 14nx, SLR/c/n, DCS720X, DCS760C, DCS760M, ProBack, ProBack645, P712, P880, P850)
	// Olympus, except:
	//	C5050Z, C5060WZ, C7070WZ, C8080WZ
	//	SP350, SP500UZ, SP510UZ, SP565UZ
	//	E-10, E-20
	//	E-300, E-330, E-400, E-410, E-420, E-450, E-500, E-510, E-520
	//	E-1, E-3
	//	XZ-1
	// Panasonic
	// Pentax
	// Sony
	// and aliases of the above
	// DNG
	linear_max           [4]int
	fmaximum             f32
	fnorm                f32
	white                [8][8]Ushort
	cam_mul              [4]f32
	pre_mul              [4]f32
	cmatrix              [3][4]f32
	ccm                  [3][4]f32
	rgb_cam              [3][4]f32
	cam_xyz              [4][3]f32
	phase_one_data       Ph1_t
	flash_used           f32
	canon_ev             f32
	model2               [64]i8
	// uniqueCameraModel    [64]i8
	// localizedCameraModel [64]i8
	// imageUniqueID        [64]i8
	// rawDataUniqueID      [17]i8
	// originalRawFileName  [64]i8
	profile              voidptr
	profile_length       u32
	black_stat           [8]u32
	dng_color            [2]Libraw_dng_color_t
	dng_levels           Libraw_dng_levels_t
	// wB_Coeffs            [256][4]int

	// R, G1, B, G2 coeffs
	// wBCT_Coeffs [64][5]f32

	// CCT, than R, G1, B, G2 coeffs
	as_shot_wb_applied int
	p1_color           [2]Libraw_P1_color_t
	raw_bps            u32

	// for Phase One: raw format; For other cameras: bits per pixel (copy of tiff_bps in most cases)
	// Phase One raw format values, makernotes tag 0x010e:
	//                      0    Name unknown
	//                      1    "RAW 1"
	//                      2    "RAW 2"
	//                      3    "IIQ L" (IIQ L14)
	//                      4    Never seen
	//                      5    "IIQ S"
	//                      6    "IIQ Sv2" (S14 / S14+)
	//                      7    Never seen
	//                      8    "IIQ L16" (IIQ L16EX / IIQ L16)
	//
	// exifColorSpace int
}

struct Libraw_thumbnail_t {
	tformat LibRaw_thumbnail_formats
	twidth  Ushort
	theight Ushort
	tlength u32
	tcolors int
	thumb   &i8
}

struct Libraw_thumbnail_item_t {
	tformat LibRaw_internal_thumbnail_formats
	twidth  Ushort
	theight Ushort
	tflip   Ushort
	tlength u32
	tmisc   u32
	toffset INT64
}

struct Libraw_thumbnail_list_t {
	thumbcount int
	thumblist  [8]Libraw_thumbnail_item_t
}

struct Libraw_gps_info_t {
	latitude [3]f32

	// Deg,min,sec
	longitude [3]f32

	// Deg,min,sec
	gpstimestamp [3]f32

	// Deg,min,sec
	altitude  f32
	altref    i8
	latref    i8
	longref   i8
	gpsstatus i8
	gpsparsed i8
}

@[typedef]
struct C.libraw_imgother_t {
	iso_speed f32
	shutter   f32
	aperture  f32
	focal_len f32

	// timestamp Time_t
	shot_order    u32
	gpsdata       [32]u32
	parsed_gps    Libraw_gps_info_t
	desc          [512]i8
	artist        [64]i8
	analogbalance [4]f32
}

type Libraw_imgother_t = C.libraw_imgother_t

struct Libraw_afinfo_item_t {
	// aFInfoData_tag     u32
	// aFInfoData_order   i16
	// aFInfoData_version u32
	// aFInfoData_length  u32
	// aFInfoData         &Uchar
}

struct Libraw_metadata_common_t {
	// flashEC                  f32
	// flashGN                  f32
	// cameraTemperature        f32
	// sensorTemperature        f32
	// sensorTemperature2       f32
	// lensTemperature          f32
	// ambientTemperature       f32
	// batteryTemperature       f32
	// exifAmbientTemperature   f32
	// exifHumidity             f32
	// exifPressure             f32
	// exifWaterDepth           f32
	// exifAcceleration         f32
	// exifCameraElevationAngle f32
	// real_ISO                 f32
	// exifExposureIndex        f32
	// colorSpace               Ushort
	// firmware                 [128]i8
	// exposureCalibrationShift f32
	// afdata                   [4]Libraw_afinfo_item_t
	// afcount                  int
}

struct Libraw_output_params_t {
	greybox [4]u32

	// -A  x1 y1 x2 y2
	cropbox [4]u32

	// -B x1 y1 x2 y2
	aber [4]f64

	// -C
	gamm [6]f64

	// -g
	user_mul [4]f32

	// -r mul0 mul1 mul2 mul3
	bright f32

	// -b
	threshold f32

	// -n
	half_size int

	// -h
	four_color_rgb int

	// -f
	highlight int

	// -H
	use_auto_wb int

	// -a
	use_camera_wb int

	// -w
	use_camera_matrix int

	// +M/-M
	output_color int

	// -o
	output_profile &i8

	// -o
	camera_profile &i8

	// -p
	bad_pixels &i8

	// -P
	dark_frame &i8

	// -K
	output_bps int

	// -4
	output_tiff int

	// -T
	output_flags int
	user_flip    int

	// -t
	user_qual int

	// -q
	user_black int

	// -k
	user_cblack [4]int
	user_sat    int

	// -S
	med_passes int

	// -m
	auto_bright_thr    f32
	adjust_maximum_thr f32
	no_auto_bright     int

	// -W
	use_fuji_rotate int

	// -j
	use_p1_correction int
	green_matching    int

	// DCB parameters
	dcb_iterations int
	dcb_enhance_fl int
	fbdd_noiserd   int
	exp_correc     int
	exp_shift      f32
	exp_preser     f32

	// Disable Auto-scale
	no_auto_scale int

	// Disable intepolation
	no_interpolation int
}

struct Libraw_raw_unpack_params_t {
	// Raw speed
	use_rawspeed int

	// DNG SDK
	use_dngsdk  int
	options     u32
	shot_select u32

	// -s
	specials                    u32
	max_raw_memory_mb           u32
	sony_arw2_posterization_thr int

	// Nikon Coolscan
	coolscan_nef_gamma f32
	p4shot_order       [5]i8

	// Custom camera list
	custom_camera_strings &&u8
}

struct Libraw_rawdata_t {
	// really allocated bitmap
	raw_alloc voidptr

	// alias to single_channel variant
	raw_image &Ushort

	// alias to 4-channel variant
	color4_image [4]fn () Ushort

	// alias to 3-color variand decoded by RawSpeed
	color3_image [3]fn () Ushort

	// float bayer
	float_image &f32

	// float 3-component
	float3_image [3]fn () f32

	// float 4-component
	float4_image [4]fn () f32

	// Phase One black level data;
	ph1_cblack [2]fn () i16
	ph1_rblack [2]fn () i16

	// save color and sizes here, too....
	iparams  Libraw_iparams_t
	sizes    Libraw_image_sizes_t
	ioparams Libraw_internal_output_params_t
	color    Libraw_colordata_t
}

struct Libraw_makernotes_lens_t {
	// lensID     i64
	// lens       [128]i8
	// lensFormat Ushort

	// // to characterize the image circle the lens covers
	// lensMount Ushort

	// // 'male', lens itself
	// camID        i64
	// cameraFormat Ushort

	// // some of the sensor formats
	// cameraMount Ushort

	// // 'female', body throat
	// body      [64]i8
	// focalType i16

	// -1/0 is unknown; 1 is fixed focal; 2 is zoom
	// lensFeatures_pre        [16]i8
	// lensFeatures_suf        [16]i8
	// minFocal                f32
	// maxFocal                f32
	// maxAp4MinFocal          f32
	// maxAp4MaxFocal          f32
	// minAp4MinFocal          f32
	// minAp4MaxFocal          f32
	// maxAp                   f32
	// minAp                   f32
	// curFocal                f32
	// curAp                   f32
	// maxAp4CurFocal          f32
	// minAp4CurFocal          f32
	// minFocusDistance        f32
	// focusRangeIndex         f32
	// lensFStops              f32
	// teleconverterID         i64
	// teleconverter           [128]i8
	// adapterID               i64
	// adapter                 [128]i8
	// attachmentID            i64
	// attachment              [128]i8
	// focalUnits              Ushort
	// focalLengthIn35mmFormat f32
}

struct Libraw_nikonlens_t {
	// effectiveMaxAp f32
	// lensIDNumber   Uchar
	// lensFStops     Uchar
	// mCUVersion     Uchar
	// lensType       Uchar
}

struct Libraw_dnglens_t {
	// minFocal       f32
	// maxFocal       f32
	// maxAp4MinFocal f32
	// maxAp4MaxFocal f32
}

@[typedef]
struct C.libraw_lensinfo_t {
	// minFocal                f32
	// maxFocal                f32
	// maxAp4MinFocal          f32
	// maxAp4MaxFocal          f32
	// eXIF_MaxAp              f32
	// lensMake                [128]i8
	// lens                    [128]i8
	// lensSerial              [128]i8
	// internalLensSerial      [128]i8
	// focalLengthIn35mmFormat Ushort
	nikon                   Libraw_nikonlens_t
	dng                     Libraw_dnglens_t
	makernotes              Libraw_makernotes_lens_t
}

type Libraw_lensinfo_t = C.libraw_lensinfo_t

struct Libraw_makernotes_t {
	canon      Libraw_canon_makernotes_t
	nikon      Libraw_nikon_makernotes_t
	hasselblad Libraw_hasselblad_makernotes_t
	fuji       Libraw_fuji_info_t
	olympus    Libraw_olympus_makernotes_t
	sony       Libraw_sony_info_t
	kodak      Libraw_kodak_makernotes_t
	panasonic  Libraw_panasonic_makernotes_t
	pentax     Libraw_pentax_makernotes_t
	phaseone   Libraw_p1_makernotes_t
	ricoh      Libraw_ricoh_makernotes_t
	samsung    Libraw_samsung_makernotes_t
	common     Libraw_metadata_common_t
}

struct Libraw_shootinginfo_t {
	// driveMode          i16
	// focusMode          i16
	// meteringMode       i16
	// aFPoint            i16
	// exposureMode       i16
	// exposureProgram    i16
	// imageStabilization i16
	// bodySerial         [64]i8
	// internalBodySerial [64]i8
	// this may be PCB or sensor serial, depends on make/model
}

struct Libraw_custom_camera_t {
	fsize   u32
	rw      Ushort
	rh      Ushort
	lm      Uchar
	tm      Uchar
	rm      Uchar
	bm      Uchar
	lf      Ushort
	cf      Uchar
	max     Uchar
	flags   Uchar
	t_make  [10]i8
	t_model [20]i8
	offset  Ushort
}

@[typedef]
struct C.libraw_data_t {
	image            [4]fn () Ushort
	sizes            Libraw_image_sizes_t
	idata            Libraw_iparams_t
	lens             Libraw_lensinfo_t
	makernotes       Libraw_makernotes_t
	shootinginfo     Libraw_shootinginfo_t
	params           Libraw_output_params_t
	rawparams        Libraw_raw_unpack_params_t
	progress_flags   u32
	process_warnings u32
	color            Libraw_colordata_t
	other            Libraw_imgother_t
	thumbnail        Libraw_thumbnail_t
	thumbs_list      Libraw_thumbnail_list_t
	rawdata          Libraw_rawdata_t
	parent_class     voidptr
}

type Libraw_data_t = C.libraw_data_t

struct Fuji_q_table {
	q_table &u8

	// quantization table
	raw_bits     int
	total_values int
	max_grad     int

	// sdp val
	q_grad_mult int

	// quant_gradient multiplier
	q_base int
}

struct Fuji_compressed_params {
	qt        [4]Fuji_q_table
	buf       voidptr
	max_bits  int
	min_value int
	max_value int

	// q_point[4]
	line_width Ushort
}

// Byte order
// -* C++ -*
// *File: libraw_internal.h
// *Copyright 2008-2024 LibRaw LLC (info@libraw.org)
// *Created: Sat Mar  8 , 2008
// *
// *LibRaw internal data structures (not visible outside)
//
// LibRaw is free software; you can redistribute it and/or modify
// it under the terms of the one of two licenses as you choose:
//
// 1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
//   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).
//
// 2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
//   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).
//
//
// __cplusplus
struct Internal_data_t {
	// input          &LibRaw_abstract_datastream
	output         &C.FILE
	input_internal int
	meta_data      &i8
	profile_offset INT64
	toffset        INT64
	pana_black     [4]u32
}

struct Output_data_t {
	histogram [8192]fn () int
	oprof     &u32
}

struct Identify_data_t {
	olympus_exif_cfa u32
	unique_id        i64
	// olyID            i64
	tiff_nifds       u32
	tiff_flip        int
	metadata_blocks  int
}

struct Crx_sample_to_chunk_t {
	first u32
	count u32
	id    u32
}

// contents of tag CMP1 for relevant track in CR3 file
struct Crx_data_header_t {
	version     int
	f_width     int
	f_height    int
	// tileWidth   int
	// tileHeight  int
	// nBits       int
	// nPlanes     int
	// cfaLayout   int
	// encType     int
	// imageLevels int
	// hasTileCols int
	// hasTileRows int
	// mdatHdrSize int
	// medianBits  int

	// // Not from header, but from datastream
	// mediaSize   u32
	// mediaOffset INT64
	// mediaType   u32

	// 1 -> /C/RAW, 2-> JPEG, 3-> CTMD metadata
	stsc_data &Crx_sample_to_chunk_t

	// samples to chunk
	stsc_count   u32
	sample_count u32
	sample_size  u32

	// zero if not fixed sample size
	sample_sizes  &int
	chunk_count   u32
	chunk_offsets &INT64
}

struct Pana8_tags_t {
	tag39        [6]u32
	// tag3A        [6]u16
	// tag3B        u16
	initial      [4]u16
	tag40a       [17]u16
	tag40b       [17]u16
	tag41        [17]u16
	stripe_count u16

	// 0x42
	tag43          u16
	stripe_offsets [5]INT64

	// 0x44
	stripe_left [5]u16

	// 0x45
	stripe_compressed_size [5]u32

	// 0x46
	stripe_width [5]u16

	// 0x47
	stripe_height [5]u16
}

struct Unpacker_data_t {
	order                        i16
	sraw_mul                     [4]Ushort
	cr2_slice                    [3]Ushort
	kodak_cbpp                   u32
	strip_offset                 INT64
	data_offset                  INT64
	meta_offset                  INT64
	exif_offset                  INT64
	exif_subdir_offset           INT64
	ifd0_offset                  INT64
	data_size                    u32
	meta_length                  u32
	cr3_exif_length              u32
	cr3_ifd0_length              u32
	thumb_misc                   u32
	thumb_format                 LibRaw_internal_thumbnail_formats
	fuji_layout                  u32
	tiff_samples                 u32
	tiff_bps                     u32
	tiff_compress                u32
	tiff_sampleformat            u32
	zero_after_ff                u32
	tile_width                   u32
	tile_length                  u32
	load_flags                   u32
	data_error                   u32
	hasselblad_parser_flag       int
	// posRAFData                   i64
	// lenRAFData                   u32
	fuji_total_lines             int
	fuji_total_blocks            int
	fuji_block_width             int
	fuji_bits                    int
	fuji_raw_type                int
	fuji_lossless                int
	pana_encoding                int
	pana_bpp                     int
	pana8                        Pana8_tags_t
	crx_header                   [16]Crx_data_header_t
	crx_track_selected           int
	crx_track_count              int
	// cR3_CTMDtag                  i16
	// cR3_Version                  i16
	// cM_found                     int
	// is_NikonTransfer             u32
	// is_Olympus                   u32
	// olympusDNG_SubDirOffsetValid int
	// is_Sony                      u32
	// is_pana_raw                  u32
	// is_PentaxRicohMakernotes     u32

	// =1 for Ricoh software by Pentax, Camera DNG
	dng_frames [20]u32

	// bits: 0-7: shot_select, 8-15: IFD#, 16-31: low 16 bit of newsubfile type
	raw_stride u16
}

struct Libraw_internal_data_t {
	internal_data          Internal_data_t
	internal_output_params Libraw_internal_output_params_t
	output_data            Output_data_t
	identify_data          Identify_data_t
	unpacker_data          Unpacker_data_t
}

struct Decode {
	branch [2]&Decode
	leaf   int
}

struct Tiff_ifd_t {
	t_width                 int
	t_height                int
	bps                     int
	comp                    int
	phint                   int
	offset                  int
	t_flip                  int
	samples                 int
	bytes                   int
	extrasamples            int
	t_tile_width            int
	t_tile_length           int
	sample_format           int
	predictor               int
	rows_per_strip          int
	strip_offsets           &int
	strip_offsets_count     int
	strip_byte_counts       &int
	strip_byte_counts_count int
	t_filters               u32
	t_vwidth                int
	t_vheight               int
	t_lm                    int
	t_tm                    int
	t_fuji_width            int
	t_shutter               f32

	// Per-IFD DNG fields
	opcode2_offset     INT64
	lineartable_offset INT64
	lineartable_len    int
	dng_color          [2]Libraw_dng_color_t
	dng_levels         Libraw_dng_levels_t
	newsubfiletype     int
}

struct Jhead {
	algo    int
	bits    int
	high    int
	wide    int
	clrs    int
	sraw    int
	psv     int
	restart int
	vpred   [6]int
	quant   [64]Ushort
	idct    [64]Ushort
	huff    [20]&Ushort
}

// c.free [20]&Ushort // row &Ushort
struct Libraw_tiff_tag {
	// tag Ushort
	// type_ Ushort
	count int
	// val Union (unnamed union at C
}

struct Tiff_hdr {
	t_order  Ushort
	magic    Ushort
	ifd      int
	pad      Ushort
	ntag     Ushort
	tag      [23]Libraw_tiff_tag
	nextifd  int
	pad2     Ushort
	nexif    Ushort
	exif     [4]Libraw_tiff_tag
	pad3     Ushort
	ngps     Ushort
	gpst     [10]Libraw_tiff_tag
	bps      [4]i16
	rat      [10]int
	gps      [26]u32
	t_desc   [512]i8
	t_make   [64]i8
	t_model  [64]i8
	soft     [32]i8
	date     [20]i8
	t_artist [64]i8
}
