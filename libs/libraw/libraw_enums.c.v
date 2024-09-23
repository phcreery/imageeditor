module libraw


// -* C++ -*
// *File: libraw_const.h
// *Copyright 2008-2024 LibRaw LLC (info@libraw.org)
// *Created: Sat Mar  8 , 2008
// *LibRaw error codes
//LibRaw is free software; you can redistribute it and/or modify
//it under the terms of the one of two licenses as you choose:
//
//1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
//   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).
//
//2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
//   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).
//
// 
// limit allocation size, default is 2Gb 
// limit thumbnail size, default is 512Mb
// Check if enough file space exists before tag read 
// LibRaw uses own memory pool management, with LIBRAW_MSIZE (512)
//entries. It is enough for parsing/decoding non-damaged files, but
//may overflow on specially crafted files (eg. with many string values
//like XMP blocks.
//LIBRAW_MEMPOOL_CHECK define will result in error on pool overflow 
enum LibRaw_openbayer_patterns {
	libraw_openbayer_rggb = 148
	libraw_openbayer_bggr = 22
	libraw_openbayer_grbg = 97
	libraw_openbayer_gbrg = 73
}

enum LibRaw_dngfields_marks {
	libraw_dngfm_forwardmatrix = 1
	libraw_dngfm_illuminant = 1 << 1
	libraw_dngfm_colormatrix = 1 << 2
	libraw_dngfm_calibration = 1 << 3
	libraw_dngfm_analogbalance = 1 << 4
	libraw_dngfm_black = 1 << 5
	libraw_dngfm_white = 1 << 6
	libraw_dngfm_opcode_2 = 1 << 7
	libraw_dngfm_lintable = 1 << 8
	libraw_dngfm_croporigin = 1 << 9
	libraw_dngfm_cropsize = 1 << 10
	libraw_dngfm_previewcs = 1 << 11
	libraw_dngfm_asshotneutral = 1 << 12
	libraw_dngfm_baselineexposure = 1 << 13
	libraw_dngfm_linearresponselimit = 1 << 14
	libraw_dngfm_usercrop = 1 << 15
	libraw_dngfm_opcode_1 = 1 << 16
	libraw_dngfm_opcode_3 = 1 << 17
}

enum LibRaw_As_Shot_WB_Applied_codes {
	libraw_aswb_applied = 1
	libraw_aswb_canon = 2
	libraw_aswb_nikon = 4
	libraw_aswb_nikon_sraw = 8
	libraw_aswb_pentax = 16
	libraw_aswb_sony = 32
}

enum LibRaw_ExifTagTypes {
	libraw_exiftag_type_unknown = 0
	libraw_exiftag_type_byte = 1
	libraw_exiftag_type_ascii = 2
	libraw_exiftag_type_short = 3
	libraw_exiftag_type_long = 4
	libraw_exiftag_type_rational = 5
	libraw_exiftag_type_sbyte = 6
	libraw_exiftag_type_undefined = 7
	libraw_exiftag_type_sshort = 8
	libraw_exiftag_type_slong = 9
	libraw_exiftag_type_srational = 10
	libraw_exiftag_type_float = 11
	libraw_exiftag_type_double = 12
	libraw_exiftag_type_ifd = 13
	libraw_exiftag_type_unicode = 14
	libraw_exiftag_type_complex = 15
	libraw_exiftag_type_long_8 = 16
	libraw_exiftag_type_slong_8 = 17
	libraw_exiftag_type_ifd_8 = 18
}

