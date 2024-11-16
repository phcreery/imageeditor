module cimgui

import libs.cimgui.c as _

@[typedef]
struct C.va_list {}

fn C.va_arg(voidptr, voidptr) voidptr
