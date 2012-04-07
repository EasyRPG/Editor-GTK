dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.68])

AC_INIT([easyrpg-editor], [0.1.0])

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_VALAC([0.14.0])

PKG_CHECK_MODULES(EASYRPG_EDITOR, [
	glib-2.0
	gio-2.0
	gtk+-3.0
])

AC_CONFIG_FILES([
Makefile
src/Makefile
])
AC_OUTPUT