enum LibRaw_whitebalance_code {
// clang-format off
//
//      EXIF light sources
//      12 = FL-D; Daylight fluorescent (D 5700K â 7100K) (F1,F5)
//      13 = FL-N; Day white fluorescent (N 4600K â 5400K) (F7,F8)
//      14 = FL-W; Cool white fluorescent (W 3900K â 4500K) (F2,F6, office, store, warehouse)
//      15 = FL-WW; White fluorescent (WW 3200K â 3700K) (F3, residential)
//      16 = FL-L; Soft/Warm white fluorescent (L 2600K - 3250K) (F4, kitchen, bath)
//  
//clang-format on
	libraw_wbi_unknown = 0
	libraw_wbi_daylight = 1
	libraw_wbi_fluorescent = 2
	libraw_wbi_tungsten = 3
	libraw_wbi_flash = 4
	libraw_wbi_fine_weather = 9
	libraw_wbi_cloudy = 10
	libraw_wbi_shade = 11
	libraw_wbi_fl_d = 12
	libraw_wbi_fl_n = 13
	libraw_wbi_fl_w = 14
	libraw_wbi_fl_ww = 15
	libraw_wbi_fl_l = 16
	libraw_wbi_ill_a = 17
	libraw_wbi_ill_b = 18
	libraw_wbi_ill_c = 19
	libraw_wbi_d55 = 20
	libraw_wbi_d65 = 21
	libraw_wbi_d75 = 22
	libraw_wbi_d50 = 23
	libraw_wbi_studio_tungsten = 24
	libraw_wbi_sunset = 64
	libraw_wbi_underwater = 65
	libraw_wbi_fluorescent_high = 66
	libraw_wbi_ht_mercury = 67
	libraw_wbi_as_shot = 81
	libraw_wbi_auto = 82
	libraw_wbi_custom = 83
	libraw_wbi_auto1 = 85
	libraw_wbi_auto2 = 86
	libraw_wbi_auto3 = 87
	libraw_wbi_auto4 = 88
	libraw_wbi_custom1 = 90
	libraw_wbi_custom2 = 91
	libraw_wbi_custom3 = 92
	libraw_wbi_custom4 = 93
	libraw_wbi_custom5 = 94
	libraw_wbi_custom6 = 95
	libraw_wbi_pc_set1 = 96
	libraw_wbi_pc_set2 = 97
	libraw_wbi_pc_set3 = 98
	libraw_wbi_pc_set4 = 99
	libraw_wbi_pc_set5 = 100
	libraw_wbi_measured = 110
	libraw_wbi_bw = 120
	libraw_wbi_kelvin = 254
	libraw_wbi_other = 255
	libraw_wbi_none = 65535
}

enum LibRaw_MultiExposure_related {
	libraw_me_none = 0
	libraw_me_simple = 1
	libraw_me_overlay = 2
	libraw_me_hdr = 3
}

enum LibRaw_dng_processing {
	libraw_dng_none = 0
	libraw_dng_float = 1
	libraw_dng_linear = 2
	libraw_dng_deflate = 4
	libraw_dng_xtrans = 8
	libraw_dng_other = 16
	libraw_dng_8_bit = 32
//LIBRAW_DNG_LARGERANGE=64,
// more than 16 bit integer 
	// libraw_dng_all = libraw_dng_float | libraw_dng_linear | libraw_dng_deflate | libraw_dng_xtrans | libraw_dng_8_bit | libraw_dng_other
// |LIBRAW_DNG_LARGERANGE 
	// libraw_dng_default = libraw_dng_float | libraw_dng_linear | libraw_dng_deflate | libraw_dng_8_bit
}

enum LibRaw_output_flags {
	libraw_output_flags_none = 0
	libraw_output_flags_ppmmeta = 1
}

enum LibRaw_runtime_capabilities {
	libraw_caps_rawspeed = 1
	libraw_caps_dngsdk = 1 << 1
	libraw_caps_gprsdk = 1 << 2
	libraw_caps_unicodepaths = 1 << 3
	libraw_caps_x3_ftools = 1 << 4
	libraw_caps_rpi_6_by_9 = 1 << 5
	libraw_caps_zlib = 1 << 6
	libraw_caps_jpeg = 1 << 7
	libraw_caps_rawspeed_3 = 1 << 8
	libraw_caps_rawspeed_bits = 1 << 9
}

enum LibRaw_colorspace {
	libraw_colorspace_not_found = 0
	libraw_colorspace_s_rgb
	libraw_colorspace_adobe_rgb
	libraw_colorspace_wide_gamut_rgb
	libraw_colorspace_pro_photo_rgb
	libraw_colorspace_icc
	libraw_colorspace_uncalibrated
// Tag 0x0001 InteropIndex containing "R03" + LIBRAW_COLORSPACE_Uncalibrated = Adobe RGB
	libraw_colorspace_camera_linear_uni_wb
	libraw_colorspace_camera_linear
	libraw_colorspace_camera_gamma_uni_wb
	libraw_colorspace_camera_gamma
	libraw_colorspace_monochrome_linear
	libraw_colorspace_monochrome_gamma
	libraw_colorspace_rec2020
	libraw_colorspace_unknown = 255
}

