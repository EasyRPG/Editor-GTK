dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard.

AC_INIT(editor, SVN)
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

AC_PROG_CC



dnl Check for vala
AM_PROG_VALAC([0.14.0])


PKG_CHECK_MODULES(EDITOR,
[gtk+-3.0 ])


AC_OUTPUT([
Makefile
src/Makefile

])