enum LibRaw_cameramaker_index {
	libraw_cameramaker_unknown = 0
	libraw_cameramaker_agfa
	libraw_cameramaker_alcatel
	libraw_cameramaker_apple
	libraw_cameramaker_aptina
	libraw_cameramaker_avt
	libraw_cameramaker_baumer
	libraw_cameramaker_broadcom
	libraw_cameramaker_canon
	libraw_cameramaker_casio
	libraw_cameramaker_cine
	libraw_cameramaker_clauss
	libraw_cameramaker_contax
	libraw_cameramaker_creative
	libraw_cameramaker_dji
	libraw_cameramaker_dxo
	libraw_cameramaker_epson
	libraw_cameramaker_foculus
	libraw_cameramaker_fujifilm
	libraw_cameramaker_generic
	libraw_cameramaker_gione
	libraw_cameramaker_gitup
	libraw_cameramaker_google
	libraw_cameramaker_go_pro
	libraw_cameramaker_hasselblad
	libraw_cameramaker_htc
	libraw_cameramaker_i_mobile
	libraw_cameramaker_imacon
	libraw_cameramaker_jk_imaging
	libraw_cameramaker_kodak
	libraw_cameramaker_konica
	libraw_cameramaker_leaf
	libraw_cameramaker_leica
	libraw_cameramaker_lenovo
	libraw_cameramaker_lg
	libraw_cameramaker_logitech
	libraw_cameramaker_mamiya
	libraw_cameramaker_matrix
	libraw_cameramaker_meizu
	libraw_cameramaker_micron
	libraw_cameramaker_minolta
	libraw_cameramaker_motorola
	libraw_cameramaker_ngm
	libraw_cameramaker_nikon
	libraw_cameramaker_nokia
	libraw_cameramaker_olympus
	libraw_cameramaker_omni_vison
	libraw_cameramaker_panasonic
	libraw_cameramaker_parrot
	libraw_cameramaker_pentax
	libraw_cameramaker_phase_one
	libraw_cameramaker_photo_control
	libraw_cameramaker_photron
	libraw_cameramaker_pixelink
	libraw_cameramaker_polaroid
	libraw_cameramaker_red
	libraw_cameramaker_ricoh
	libraw_cameramaker_rollei
	libraw_cameramaker_rover_shot
	libraw_cameramaker_samsung
	libraw_cameramaker_sigma
	libraw_cameramaker_sinar
	libraw_cameramaker_sm_a_l
	libraw_cameramaker_sony
	libraw_cameramaker_st_micro
	libraw_cameramaker_thl
	libraw_cameramaker_vluu
	libraw_cameramaker_xiaomi
	libraw_cameramaker_xiaoyi
	libraw_cameramaker_yi
	libraw_cameramaker_yuneec
	libraw_cameramaker_zeiss
	libraw_cameramaker_one_plus
	libraw_cameramaker_isg
	libraw_cameramaker_vivo
	libraw_cameramaker_hmd_global
	libraw_cameramaker_huawei
	libraw_cameramaker_raspberry_pi
	libraw_cameramaker_om_digital
// Insert additional indexes here
	libraw_cameramaker_the_last_one
}

enum LibRaw_camera_mounts {
	libraw_mount_unknown = 0
	libraw_mount_alpa
	libraw_mount_c
// C-mount 
	libraw_mount_canon_ef_m
	libraw_mount_canon_ef_s
	libraw_mount_canon_ef
	libraw_mount_canon_rf
	libraw_mount_contax_n
	libraw_mount_contax645
	libraw_mount_ft
// original 4/3 
	libraw_mount_m_ft
// micro 4/3 
	libraw_mount_fuji_gf
// Fujifilm GFX cameras, G mount 
	libraw_mount_fuji_gx
// Fujifilm GX680 
	libraw_mount_fuji_x
	libraw_mount_hasselblad_h
// Hasselblad Hn cameras, HC & HCD lenses 
	libraw_mount_hasselblad_v
	libraw_mount_hasselblad_xcd
// Hasselblad Xn cameras, XCD lenses 
	libraw_mount_leica_m
// Leica rangefinder bayonet 
	libraw_mount_leica_r
// Leica SLRs, 'R' for reflex 
	libraw_mount_leica_s
// LIBRAW_FORMAT_LeicaS 'MF' 
	libraw_mount_leica_sl
// lens, mounts on 'L' throat, FF 
	libraw_mount_leica_tl
// lens, mounts on 'L' throat, APS-C 
	libraw_mount_lps_l
// Leica/Panasonic/Sigma camera mount, takes L, SL and TL lenses 
	libraw_mount_mamiya67
// Mamiya RB67, RZ67 
	libraw_mount_mamiya645
	libraw_mount_minolta_a
	libraw_mount_nikon_cx
// used in 'Nikon 1' series 
	libraw_mount_nikon_f
	libraw_mount_nikon_z
	libraw_mount_phase_one_i_xm_mv
	libraw_mount_phase_one_i_xm_rs
	libraw_mount_phase_one_i_xm
	libraw_mount_pentax_645
	libraw_mount_pentax_k
	libraw_mount_pentax_q
	libraw_mount_ricoh_module
	libraw_mount_rollei_bayonet
// Rollei Hy-6: Leaf AFi, Sinar Hy6- models 
	libraw_mount_samsung_nx_m
	libraw_mount_samsung_nx
	libraw_mount_sigma_x3_f
	libraw_mount_sony_e
	libraw_mount_lf
	libraw_mount_digital_back
	libraw_mount_fixed_lens
	libraw_mount_il_um
// Interchangeable lens, mount unknown 
	libraw_mount_the_last_one
}

enum LibRaw_camera_formats {
	libraw_format_unknown = 0
	libraw_format_apsc
	libraw_format_ff
	libraw_format_mf
	libraw_format_apsh
	libraw_format_1_inch
	libraw_format_1div2p3_inch
// 1/2.3" 
	libraw_format_1div1p7_inch
// 1/1.7" 
	libraw_format_ft
// sensor size in FT & mFT cameras 
	libraw_format_crop_645
// 44x33mm 
	libraw_format_leica_s
// 'MF' Leicas 
	libraw_format_645
	libraw_format_66
	libraw_format_69
	libraw_format_lf
	libraw_format_leica_dmr
	libraw_format_67
	libraw_format_sigma_apsc
// DP1, DP2, SD15, SD14, SD10, SD9 
	libraw_format_sigma_merrill
// SD1,  'SD1 Merrill',  'DP1 Merrill',  'DP2 Merrill' 
	libraw_format_sigma_apsh
// 'sd Quattro H' 
	libraw_format_3648
// DALSA FTF4052C (Mamiya ZD) 
	libraw_format_68
// Fujifilm GX680 
	libraw_format_the_last_one
}

enum LibRawImageAspects {
	libraw_image_aspect_unknown = 0
	libraw_image_aspect_other = 1
	libraw_image_aspect_minimal_real_aspect_value = 99
// 1:10
	libraw_image_aspect_maximal_real_aspect_value = 10000
// 10: 1
// Value:  width / height * 1000
	libraw_image_aspect_3to2 = 1000 * 3 / 2
	libraw_image_aspect_1to1 = 1000
	libraw_image_aspect_4to3 = 1000 * 4 / 3
	libraw_image_aspect_16to9 = 1000 * 16 / 9
//LIBRAW_IMAGE_ASPECT_6to6, // what is the difference with 1:1 ?
	libraw_image_aspect_5to4 = 1000 * 5 / 4
	libraw_image_aspect_7to6 = 1000 * 7 / 6
	libraw_image_aspect_6to5 = 1000 * 6 / 5
	libraw_image_aspect_7to5 = 1000 * 7 / 5
}

enum LibRaw_lens_focal_types {
	libraw_ft_undefined = 0
	libraw_ft_prime_lens = 1
	libraw_ft_zoom_lens = 2
	libraw_ft_zoom_lens_constant_aperture = 3
	libraw_ft_zoom_lens_variable_aperture = 4
}

enum LibRaw_Canon_RecordModes {
	libraw_canon_record_mode_undefined = 0
	libraw_canon_record_mode_jpeg
	libraw_canon_record_mode_crw_thm
	libraw_canon_record_mode_avi_thm
	libraw_canon_record_mode_tif
	libraw_canon_record_mode_tif_jpeg
	libraw_canon_record_mode_cr_2
	libraw_canon_record_mode_cr_2_jpeg
	libraw_canon_record_mode_unknown
	libraw_canon_record_mode_mov
	libraw_canon_record_mode_mp_4
	libraw_canon_record_mode_crm
	libraw_canon_record_mode_cr_3
	libraw_canon_record_mode_cr_3_jpeg
	libraw_canon_record_mode_heif
	libraw_canon_record_mode_cr_3_heif
	libraw_canon_record_mode_the_last_one
}

enum LibRaw_minolta_storagemethods {
	libraw_minolta_unpacked = 82
	libraw_minolta_packed = 89
}

enum LibRaw_minolta_bayerpatterns {
	libraw_minolta_rggb = 1
	libraw_minolta_g2_brg_1 = 4
}

enum LibRaw_sony_cameratypes {
	libraw_sony_dsc = 1
	libraw_sony_dslr = 2
	libraw_sony_nex = 3
	libraw_sony_slt = 4
	libraw_sony_ilce = 5
	libraw_sony_ilca = 6
	libraw_sony_camera_type_unknown = 65535
}

enum LibRaw_Sony_0x2010_Type {
	libraw_sony_tag2010_none = 0
	libraw_sony_tag2010a
	libraw_sony_tag2010b
	libraw_sony_tag2010c
	libraw_sony_tag2010d
	libraw_sony_tag2010e
	libraw_sony_tag2010f
	libraw_sony_tag2010g
	libraw_sony_tag2010h
	libraw_sony_tag2010i
}

enum LibRaw_Sony_0x9050_Type {
	libraw_sony_tag9050_none = 0
	libraw_sony_tag9050a
	libraw_sony_tag9050b
	libraw_sony_tag9050c
	libraw_sony_tag9050d
}

enum LIBRAW_SONY_FOCUSMODEmodes {
	libraw_sony_focusmode_mf = 0
	libraw_sony_focusmode_af_s = 2
	libraw_sony_focusmode_af_c = 3
	libraw_sony_focusmode_af_a = 4
	libraw_sony_focusmode_dmf = 6
	libraw_sony_focusmode_af_d = 7
	libraw_sony_focusmode_af = 101
	libraw_sony_focusmode_permanent_af = 104
	libraw_sony_focusmode_semi_mf = 105
	libraw_sony_focusmode_unknown = -1
}

enum LibRaw_KodakSensors {
	libraw_kodak_unknown_sensor = 0
	libraw_kodak_m1 = 1
	libraw_kodak_m15 = 2
	libraw_kodak_m16 = 3
	libraw_kodak_m17 = 4
	libraw_kodak_m2 = 5
	libraw_kodak_m23 = 6
	libraw_kodak_m24 = 7
	libraw_kodak_m3 = 8
	libraw_kodak_m5 = 9
	libraw_kodak_m6 = 10
	libraw_kodak_c14 = 11
	libraw_kodak_x14 = 12
	libraw_kodak_m11 = 13
}

enum LibRaw_HasselbladFormatCodes {
	libraw_hf_unknown = 0
	libraw_hf_3_fr
	libraw_hf_fff
	libraw_hf_imacon
	libraw_hf_hasselblad_dng
	libraw_hf_adobe_dng
	libraw_hf_adobe_dng_from_phocus_dng
}

enum LibRaw_rawspecial_t {
	libraw_rawspecial_sonyarw_2_none = 0
	libraw_rawspecial_sonyarw_2_baseonly = 1
	libraw_rawspecial_sonyarw_2_deltaonly = 1 << 1
	libraw_rawspecial_sonyarw_2_deltazerobase = 1 << 2
	libraw_rawspecial_sonyarw_2_deltatovalue = 1 << 3
	// libraw_rawspecial_sonyarw_2_allflags = libraw_rawspecial_sonyarw_2_baseonly + libraw_rawspecial_sonyarw_2_deltaonly + libraw_rawspecial_sonyarw_2_deltazerobase + libraw_rawspecial_sonyarw_2_deltatovalue
	libraw_rawspecial_nodp_2_q_interpolaterg = 1 << 4
	libraw_rawspecial_nodp_2_q_interpolateaf = 1 << 5
	libraw_rawspecial_sraw_no_rgb = 1 << 6
	libraw_rawspecial_sraw_no_interpolate = 1 << 7
}

enum LibRaw_rawspeed_bits_t {
	libraw_rawspeedv_1_use = 1
	libraw_rawspeedv_1_failonunknown = 1 << 1
	libraw_rawspeedv_1_ignoreerrors = 1 << 2
//  bits 3-7 are reserved
	libraw_rawspeedv_3_use = 1 << 8
	libraw_rawspeedv_3_failonunknown = 1 << 9
	libraw_rawspeedv_3_ignoreerrors = 1 << 10
}

enum LibRaw_processing_options {
	libraw_rawoptions_pentax_ps_allframes = 1
	libraw_rawoptions_convertfloat_to_int = 1 << 1
	libraw_rawoptions_arq_skip_channel_swap = 1 << 2
	libraw_rawoptions_no_rotate_for_kodak_thumbnails = 1 << 3
//  LIBRAW_RAWOPTIONS_USE_DNG_DEFAULT_CROP = 1 << 4,
	libraw_rawoptions_use_ppm_16_thumbs = 1 << 5
	libraw_rawoptions_dont_check_dng_illuminant = 1 << 6
	libraw_rawoptions_dngsdk_zerocopy = 1 << 7
	libraw_rawoptions_zerofilters_for_monochrometiffs = 1 << 8
	libraw_rawoptions_dng_add_enhanced = 1 << 9
	libraw_rawoptions_dng_add_previews = 1 << 10
	libraw_rawoptions_dng_prefer_largest_image = 1 << 11
	libraw_rawoptions_dng_stage_2 = 1 << 12
	libraw_rawoptions_dng_stage_3 = 1 << 13
	libraw_rawoptions_dng_allowsizechange = 1 << 14
	libraw_rawoptions_dng_disablewbadjust = 1 << 15
	libraw_rawoptions_provide_nonstandard_wb = 1 << 16
	libraw_rawoptions_camerawb_fallback_to_daylight = 1 << 17
	libraw_rawoptions_check_thumbnails_known_vendors = 1 << 18
	libraw_rawoptions_check_thumbnails_all_vendors = 1 << 19
	libraw_rawoptions_dng_stage_2_ifpresent = 1 << 20
	libraw_rawoptions_dng_stage_3_ifpresent = 1 << 21
	libraw_rawoptions_dng_add_masks = 1 << 22
	libraw_rawoptions_canon_ignore_makernotes_rotation = 1 << 23
	libraw_rawoptions_allow_jpegxl_previews = 1 << 24
}

enum LibRaw_decoder_flags {
	libraw_decoder_hascurve = 1 << 4
	libraw_decoder_sonyarw_2 = 1 << 5
	libraw_decoder_tryrawspeed = 1 << 6
	libraw_decoder_ownalloc = 1 << 7
	libraw_decoder_fixedmaxc = 1 << 8
	libraw_decoder_adobecopypixel = 1 << 9
	libraw_decoder_legacy_with_margins = 1 << 10
	libraw_decoder_3_channel = 1 << 11
	// libraw_decoder_sinar_4_shot = 1 << 11
	libraw_decoder_flatdata = 1 << 12
	libraw_decoder_flat_bg_2_swapped = 1 << 13
	libraw_decoder_unsupported_format = 1 << 14
	libraw_decoder_notset = 1 << 15
	libraw_decoder_tryrawspeed_3 = 1 << 16
}

enum LibRaw_constructor_flags {
	libraw_options_none = 0
	libraw_options_no_dataerr_callback = 1 << 1
// Compatibility w/ years old typo 
	// libraw_opions_no_dataerr_callback = libraw_options_no_dataerr_callback
}

enum LibRaw_warnings {
	libraw_warn_none = 0
	libraw_warn_bad_camera_wb = 1 << 2
	libraw_warn_no_metadata = 1 << 3
	libraw_warn_no_jpeglib = 1 << 4
	libraw_warn_no_embedded_profile = 1 << 5
	libraw_warn_no_input_profile = 1 << 6
	libraw_warn_bad_output_profile = 1 << 7
	libraw_warn_no_badpixelmap = 1 << 8
	libraw_warn_bad_darkframe_file = 1 << 9
	libraw_warn_bad_darkframe_dim = 1 << 10
	libraw_warn_rawspeed_problem = 1 << 12
	libraw_warn_rawspeed_unsupported = 1 << 13
	libraw_warn_rawspeed_processed = 1 << 14
	libraw_warn_fallback_to_ahd = 1 << 15
	libraw_warn_parsefuji_processed = 1 << 16
	libraw_warn_dngsdk_processed = 1 << 17
	libraw_warn_dng_images_reordered = 1 << 18
	libraw_warn_dng_stage_2_applied = 1 << 19
	libraw_warn_dng_stage_3_applied = 1 << 20
	libraw_warn_rawspeed_3_problem = 1 << 21
	libraw_warn_rawspeed_3_unsupported = 1 << 22
	libraw_warn_rawspeed_3_processed = 1 << 23
	libraw_warn_rawspeed_3_notlisted = 1 << 24
	libraw_warn_vendor_crop_suggested = 1 << 25
}

enum LibRaw_exceptions {
	libraw_exception_none = 0
	libraw_exception_alloc = 1
	libraw_exception_decode_raw = 2
	libraw_exception_decode_jpeg = 3
	libraw_exception_io_eof = 4
	libraw_exception_io_corrupt = 5
	libraw_exception_cancelled_by_callback = 6
	libraw_exception_bad_crop = 7
	libraw_exception_io_badfile = 8
	libraw_exception_decode_jpeg_2000 = 9
	libraw_exception_toobig = 10
	libraw_exception_mempool = 11
	libraw_exception_unsupported_format = 12
}

pub enum LibRaw_progress {
	libraw_progress_start = 0
	libraw_progress_open = 1
	libraw_progress_identify = 1 << 1
	libraw_progress_size_adjust = 1 << 2
	libraw_progress_load_raw = 1 << 3
	libraw_progress_raw_2_image = 1 << 4
	libraw_progress_remove_zeroes = 1 << 5
	libraw_progress_bad_pixels = 1 << 6
	libraw_progress_dark_frame = 1 << 7
	libraw_progress_foveon_interpolate = 1 << 8
	libraw_progress_scale_colors = 1 << 9
	libraw_progress_pre_interpolate = 1 << 10
	libraw_progress_interpolate = 1 << 11
	libraw_progress_mix_green = 1 << 12
	libraw_progress_median_filter = 1 << 13
	libraw_progress_highlights = 1 << 14
	libraw_progress_fuji_rotate = 1 << 15
	libraw_progress_flip = 1 << 16
	libraw_progress_apply_profile = 1 << 17
	libraw_progress_convert_rgb = 1 << 18
	libraw_progress_stretch = 1 << 19
// reserved 
	libraw_progress_stage_20 = 1 << 20
	libraw_progress_stage_21 = 1 << 21
	libraw_progress_stage_22 = 1 << 22
	libraw_progress_stage_23 = 1 << 23
	libraw_progress_stage_24 = 1 << 24
	libraw_progress_stage_25 = 1 << 25
	libraw_progress_stage_26 = 1 << 26
	libraw_progress_stage_27 = 1 << 27
	libraw_progress_thumb_load = 1 << 28
	libraw_progress_treserved_1 = 1 << 29
	libraw_progress_treserved_2 = 1 << 30
}

// pub type LibRaw_progress = C.LibRaw_progress

enum LibRaw_errors {
	libraw_success = 0
	libraw_unspecified_error = -1
	libraw_file_unsupported = -2
	libraw_request_for_nonexistent_image = -3
	libraw_out_of_order_call = -4
	libraw_no_thumbnail = -5
	libraw_unsupported_thumbnail = -6
	libraw_input_closed = -7
	libraw_not_implemented = -8
	libraw_request_for_nonexistent_thumbnail = -9
	libraw_unsufficient_memory = -100007
	libraw_data_error = -100008
	libraw_io_error = -100009
	libraw_cancelled_by_callback = -100010
	libraw_bad_crop = -100011
	libraw_too_big = -100012
	libraw_mempool_overflow = -100013
}

enum LibRaw_internal_thumbnail_formats {
	libraw_internal_thumbnail_unknown = 0
	libraw_internal_thumbnail_kodak_thumb = 1
	libraw_internal_thumbnail_kodak_ycbcr = 2
	libraw_internal_thumbnail_kodak_rgb = 3
	libraw_internal_thumbnail_jpeg = 4
	libraw_internal_thumbnail_layer
	libraw_internal_thumbnail_rollei
	libraw_internal_thumbnail_ppm
	libraw_internal_thumbnail_ppm_16
	libraw_internal_thumbnail_x3_f
	libraw_internal_thumbnail_dng_ycbcr
	libraw_internal_thumbnail_jpegxl
}

enum LibRaw_thumbnail_formats {
	libraw_thumbnail_unknown = 0
	libraw_thumbnail_jpeg = 1
	libraw_thumbnail_bitmap = 2
	libraw_thumbnail_bitmap_16 = 3
	libraw_thumbnail_layer = 4
	libraw_thumbnail_rollei = 5
	libraw_thumbnail_h265 = 6
	libraw_thumbnail_jpegxl = 7
}

enum INT64 {
	libraw_image_jpeg = 1
	libraw_image_bitmap = 2
}