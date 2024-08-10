#!/bin/ksh -p
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (c) 1999, 2011, Oracle and/or its affiliates. All rights reserved.
#
# Based on the nightly script from the integration folks,
# Mostly modified and owned by mike_s.
# Changes also by kjc, dmk.
#
# BRINGOVER_WS may be specified in the env file.
# The default is the old behavior of CLONE_WS
#
# -i on the command line, means fast options, so when it's on the
# command line (only), lint and check builds are skipped no matter what
# the setting of their individual flags are in NIGHTLY_OPTIONS.
#
# LINTDIRS can be set in the env file, format is a list of:
#
#	/dirname-to-run-lint-on flag
#
#	Where flag is:	y - enable lint noise diff output
#			n - disable lint noise diff output
#
#	For example: LINTDIRS="$SRC/uts n $SRC/stand y $SRC/psm y"
#
# OPTHOME and TEAMWARE may be set in the environment to override /opt
# and /opt/teamware defaults.
#

#
# The CDPATH variable causes ksh's `cd' builtin to emit messages to stdout
# under certain circumstances, which can really screw things up; unset it.
#
unset CDPATH

# Get the absolute path of the nightly script that the user invoked.  This
# may be a relative path, and we need to do this before changing directory.
nightly_path=`whence $0`
nightly_ls="`ls -l $nightly_path`"

#
# Keep track of where we found nightly so we can invoke the matching
# which_scm script.  If that doesn't work, don't go guessing, just rely
# on the $PATH settings, which will generally give us either /opt/onbld
# or the user's workspace.
#
WHICH_SCM=$(dirname $nightly_path)/which_scm
if [[ ! -x $WHICH_SCM ]]; then
	WHICH_SCM=which_scm
fi

#
# Datestamp for crypto tarballs.  We don't use BUILD_DATE because it
# doesn't sort right and it uses English abbreviations for the month.
# We want to guarantee a consistent string, so just invoke date(1)
# once and save the result in a global variable.  YYYY-MM-DD is easier
# to parse visually than YYYYMMDD.
#
cryptostamp=$(date +%Y-%m-%d)

#
# Echo the path for depositing a crypto tarball, creating the target
# directory if it doesn't already exist.
# usage: cryptodest suffix
# where "suffix" is "" or "-nd".
#
function cryptodest {
	typeset suffix=$1
	#
	# $PKGARCHIVE gets wiped out with each build, so put the
	# tarball one level up.
	#
	typeset dir=$(dirname "$PKGARCHIVE")
	[ -d "$dir" ] || mkdir -p "$dir" >> "$LOGFILE" 2>&1
	#
	# Put the suffix after the datestamp to make it easier for
	# gatelings to use crypto from a specific date (no need to
	# copy and rename the gate tarball).
	#
	echo "$dir/on-crypto-$cryptostamp$suffix.$MACH.tar"
}

#
# Create a non-stamped symlink to the given crypto tarball.
# Return 0 on success, non-zero on failure.
#
function cryptolink {
	typeset targpath=$1
	typeset suffix=$2
	if [ ! -f "$targpath" ]; then
		echo "no crypto at $targpath"
		return 1
	fi
	typeset dir=$(dirname "$targpath")
	typeset targfile=$(basename "$targpath")
	typeset link=on-crypto$suffix.$MACH.tar.bz2
	(cd "$dir"; rm -f "$link")
	(cd "$dir"; ln -s "$targfile" "$link")
	return $?
}

#
# Generate a crypto tarball from the proto area and put it in the
# canonical location, along with the datestamp-free symlink.
# Sets build_ok to "n" if there is a problem.
#
function crypto_from_proto {
	typeset label=$1
	typeset suffix=$2
	typeset -i stat
	typeset to

	echo "Creating $label crypto tarball..." >> "$LOGFILE"

	#
	# Generate the crypto THIRDPARTYLICENSE file.  This needs to
	# be done after the build has finished and before we run
	# cryptodrop.  We'll generate the file twice if we're building
	# both DEBUG and non-DEBUG, but it's a cheap operation and not
	# worth the complexity to only do once.
	#
	if [ -d ${ROOT}${suffix}/licenses/usr ]; then
		( cd ${ROOT}${suffix}/licenses ; \
		    mktpl -c $SRC/pkg/license-list ) >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create crypto THIRDPARTYLICENSE files" |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
			build_ok=n
			return
		fi
	else
		echo "No licenses found under ${ROOT}${suffix}/licenses" |
		    tee -a "$mail_msg_file" >> "$LOGFILE"
	fi

	to=$(cryptodest "$suffix")
	if [ "$suffix" = "-nd" ]; then
		cryptodrop -n "$to" >> "$LOGFILE" 2>&1
	else
		cryptodrop "$to" >> "$LOGFILE" 2>&1
	fi
	if (( $? != 0 )) ; then
		echo "\nCould not create $label crypto tarball." |
		   tee -a "$mail_msg_file" >> "$LOGFILE"
		build_ok=n
	else
		cryptolink "$to.bz2" "$suffix" >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			build_ok=n
		fi
	fi
}

#
# Function to do a DEBUG and non-DEBUG build. Needed because we might
# need to do another for the source build, and since we only deliver DEBUG or
# non-DEBUG packages.
#
# usage: normal_build
#
function normal_build {

	typeset orig_p_FLAG="$p_FLAG"
	typeset crypto_in="$ON_CRYPTO_BINS"
	typeset crypto_signer="$CODESIGN_USER"
	typeset gencrypto=no

	suffix=""
	[ -n "$CODESIGN_USER" ] && gencrypto=yes

	# non-DEBUG build begins

	if [ "$F_FLAG" = "n" ]; then
		set_non_debug_build_flags
		if [ "$P_FLAG" = "y" ]; then
			buildlabel="PARFAIT-non-DEBUG"
			PARFAITLOGDIR=$ATLOG/parfait_analysis_${MACH}-nd
			mkdir -p ${PARFAITLOGDIR}
		else
			buildlabel="non-DEBUG"
		fi
		CODESIGN_USER="$crypto_signer" \
		    build $buildlabel "$suffix-nd" "-nd" "$MULTI_PROTO" \
		    $(ndcrypto "$crypto_in")

		if [[ "$gencrypto" = yes && "$build_ok" = y ]]; then
			crypto_from_proto non-DEBUG -nd
		fi
		[[ "$P_FLAG" = "y" ]] && parfait_analyse "-nd" "NON-DEBUG"
	else
		echo "\n==== No non-DEBUG $open_only build ====\n" >> "$LOGFILE"
	fi

	# non-DEBUG build ends

	# DEBUG build begins

	if [ "$D_FLAG" = "y" ]; then
		set_debug_build_flags
		if [ "$P_FLAG" = "y" ]; then
			buildlabel="PARFAIT-DEBUG"
			PARFAITLOGDIR=$ATLOG/parfait_analysis_${MACH}
			mkdir -p ${PARFAITLOGDIR}
		else
			buildlabel="DEBUG"
		fi
		CODESIGN_USER="$crypto_signer" \
		    build $buildlabel "$suffix" "" "$MULTI_PROTO" "$crypto_in"

		if [[ "$gencrypto" = yes && "$build_ok" = y ]]; then
			crypto_from_proto DEBUG ""
		fi
		[[ "$P_FLAG" = "y" ]] && parfait_analyse "" "DEBUG"
	else
		echo "\n==== No DEBUG $open_only build ====\n" >> "$LOGFILE"
	fi

	# DEBUG build ends

	p_FLAG="$orig_p_FLAG"
}

#
# usage: run_hook HOOKNAME ARGS...
#
# If variable "$HOOKNAME" is defined, insert a section header into 
# our logs and then run the command with ARGS. Return 1 to exit, 0 to continue.
#
function run_hook {
	HOOKNAME=$1
	typeset -r abrtfile=$TMPDIR/$HOOKNAME.abort
    	eval HOOKCMD=\$$HOOKNAME
	shift

	if [ -n "$HOOKCMD" ]; then 
		(
			echo "\n==== Running $HOOKNAME command: $HOOKCMD ====\n"
			( $HOOKCMD "$@" 2>&1 )
			if [ "$?" -ne 0 ]; then
				# Let exit status propagate up
				touch $abrtfile
			fi
		) | tee -a $mail_msg_file >> $LOGFILE

		if [ -f $abrtfile ]; then
			build_ok=n
			echo "\nAborting at request of $HOOKNAME" |
				tee -a $mail_msg_file >> $LOGFILE
			return 1
		fi
	fi
	return 0
}

#
# usage: filelist DESTDIR PATTERN
#
function filelist {
	DEST=$1
	PATTERN=$2
	cd ${DEST}

	OBJFILES=${ORIG_SRC}/xmod/obj_files
	if [ ! -f ${OBJFILES} ]; then
		return;
	fi
	for i in `grep -v '^#' ${OBJFILES} | \
	    grep ${PATTERN} | cut -d: -f2 | tr -d ' \t'`
	do
		# wildcard expansion
		for j in $i
		do
			if [ -f "$j" ]; then
				echo $j
			fi
			if [ -d "$j" ]; then
				echo $j
			fi
		done
	done | sort | uniq
}

# function to save off binaries after a full build for later
# restoration
function save_binaries {
	# save off list of binaries
	echo "\n==== Saving binaries from build at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	rm -f ${BINARCHIVE}
	cd ${CODEMGR_WS}
	filelist ${CODEMGR_WS} '^preserve:' >> $LOGFILE
	filelist ${CODEMGR_WS} '^preserve:' | \
	    cpio -ocB 2>/dev/null | compress \
	    > ${BINARCHIVE}
}

# delete files
# usage: hybridize_files DESTDIR MAKE_TARGET
function hybridize_files {
	DEST=$1
	MAKETARG=$2

	echo "\n==== Hybridizing files at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	for i in `filelist ${DEST} '^delete:'`
	do
		echo "removing ${i}." | tee -a $mail_msg_file >> $LOGFILE
		rm -rf "${i}"
	done
	for i in `filelist ${DEST} '^hybridize:' `
	do
		echo "hybridizing ${i}." | tee -a $mail_msg_file >> $LOGFILE
		rm -f ${i}+
		sed -e "/^# HYBRID DELETE START/,/^# HYBRID DELETE END/d" \
		    < ${i} > ${i}+
		mv ${i}+ ${i}
	done
}

# restore binaries into the proper source tree.
# usage: restore_binaries DESTDIR MAKE_TARGET
function restore_binaries {
	DEST=$1
	MAKETARG=$2

	echo "\n==== Restoring binaries to ${MAKETARG} at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	cd ${DEST}
	zcat ${BINARCHIVE} | \
	    cpio -idmucvB 2>/dev/null | tee -a $mail_msg_file >> ${LOGFILE}
}

# rename files we save binaries of
# usage: rename_files DESTDIR MAKE_TARGET
function rename_files {
	DEST=$1
	MAKETARG=$2
	echo "\n==== Renaming source files in ${MAKETARG} at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	for i in `filelist ${DEST} '^rename:'`
	do
		echo ${i} | tee -a $mail_msg_file >> ${LOGFILE}
		rm -f ${i}.export
		mv ${i} ${i}.export
	done
}

#
# Copy some or all of the source tree.
#
# Returns 0 for success, non-zero for failure.
#
# usage: copy_source CODEMGR_WS DESTDIR LABEL SRCROOT
#
function copy_source {
	WS=$1
	DEST=$2
	label=$3
	srcroot=$4

	printf "\n==== Creating %s source from %s (%s) ====\n\n" \
	    "$DEST" "$WS" "$label" | tee -a $mail_msg_file >> $LOGFILE

	printf "cleaning out %s\n" "$DEST." >> $LOGFILE
	rm -rf "$DEST" >> $LOGFILE 2>&1

	printf "creating %s\n" "$DEST." >> $LOGFILE
	mkdir -p "$DEST" 2>> $LOGFILE

	if (( $? != 0 )) ; then
		printf "failed to create %s\n" "$DEST" |
		    tee -a $mail_msg_file >> $LOGFILE
		build_ok=n
		return 1
	fi
	cd "$WS"

	printf "populating %s\n" "$DEST." >> $LOGFILE

	case "$SCM_TYPE" in
	teamware)
		find $srcroot -name 's\.*' -a -type f -print | \
		    sed -e 's,SCCS\/s.,,' | \
		    grep -v '/\.del-*' | \
		    cpio -pd $DEST >>$LOGFILE 2>&1
		if (( $? != 0 )) ; then
		    printf "cpio failed for %s\n" "$DEST" |
			tee -a $mail_msg_file >> $LOGFILE
		    build_ok=n
		    return 1
		fi
		;;
	mercurial)
		copy_source_mercurial $DEST $srcroot
		if (( $? != 0 )) ; then
		    build_ok=n
		    return 1
		fi
		;;
	*)
		build_ok=n
		echo "Tree copy is not supported for workspace type" \
		    "$SCM_TYPE" | tee -a $mail_msg_file >> $LOGFILE
		return 1
		;;
	esac

	return 0
}

#
# Mercurial-specific copy code for copy_source().  Handles the
# combined open and closed trees.
#
# Returns 0 for success, non-zero for failure.
#
# usage: copy_source_mercurial destdir srcroot
#
function copy_source_mercurial {
	typeset dest=$1
	typeset srcroot=$2
	typeset open_top closed_top

	case $srcroot in
	usr)
		open_top=usr
		if [[ "$CLOSED_IS_PRESENT" = yes ]]; then
			closed_top=usr/closed
		fi
		;;
	usr/closed*)
		if [[ "$CLOSED_IS_PRESENT" = no ]]; then
			printf "can't copy %s: closed tree not present.\n" \
			    "$srcroot" | tee -a $mail_msg_file >> $LOGFILE
			return 1
		fi
		closed_top="$srcroot"
		;;
	*)
		open_top="$srcroot"
		;;
	esac		

	if [[ -n "$open_top" ]]; then
		hg locate -I "$open_top" | cpio -pd "$dest" >>$LOGFILE 2>&1
		if (( $? != 0 )) ; then
		    printf "cpio failed for %s\n" "$dest" |
			tee -a $mail_msg_file >> $LOGFILE
		    return 1
		fi
	fi

	if [[ -n "$closed_top" ]]; then
		mkdir -p "$dest/usr/closed" || return 1
		if [[ "$closed_top" = usr/closed ]]; then
			(cd usr/closed; hg locate |
			    cpio -pd "$dest/usr/closed") >>$LOGFILE 2>&1
			if (( $? != 0 )) ; then
			    printf "cpio failed for %s/usr/closed\n" \
				"$dest" | tee -a $mail_msg_file >> $LOGFILE
			    return 1
			fi
		else
			# copy subtree of usr/closed
			closed_top=${closed_top#usr/closed/}
			(cd usr/closed; hg locate -I "$closed_top" |
			    cpio -pd "$dest/usr/closed") >>$LOGFILE 2>&1
			if (( $? != 0 )) ; then
			    printf "cpio failed for %s/usr/closed/%s\n" \
				"$dest" "$closed_top" |
				tee -a $mail_msg_file >> $LOGFILE
			    return 1
			fi
		fi
	fi

	return 0
}

#
# function to create (but not build) the export/crypt source tree.
# usage: set_up_source_build CODEMGR_WS DESTDIR MAKE_TARGET
# Sets SRC to the modified source tree, for use by the caller when it
# builds the tree.
#
function set_up_source_build {
	WS=$1
	DEST=$2
	MAKETARG=$3

	copy_source $WS $DEST $MAKETARG usr
	if (( $? != 0 )); then
	    echo "\nCould not copy source tree for source build." |
		tee -a $mail_msg_file >> $LOGFILE
	    build_ok=n
	    return
	fi

	SRC=${DEST}/usr/src

	cd $SRC
	rm -f ${MAKETARG}.out
	echo "making ${MAKETARG} in ${SRC}." >> $LOGFILE
	/bin/time $MAKE -e ${MAKETARG} 2>&1 | \
	    tee -a $SRC/${MAKETARG}.out >> $LOGFILE
	echo "\n==== ${MAKETARG} build errors ====\n" >> $mail_msg_file
	egrep ":" $SRC/${MAKETARG}.out | \
		egrep -e "(^${MAKE}:|[ 	]error[: 	\n])" | \
		egrep -v "Ignoring unknown host" | \
		egrep -v "warning" >> $mail_msg_file

	echo "clearing state files." >> $LOGFILE
	find . -name '.make*' -exec rm -f {} \;

	cd ${DEST}
	if [ "${MAKETARG}" = "CRYPT_SRC" ]; then
		rm -f ${CODEMGR_WS}/crypt_files.cpio.Z
		echo "\n==== xmod/cry_files that don't exist ====\n" | \
		    tee -a $mail_msg_file >> $LOGFILE
		CRYPT_FILES=${WS}/usr/src/xmod/cry_files
		for i in `cat ${CRYPT_FILES}`
		do
			# make sure the files exist
			if [ -f "$i" ]; then
				continue
			fi
			if [ -d "$i" ]; then
				continue
			fi
			echo "$i" | tee -a $mail_msg_file >> $LOGFILE
		done
		find `cat ${CRYPT_FILES}` -print 2>/dev/null | \
		    cpio -ocB 2>/dev/null | \
		    compress > ${CODEMGR_WS}/crypt_files.cpio.Z
	fi

	if [ "${MAKETARG}" = "EXPORT_SRC" ]; then
		# rename first, since we might restore a file
		# of the same name (mapfiles)
		rename_files ${EXPORT_SRC} EXPORT_SRC
		if [ "$SH_FLAG" = "y" ]; then
			hybridize_files ${EXPORT_SRC} EXPORT_SRC
		fi
	fi

	# save the cleartext
	echo "\n==== Creating ${MAKETARG}.cpio.Z ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	cd ${DEST}
	rm -f ${MAKETARG}.cpio.Z
	find usr -depth -print | \
	    grep -v usr/src/${MAKETARG}.out | \
	    cpio -ocB 2>/dev/null | \
	    compress > ${CODEMGR_WS}/${MAKETARG}.cpio.Z
	if [ "${MAKETARG}" = "EXPORT_SRC" ]; then
		restore_binaries ${EXPORT_SRC} EXPORT_SRC
	fi

	if [ "${MAKETARG}" = "CRYPT_SRC" ]; then
		restore_binaries ${CRYPT_SRC} CRYPT_SRC
	fi

}

# Return library search directive as function of given root.
function myldlibs {
	echo "-L$1/lib -L$1/usr/lib"
}

# Return header search directive as function of given root.
function myheaders {
	echo "-I$1/usr/include"
}

#
# Unpack the crypto tarball into the proto area.  We first extract the
# tarball into a temp directory so that we can handle the non-DEBUG
# tarball correctly with MULTI_PROTO=no.
# Return 0 on success, non-zero on failure.
# 
function unpack_crypto {
	typeset tarfile=$1
	typeset suffix=$2
	typeset ctop=$(mktemp -d /tmp/crypto.XXXXXX)
	[ -n "$ctop" ] || return 1
	typeset croot=$ctop/proto/root_$MACH$suffix
	echo "Unpacking crypto ($tarfile)..."
	bzcat "$tarfile" | (cd "$ctop"; tar xfBp -)
	if [[ $? -ne 0 || ! -d "$croot" ]]; then
		return 1
	fi
	#
	# We extract with -p so that we maintain permissions on directories.
	#
	(cd "$croot"; tar cf - *) | (cd "$ROOT"; tar xfBp -)
	typeset -i stat=$?
	rm -rf "$ctop"
	return $stat
}

#
# Function to do the build, including package generation.
# usage: build LABEL SUFFIX ND MULTIPROTO CRYPTO
# - LABEL is used to tag build output.
# - SUFFIX is used to distinguish files (e.g., DEBUG vs non-DEBUG,
#   open-only vs full tree).
# - ND is "-nd" (non-DEBUG builds) or "" (DEBUG builds).
# - If MULTIPROTO is "yes", it means to name the proto area according to
#   SUFFIX.  Otherwise ("no"), (re)use the standard proto area.
# - CRYPTO is the path to the crypto tarball, or null.
#
function build {
	LABEL=$1
	SUFFIX=$2
	ND=$3
	MULTIPROTO=$4
	CRYPTOPATH=$5
	INSTALLOG=install${SUFFIX}-${MACH}
	NOISE=noise${SUFFIX}-${MACH}
	PKGARCHIVE=${PKGARCHIVE_ORIG}${SUFFIX}

	ORIGROOT=$ROOT
	ORIGSTUBROOT=$STUBROOT
	if [[ "$MULTIPROTO" = "yes" ]]; then
		export ROOT=$ROOT$SUFFIX
		export STUBROOT=$STUBROOT$SUFFIX
	fi

	if [[ "$O_FLAG" = y ]]; then
		echo "\nSetting CLOSEDROOT= ${ROOT}-closed\n" >> $LOGFILE
		export CLOSEDROOT=${ROOT}-closed
	fi

	export ENVLDLIBS1=`myldlibs $ROOT`
	export STUBENVLDLIBS1=`myldlibs $STUBROOT`
	export ENVCPPFLAGS1=`myheaders $ROOT`

	this_build_ok=y
	#
	#	Build OS-Networking source
	#
	echo "\n==== Building OS-Net source at `date` ($LABEL) ====\n" \
		>> $LOGFILE

	rm -f $SRC/${INSTALLOG}.out
	cd $SRC
	/bin/time $MAKE -e install 2>&1 | \
	    tee -a $SRC/${INSTALLOG}.out >> $LOGFILE

	if [[ "$SCM_TYPE" = teamware ]]; then
		echo "\n==== SCCS Noise ($LABEL) ====\n" >> $mail_msg_file
		egrep 'sccs(check:| *get)' $SRC/${INSTALLOG}.out >> \
			$mail_msg_file
	fi

	echo "\n==== Build errors ($LABEL) ====\n" >> $mail_msg_file
	egrep ":" $SRC/${INSTALLOG}.out |
		egrep -e "(^${MAKE}:|[ 	]error[: 	\n])" | \
		egrep -v "Ignoring unknown host" | \
		egrep -v "cc .* -o error " | \
		egrep -v "warning" >> $mail_msg_file
	if [ "$?" = "0" ]; then
		build_ok=n
		this_build_ok=n
	fi
	grep "bootblock image is .* bytes too big" $SRC/${INSTALLOG}.out \
		>> $mail_msg_file
	if [ "$?" = "0" ]; then
		build_ok=n
		this_build_ok=n
	fi

	if [ -n "$CRYPTOPATH" ]; then
		unpack_crypto "$CRYPTOPATH" "$ND" >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Could not unpack crypto ($CRYPTOPATH)" |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
			build_ok=n
			this_build_ok=n
		fi
	fi

	if [ "$W_FLAG" = "n" ]; then
		echo "\n==== Build warnings ($LABEL) ====\n" >>$mail_msg_file
		egrep -i warning: $SRC/${INSTALLOG}.out \
			| egrep -v '^tic:' \
			| egrep -v "symbol (\`|')timezone' has differing types:" \
		        | egrep -v "parameter <PSTAMP> set to" \
			| egrep -v "Ignoring unknown host" \
			| egrep -v "redefining segment flags attribute for" \
			>> $mail_msg_file
	fi

	echo "\n==== Ended OS-Net source build at `date` ($LABEL) ====\n" \
		>> $LOGFILE

	echo "\n==== Elapsed build time ($LABEL) ====\n" >>$mail_msg_file
	tail -3  $SRC/${INSTALLOG}.out >>$mail_msg_file

	if [ "$i_FLAG" = "n" -a "$W_FLAG" = "n" ]; then
		rm -f $SRC/${NOISE}.ref
		if [ -f $SRC/${NOISE}.out ]; then
			mv $SRC/${NOISE}.out $SRC/${NOISE}.ref
		fi
		grep : $SRC/${INSTALLOG}.out \
			| egrep -v '^/' \
			| egrep -v '^(Start|Finish|real|user|sys|./bld_awk)' \
			| egrep -v '^tic:' \
			| egrep -v '^mcs' \
			| egrep -v '^LD_LIBRARY_PATH=' \
			| egrep -v 'ar: creating' \
			| egrep -v 'ar: writing' \
			| egrep -v 'conflicts:' \
			| egrep -v ':saved created' \
			| egrep -v '^stty.*c:' \
			| egrep -v '^mfgname.c:' \
			| egrep -v '^uname-i.c:' \
			| egrep -v '^volumes.c:' \
			| egrep -v '^lint library construction:' \
			| egrep -v 'tsort: INFORM:' \
			| egrep -v 'stripalign:' \
			| egrep -v 'chars, width' \
			| egrep -v "symbol (\`|')timezone' has differing types:" \
			| egrep -v 'PSTAMP' \
			| egrep -v '|%WHOANDWHERE%|' \
			| egrep -v '^Manifying' \
			| egrep -v 'Ignoring unknown host' \
			| egrep -v 'Processing method:' \
			| egrep -v '^Writing' \
			| egrep -v 'spellin1:' \
			| egrep -v '^adding:' \
			| egrep -v "^echo 'msgid" \
			| egrep -v '^echo ' \
			| egrep -v '\.c:$' \
			| egrep -v '^Adding file:' \
			| egrep -v 'CLASSPATH=' \
			| egrep -v '\/var\/mail\/:saved' \
			| egrep -v -- '-DUTS_VERSION=' \
			| egrep -v '^Running Mkbootstrap' \
			| egrep -v '^Applet length read:' \
			| egrep -v 'bytes written:' \
			| egrep -v '^File:SolarisAuthApplet.bin' \
			| egrep -v -i 'jibversion' \
			| egrep -v '^Output size:' \
			| egrep -v '^Solo size statistics:' \
			| egrep -v '^Using ROM API Version' \
			| egrep -v '^Zero Signature length:' \
			| egrep -v '^Note \(probably harmless\):' \
			| egrep -v '::' \
			| egrep -v -- '-xcache' \
			| egrep -v '^\+' \
			| egrep -v '^cc1: note: -fwritable-strings' \
			| egrep -v 'svccfg-native -s svc:/' \
			| sort | uniq >$SRC/${NOISE}.out
		if [ ! -f $SRC/${NOISE}.ref ]; then
			cp $SRC/${NOISE}.out $SRC/${NOISE}.ref
		fi
		echo "\n==== Build noise differences ($LABEL) ====\n" \
			>>$mail_msg_file
		diff $SRC/${NOISE}.ref $SRC/${NOISE}.out >>$mail_msg_file
	fi

	#
	#	Re-sign selected binaries using signing server
	#	(gatekeeper builds only)
	#
	if [ -n "$CODESIGN_USER" -a "$this_build_ok" = "y" ]; then
		echo "\n==== Signing proto area at `date` ====\n" >> $LOGFILE
		signing_file="${TMPDIR}/signing"
		rm -f ${signing_file}
		export CODESIGN_USER
		signproto $SRC/tools/codesign/creds 2>&1 | \
			tee -a ${signing_file} >> $LOGFILE
		echo "\n==== Finished signing proto area at `date` ====\n" \
		    >> $LOGFILE
		echo "\n==== Crypto module signing errors ($LABEL) ====\n" \
		    >> $mail_msg_file
		egrep 'WARNING|ERROR' ${signing_file} >> $mail_msg_file
		if (( $? == 0 )) ; then
			build_ok=n
			this_build_ok=n
		fi
	fi

	#
	#	Building Packages
	#
	if [ "$p_FLAG" = "y" -a "$this_build_ok" = "y" ]; then
		if [ -d $SRC/pkg -o -d $SRC/pkgdefs ]; then
			this_pkg_build_ok=y
			if ! run_hook PRE_PKGBUILD $LABEL; then
				exit 1
			fi
			echo "\n==== Creating $LABEL packages" \
			    "at `date` ====\n" >> $LOGFILE
			echo "Clearing out $PKGARCHIVE ..." >> $LOGFILE
			rm -rf $PKGARCHIVE >> "$LOGFILE" 2>&1
			mkdir -p $PKGARCHIVE >> "$LOGFILE" 2>&1

			for d in pkg pkgdefs; do
				if [ ! -f "$SRC/$d/Makefile" ]; then
					continue
				fi
				rm -f $SRC/$d/${INSTALLOG}.out
				cd $SRC/$d
				/bin/time $MAKE -e install 2>&1 | \
					tee -a $SRC/$d/${INSTALLOG}.out \
					>> $LOGFILE
			done

			echo "\n==== package build errors ($LABEL) ====\n" \
				>> $mail_msg_file

			# svr4 packaging
			if [ -f "$SRC/pkgdefs/Makefile" ]; then
				egrep "${MAKE}|ERROR|WARNING" \
				    $SRC/pkgdefs/${INSTALLOG}.out | \
					grep ':' | \
					grep -v PSTAMP | \
					egrep -v "Ignoring unknown host" \
					>> $mail_msg_file
				if (( $? == 0 )); then
					build_ok=n
					this_pkg_build_ok=n
				fi
			fi

			# ips packaging
			if [ -f "$SRC/pkg/Makefile" ]; then
				#
				# Grab any errors delineated by the Package
				# Build Error markers, and exclude the markers
				# in the final output.  Exclude lines starting
				# with info:, as those are just extra status
				# messages from the pkg build process.  If
				# anything is found, it's an error.
				#
				nawk '
				    BEGIN { exitcode=0; }
				    /^info:/ { next; }
				    /^NOTICE:/ { print; next; }
				    /^Begin Package Build Errors/ { x=1; next; }
				    /^End Package Build Errors/ { x=0; next; }
				    x { print; exitcode=1; next; }
				    toupper($0) ~ /(ERROR|FAILED|WARNING)/ {
					print; exitcode=1; next; }
				    END { exit exitcode; }' \
				    $SRC/pkg/${INSTALLOG}.out >> $mail_msg_file
				if (( $? == 1 )); then
					build_ok=n
					this_pkg_build_ok=n
				fi
			fi

			case $this_pkg_build_ok in
			y)
				state=Completed
				;;
			n)
				state=Failed
				;;
			esac
			if ! run_hook POST_PKGBUILD $LABEL $state; then
				exit 1
			fi
		else
			#
			# Handle it gracefully if -p was set but there are
			# neither pkg nor pkgdefs directories.
			#
			echo "\n==== No $LABEL packages to build ====\n" \
				>> $LOGFILE
		fi
	else
		echo "\n==== Not creating $LABEL packages ====\n" >> $LOGFILE
	fi

	ROOT=$ORIGROOT
	STUBROOT=$ORIGSTUBROOT
}

# Usage: dolint /dir y|n
# Arg. 2 is a flag to turn on/off the lint diff output
function dolint {
	if [ ! -d "$1" ]; then
		echo "dolint error: $1 is not a directory"
		exit 1
	fi

	if [ "$2" != "y" -a "$2" != "n" ]; then
		echo "dolint internal error: $2 should be 'y' or 'n'"
		exit 1
	fi

	lintdir=$1
	dodiff=$2
	base=`basename $lintdir`
	LINTOUT=$lintdir/lint-${MACH}.out
	LINTNOISE=$lintdir/lint-noise-${MACH}
	export ENVLDLIBS1=`myldlibs $ROOT`
	export STUBENVLDLIBS1=`myldlibs $STUBROOT`
	export ENVCPPFLAGS1=`myheaders $ROOT`

	set_debug_build_flags

	#
	#	'$MAKE lint' in $lintdir
	#
	echo "\n==== Begin '$MAKE lint' of $base at `date` ====\n" >> $LOGFILE

	# remove old lint.out
	rm -f $lintdir/lint.out $lintdir/lint-noise.out
	if [ -f $lintdir/lint-noise.ref ]; then
		mv $lintdir/lint-noise.ref ${LINTNOISE}.ref
	fi

	rm -f $LINTOUT
	cd $lintdir
	#
	# Remove all .ln files to ensure a full reference file
	#
	rm -f Nothing_to_remove \
	    `find . \( -name SCCS -o -name .hg -o -name .svn \) \
	    	-prune -o -type f -name '*.ln' -print `

	/bin/time $MAKE -ek lint 2>&1 | \
	    tee -a $LINTOUT >> $LOGFILE
	echo "\n==== '$MAKE lint' of $base ERRORS ====\n" >> $mail_msg_file
	grep "$MAKE:" $LINTOUT |
		egrep -v "Ignoring unknown host" \
		>> $mail_msg_file

	echo "\n==== Ended '$MAKE lint' of $base at `date` ====\n" >> $LOGFILE

	echo "\n==== Elapsed time of '$MAKE lint' of $base ====\n" \
		>>$mail_msg_file
	tail -3  $LINTOUT >>$mail_msg_file

	rm -f ${LINTNOISE}.ref
	if [ -f ${LINTNOISE}.out ]; then
		mv ${LINTNOISE}.out ${LINTNOISE}.ref
	fi
        grep : $LINTOUT | \
		egrep -v '^(real|user|sys)' |
		egrep -v '(library construction)' | \
		egrep -v ': global crosschecks' | \
		egrep -v 'Ignoring unknown host' | \
		egrep -v '\.c:$' | \
		sort | uniq > ${LINTNOISE}.out
	if [ ! -f ${LINTNOISE}.ref ]; then
		cp ${LINTNOISE}.out ${LINTNOISE}.ref
	fi
	if [ "$dodiff" != "n" ]; then
		echo "\n==== lint warnings $base ====\n" \
			>>$mail_msg_file
		# should be none, though there are a few that were filtered out
		# above
		egrep -i '(warning|lint):' ${LINTNOISE}.out \
			| sort | uniq >> $mail_msg_file
		echo "\n==== lint noise differences $base ====\n" \
			>> $mail_msg_file
		diff ${LINTNOISE}.ref ${LINTNOISE}.out \
			>> $mail_msg_file
	fi
}

# The parfait static code analysis build needs some other setup tasks
# completed before we kick off a normal build
# 
function parfait_setup {

	PARFAIT_BUILD="" ; export PARFAIT_BUILD

	# Try local copies first
	PARFAIT_HOME=${PARFAIT_HOME:-"${BUILD_TOOLS}/parfait/latest"}
	if [ ! -f $PARFAIT_HOME/bin/parfait-cc ]; then
		# Fallback to /ws/onnv-tools if local copy not found
		if [ ! -f /ws/onnv-tools/parfait/latest/bin/parfait-cc ]; then
			# we need these tools!
			echo "\nERROR: parfait-cc was not found! Please " \
				"check that $PARFAIT_HOME/bin/parfait-cc " \
				"exists. Do you need to set PARFAIT_HOME " \
				"in your env file?" \
				| tee -a $mail_msg_file >> $LOGFILE
			exit 1
		else
			PARFAIT_HOME="/ws/onnv-tools/parfait/latest/"
		fi
	fi
	# check the parfait version - we require at least 0.3.7
	PARFAIT_VERSION=$( $PARFAIT_HOME/bin/parfait --version | \
		awk '{print $2}' )
	PV_MAJOR=`echo $PARFAIT_VERSION| awk -F"." '{print $1}'`
	PV_MINOR=`echo $PARFAIT_VERSION| awk -F"." '{print $2}'`
	PV_MICRO=`echo $PARFAIT_VERSION| awk -F"." '{print $3}'`

	if [ $PV_MAJOR -eq 0 -a $PV_MINOR -eq 3 -a $PV_MICRO -lt 7 ]; then 
		echo "\nERROR: your version of parfait ($PARFAIT_VERSION) is " \
			"too old - please upgrade to at least 0.3.7\n\n" \
		    | tee -a $mail_msg_file >> $LOGFILE
		exit 1;
	else
		echo "\nParfait version $PARFAIT_VERSION found\n" \
			| tee -a $mail_msg_file >> $LOGFILE
	fi

	# We're not doing any heuristic calculations here. Having 
	# this value set to a max 16 is a reasonable upper bound
	# until we've got a lot more data about how this runs on
	# T3/T4 systems as well as next-gen x64.
	PARFAIT_MAXJOBS=${PARFAIT_MAXJOBS:-$DMAKE_MAX_JOBS}
	[[ $PARFAIT_MAXJOBS -gt 16 ]] && PARFAIT_MAXJOBS=16
	PARFAIT_LOGFMT=${PARFAIT_LOGFMT:-"text"}

	if [ $PV_MAJOR -eq 0 -a $PV_MINOR -lt 4 ]; then
		# We don't support comparison against Parfait Server
		# if our tools version is < 0.4
		DB=${PARFAIT_BUGDB:-/ws/onnv-gate/public/parfait/bugdb}
		P_BUGDB_ARGS="-b $DB -c onnv.conf -e all -W"
	else
		# NOTE: PARFAIT_SERVER_URL overrides PARFAIT_BUGDB
		if [[ -n $PARFAIT_SERVER_URL ]]; then
			P_TIP=${PARFAIT_TIP:-$( hg tip -R $CODEMGR_WS --template '{node|short}' )}
			P_BUGDB_ARGS="-s $PARFAIT_SERVER_URL -r $P_TIP"
		else
			# The -b switch does not use server configuration. We need to pass our preferred
			# setting manually. It should be fixed in 0.4.1.1 release and newer. 
			DB=${PARFAIT_BUGDB:-http://onnv.us.oracle.com:9990/projects/onnv/tasks/nightly-${MACH}}
			P_BUGDB_ARGS="-b $DB -c onnv.conf -e all -W"
		fi
	fi

	[[ -n $DB ]] && echo "Using $DB as the Parfait baseline" | \
		tee -a $mail_msg_file >> $LOGFILE
	[[ -n $PARFAIT_SERVER_URL ]] && echo "Uploading Parfait analysis" \
		"to $PARFAIT_SERVER_URL" | \
		tee -a $mail_msg_file >> $LOGFILE

	PARFAIT_ARGS="-j $PARFAIT_MAXJOBS $P_BUGDB_ARGS"
	PARFAIT_ARGS="$PARFAIT_ARGS -f $PARFAIT_LOGFMT -z $CODEMGR_WS"

	if [ "$CLOSED_IS_PRESENT" = "no" ]; then 
		# We check the *whole* tree
		echo "\n\nERROR: the usr/closed tree MUST be present" | \
			 tee -a $mail_msg_file >> $LOGFILE
		exit 1
	fi	

	CW_CC=$PARFAIT_HOME/bin/parfait-cc
	CW_GCC=$PARFAIT_HOME/bin/parfait-gcc
	CW_CPLUSPLUS=$PARFAIT_HOME/bin/parfait-CC
	CW_GPLUSPLUS=$PARFAIT_HOME/bin/parfait-g++
	AW_AS=$PARFAIT_HOME/bin/parfait-gas
	AW_AS64=$PARFAIT_HOME/bin/parfait-gas
	if [ $MACH = "i386" ]; then
		i386_AS=$PARFAIT_HOME/bin/parfait-as
		i386_LD=$PARFAIT_HOME/bin/parfait-ld
		amd64_LD=$PARFAIT_HOME/bin/parfait-ld
		export i386_AS i386_LD amd64_LD 
	else
		sparc_AS="$PARFAIT_HOME/bin/parfait-as -xregsym=no"
		sparcv9_AS="$PARFAIT_HOME/bin/parfait-as -xregsym=no"
		sparc_LD=$PARFAIT_HOME/bin/parfait-ld
		sparcv9_LD=$PARFAIT_HOME/bin/parfait-ld
		export sparc_AS sparcv9_AS sparc_LD sparcv9_LD
	fi

	export PARFAIT_HOME CW_CC CW_GCC CW_GPLUSPLUS CW_CPLUSPLUS
	export AW_AS AW_AS64
}

function parfait_analyse {

	label=$1
	buildtype=$2

	typeset -a PARFAITSTATUSMSG
	PARFAITSTATUSMSG[0]="Analysis completed successfully, and no bugs were found in the analysed programs.\n"
	PARFAITSTATUSMSG[1]="Analysis completed successfully, but one or more bugs were found in the analysed programs.\n"
	PARFAITSTATUSMSG[2]="An error was encountered in processing command line options or the user-supplied configuration file.\nParfait was called with\n\t$PARFAIT_ARGS -g $PARFAITLOGDIR/gui -o $PARFAITLOGDIR/analysis -L $PARFAITLOGDIR/filelist.txt\n"
	PARFAITSTATUSMSG[3]="An internal error was detected in parfait during processing. Please contact gk@onnv.us.oracle.com immediately.\n"

	cd $CODEMGR_WS
	find $SRC $SRC/../closed -name "*.bc" -newer $EXCLUDETHIS \
		| sort >> $PARFAITLOGDIR/filelist.txt
	# Analyse the bytecode
	echo "\n==== Parfait analysis ($buildtype) started at `date` ====\n" \
		| tee -a $mail_msg_file >> $LOGFILE
	$PARFAIT_HOME/bin/parfait $PARFAIT_ARGS \
		-g $PARFAITLOGDIR/gui \
		-o $PARFAITLOGDIR/analysis \
		-L $PARFAITLOGDIR/filelist.txt > $PARFAITLOGDIR/stdout 2>&1
	PARFAITSTATUS=$?
	echo "Parfait exit status is $PARFAITSTATUS:" \
		| tee -a $mail_msg_file >> $LOGFILE
	echo "${PARFAITSTATUSMSG[$PARFAITSTATUS]}" \
		| tee -a $mail_msg_file >> $LOGFILE
	[ $PARFAITSTATUS -gt 0 ] && echo "Please review the stdout" \
		"and analysis files (under parfait_analysis_${MACH}${label})" \
		"in the build log directory.\n" \
		| tee -a $mail_msg_file >> $LOGFILE
	echo "\n==== Parfait analysis finished at `date` ====\n" \
		| tee -a $mail_msg_file >> $LOGFILE
}

#
# Build and install the onbld tools.
#
# usage: build_tools DESTROOT
#
# returns non-zero status if the build was successful.
#
function build_tools {
	DESTROOT=$1

	INSTALLOG=install-${MACH}

	echo "\n==== Building tools at `date` ====\n" \
		>> $LOGFILE

	rm -f ${TOOLS}/${INSTALLOG}.out
	cd ${TOOLS}
	/bin/time $MAKE TOOLS_PROTO=${DESTROOT} -e install 2>&1 | \
	    tee -a ${TOOLS}/${INSTALLOG}.out >> $LOGFILE

	echo "\n==== Tools build errors ====\n" >> $mail_msg_file

	egrep ":" ${TOOLS}/${INSTALLOG}.out |
		egrep -e "(${MAKE}:|[ 	]error[: 	\n])" | \
		egrep -v "Ignoring unknown host" | \
		egrep -v warning >> $mail_msg_file
	return $?
}

#
# Set up to use locally installed tools.
#
# usage: use_tools TOOLSROOT
#
function use_tools {
	TOOLSROOT=$1

	#
	# If we're not building ON workspace, then the TOOLSROOT
	# settings here are clearly ignored by the workspace
	# makefiles, prepending nonexistent directories to PATH is
	# harmless, and we clearly do not wish to override
	# ONBLD_TOOLS.
	#
	# If we're building an ON workspace, then the prepended PATH
	# elements should supercede the preexisting ONBLD_TOOLS paths,
	# and we want to override ONBLD_TOOLS to catch the tools that
	# don't have specific path env vars here.
	#
	# So the only conditional behavior is overriding ONBLD_TOOLS,
	# and we check for "an ON workspace" by looking for
	# ${TOOLSROOT}/opt/onbld.
	#

	STABS=${TOOLSROOT}/opt/onbld/bin/${MACH}/stabs
	export STABS
	CTFSTABS=${TOOLSROOT}/opt/onbld/bin/${MACH}/ctfstabs
	export CTFSTABS
	GENOFFSETS=${TOOLSROOT}/opt/onbld/bin/genoffsets
	export GENOFFSETS

	CTFCONVERT=${TOOLSROOT}/opt/onbld/bin/${MACH}/ctfconvert
	export CTFCONVERT
	CTFMERGE=${TOOLSROOT}/opt/onbld/bin/${MACH}/ctfmerge
	export CTFMERGE

	if [ "$VERIFY_ELFSIGN" = "y" ]; then
		ELFSIGN=${TOOLSROOT}/opt/onbld/bin/elfsigncmp
	else
		ELFSIGN=${TOOLSROOT}/opt/onbld/bin/${MACH}/elfsign
	fi
	export ELFSIGN

	PATH="${TOOLSROOT}/opt/onbld/bin/${MACH}:${PATH}"
	PATH="${TOOLSROOT}/opt/onbld/bin:${PATH}"
	export PATH

	if [ -d "${TOOLSROOT}/opt/onbld" ]; then
		ONBLD_TOOLS=${TOOLSROOT}/opt/onbld
		export ONBLD_TOOLS
	fi

	echo "\n==== New environment settings. ====\n" >> $LOGFILE
	echo "STABS=${STABS}" >> $LOGFILE
	echo "CTFSTABS=${CTFSTABS}" >> $LOGFILE
	echo "CTFCONVERT=${CTFCONVERT}" >> $LOGFILE
	echo "CTFMERGE=${CTFMERGE}" >> $LOGFILE
	echo "ELFSIGN=${ELFSIGN}" >> $LOGFILE
	echo "PATH=${PATH}" >> $LOGFILE
	echo "ONBLD_TOOLS=${ONBLD_TOOLS}" >> $LOGFILE
}

function staffer {
	if [ $ISUSER -ne 0 ]; then
		"$@"
	else
		arg="\"$1\""
		shift
		for i
		do
			arg="$arg \"$i\""
		done
		eval su $STAFFER -c \'$arg\'
	fi
}

#
# Verify that the closed tree is present if it needs to be.
# Sets CLOSED_IS_PRESENT for future use.
#
function check_closed_tree {
	if [ -z "$CLOSED_IS_PRESENT" ]; then
		if [ -d $CODEMGR_WS/usr/closed ]; then
			CLOSED_IS_PRESENT="yes"
		else
			CLOSED_IS_PRESENT="no"
		fi
		export CLOSED_IS_PRESENT
	fi
	if [[ "$CLOSED_IS_PRESENT" = no && ! -d "$ON_CLOSED_BINS" ]]; then
		#
		# If it's an old (pre-split) tree or an empty
		# workspace, don't complain.
		#
		if grep -s CLOSED_BUILD $SRC/Makefile.master > /dev/null; then
			echo "If the closed sources are not present," \
			    "ON_CLOSED_BINS"
			echo "must point to the closed binaries tree."
			build_ok=n
			exit 1
		fi
	fi
}

function obsolete_build {
    	echo "WARNING: Obsolete $1 build requested; request will be ignored"
}

#
# wrapper over wsdiff.
# usage: do_wsdiff LABEL OLDPROTO NEWPROTO
#
function do_wsdiff {
	label=$1
	oldproto=$2
	newproto=$3

	wsdiff="wsdiff"
	[ "$t_FLAG" = y ] && wsdiff="wsdiff -t"

	typeset mfarg=""
	if [ -d $SRC/pkg/packages.$MACH ]; then
		mfarg="-m $SRC/pkg/packages.$MACH"
	fi

	echo "\n==== Getting object changes since last build at `date`" \
	    "($label) ====\n" | tee -a $LOGFILE >> $mail_msg_file
	$wsdiff -s -r ${TMPDIR}/wsdiff.results $mfarg \
	    $oldproto $newproto 2>&1 | \
	    tee -a $LOGFILE >> $mail_msg_file
	echo "\n==== Object changes determined at `date` ($label) ====\n" | \
	    tee -a $LOGFILE >> $mail_msg_file
}

#
# Functions for setting build flags (DEBUG/non-DEBUG).  Keep them
# together.
#

function set_non_debug_build_flags {
	export INTERNAL_RELEASE_BUILD ; INTERNAL_RELEASE_BUILD=
	export RELEASE_BUILD ; RELEASE_BUILD=
	unset EXTRA_OPTIONS
	unset EXTRA_CFLAGS
}

function set_debug_build_flags {
	export INTERNAL_RELEASE_BUILD ; INTERNAL_RELEASE_BUILD=
	unset RELEASE_BUILD
	unset EXTRA_OPTIONS
	unset EXTRA_CFLAGS
}


MACH=`uname -p`

if [ "$OPTHOME" = "" ]; then
	OPTHOME=/opt
	export OPTHOME
fi
if [ "$TEAMWARE" = "" ]; then
	TEAMWARE=$OPTHOME/teamware
	export TEAMWARE
fi

USAGE='Usage: nightly [-in] [+t] [-V VERS ] [ -S E|D|H|O ] <env_file>

Where:
	-i	Fast incremental options (no clobber, lint, check)
	-n      Do not do a bringover
	+t	Use the build tools in $ONBLD_TOOLS/bin
	-V VERS set the build version string to VERS
	-S	Build a variant of the source product
		E - build exportable source
		D - build domestic source (exportable + crypt)
		H - build hybrid source (binaries + deleted source)
		O - build (only) open source

	<env_file>  file in Bourne shell syntax that sets and exports
	variables that configure the operation of this script and many of
	the scripts this one calls. If <env_file> does not exist,
	it will be looked for in $OPTHOME/onbld/env.

non-DEBUG is the default build type. Build options can be set in the
NIGHTLY_OPTIONS variable in the <env_file> as follows:

	-A	check for ABI differences in .so files
	-C	check for cstyle/hdrchk errors
	-D	do a build with DEBUG on
	-F	do _not_ do a non-DEBUG build
	-G	gate keeper default group of options (-au)
	-I	integration engineer default group of options (-ampu)
	-M	do not run pmodes (safe file permission checker)
	-N	do not run protocmp
	-O	generate OpenSolaris deliverables
	-P	do a Parfait static code analysis build
	-R	default group of options for building a release (-mp)
	-U	update proto area in the parent
	-V VERS set the build version string to VERS
	-f	find unreferenced files
	-i	do an incremental build (no "make clobber")
	-l	do "make lint" in $LINTDIRS (default: $SRC y)
	-m	send mail to $MAILTO at end of build
	-n      do not do a bringover
	-o	build using root privileges to set OWNER/GROUP (old style)
	-p	create packages
	-r	check ELF runtime attributes in the proto area
	-t	build and use the tools in $SRC/tools (default setting)
	+t	Use the build tools in $ONBLD_TOOLS/bin
	-u	update proto_list_$MACH and friends in the parent workspace;
		when used with -f, also build an unrefmaster.out in the parent
	-w	report on differences between previous and current proto areas
	-z	compress cpio archives with gzip
	-W	Do not report warnings (freeware gate ONLY)
	-S	Build a variant of the source product
		E - build exportable source
		D - build domestic source (exportable + crypt)
		H - build hybrid source (binaries + deleted source)
		O - build (only) open source
'
#
#	-x	less public handling of xmod source for the source product
#
#	A log file will be generated under the name $LOGFILE
#	for partially completed build and log.`date '+%F'`
#	in the same directory for fully completed builds.
#

# default values for low-level FLAGS; G I R are group FLAGS
A_FLAG=n
C_FLAG=n
D_FLAG=n
F_FLAG=n
f_FLAG=n
i_FLAG=n; i_CMD_LINE_FLAG=n
l_FLAG=n
M_FLAG=n
m_FLAG=n
N_FLAG=n
n_FLAG=n
O_FLAG=n
o_FLAG=n
P_FLAG=n
p_FLAG=n
r_FLAG=n
T_FLAG=n
t_FLAG=y
U_FLAG=n
u_FLAG=n
V_FLAG=n
W_FLAG=n
w_FLAG=n
z_FLAG=n
SD_FLAG=n
SE_FLAG=n
SH_FLAG=n
SO_FLAG=n
#
XMOD_OPT=
#
build_ok=y

function is_source_build {
	[ "$SE_FLAG" = "y" -o "$SD_FLAG" = "y" -o \
	    "$SH_FLAG" = "y" -o "$SO_FLAG" = "y" ]
	return $?
}

#
# examine arguments
#

#
# single function for setting -S flag and doing error checking.
# usage: set_S_flag <type>
# where <type> is the source build type ("E", "D", ...).
#
function set_S_flag {
	if is_source_build; then
		echo "Can only build one source variant at a time."
		exit 1
	fi
	if [ "$1" = "E" ]; then
		SE_FLAG=y
	elif [ "$1" = "D" ]; then
		SD_FLAG=y
	elif [ "$1" = "H" ]; then
		SH_FLAG=y
	elif [ "$1" = "O" ]; then
		SO_FLAG=y
	else
		echo "$USAGE"
		exit 1
	fi
}

OPTIND=1
while getopts +inS:tV: FLAG
do
	case $FLAG in
	  i )	i_FLAG=y; i_CMD_LINE_FLAG=y
		;;
	  n )	n_FLAG=y
		;;
	  S )
		set_S_flag $OPTARG
		;;
	 +t )	t_FLAG=n
		;;
	  V )	V_FLAG=y
		V_ARG="$OPTARG"
		;;
	 \? )	echo "$USAGE"
		exit 1
		;;
	esac
done

# correct argument count after options
shift `expr $OPTIND - 1`

# test that the path to the environment-setting file was given
if [ $# -ne 1 ]; then
	echo "$USAGE"
	exit 1
fi

# check if user is running nightly as root
# ISUSER is set non-zero if an ordinary user runs nightly, or is zero
# when root invokes nightly.
/usr/bin/id | grep '^uid=0(' >/dev/null 2>&1
ISUSER=$?;	export ISUSER

#
# force locale to C
LC_COLLATE=C;	export LC_COLLATE
LC_CTYPE=C;	export LC_CTYPE
LC_MESSAGES=C;	export LC_MESSAGES
LC_MONETARY=C;	export LC_MONETARY
LC_NUMERIC=C;	export LC_NUMERIC
LC_TIME=C;	export LC_TIME

# clear environment variables we know to be bad for the build
unset LD_OPTIONS
unset LD_AUDIT		LD_AUDIT_32		LD_AUDIT_64
unset LD_BIND_NOW	LD_BIND_NOW_32		LD_BIND_NOW_64
unset LD_BREADTH	LD_BREADTH_32		LD_BREADTH_64
unset LD_CONFIG		LD_CONFIG_32		LD_CONFIG_64
unset LD_DEBUG		LD_DEBUG_32		LD_DEBUG_64
unset LD_DEMANGLE	LD_DEMANGLE_32		LD_DEMANGLE_64
unset LD_FLAGS		LD_FLAGS_32		LD_FLAGS_64
unset LD_LIBRARY_PATH	LD_LIBRARY_PATH_32	LD_LIBRARY_PATH_64
unset LD_LOADFLTR	LD_LOADFLTR_32		LD_LOADFLTR_64
unset LD_NOAUDIT	LD_NOAUDIT_32		LD_NOAUDIT_64
unset LD_NOAUXFLTR	LD_NOAUXFLTR_32		LD_NOAUXFLTR_64
unset LD_NOCONFIG	LD_NOCONFIG_32		LD_NOCONFIG_64
unset LD_NODIRCONFIG	LD_NODIRCONFIG_32	LD_NODIRCONFIG_64
unset LD_NODIRECT	LD_NODIRECT_32		LD_NODIRECT_64
unset LD_NOLAZYLOAD	LD_NOLAZYLOAD_32	LD_NOLAZYLOAD_64
unset LD_NOOBJALTER	LD_NOOBJALTER_32	LD_NOOBJALTER_64
unset LD_NOVERSION	LD_NOVERSION_32		LD_NOVERSION_64
unset LD_ORIGIN		LD_ORIGIN_32		LD_ORIGIN_64
unset LD_PRELOAD	LD_PRELOAD_32		LD_PRELOAD_64
unset LD_PROFILE	LD_PROFILE_32		LD_PROFILE_64

unset CONFIG
unset GROUP
unset OWNER
unset REMOTE
unset ENV
unset ARCH
unset CLASSPATH
unset NAME

#
# To get ONBLD_TOOLS from the environment, it must come from the env file.
# If it comes interactively, it is generally TOOLS_PROTO, which will be
# clobbered before the compiler version checks, which will therefore fail.
#
# Similarly for INS_STRIP_CDDL, which should not be carried over from
# an interactive environment if it is not also set in the env file.
#
unset ONBLD_TOOLS INS_STRIP_CDDL

#
#	Setup environmental variables
#
unset SYS_PRE_NIGHTLY SYS_POST_NIGHTLY
if [ -f /etc/nightly.conf ]; then
	. /etc/nightly.conf
fi    

if [ -f $1 ]; then
	if [[ $1 = */* ]]; then
		. $1
	else
		. ./$1
	fi
else
	if [ -f $OPTHOME/onbld/env/$1 ]; then
		. $OPTHOME/onbld/env/$1
	else
		echo "Cannot find env file as either $1 or $OPTHOME/onbld/env/$1"
		exit 1
	fi
fi

# STUBROOT is derived from ROOT. ROOT is defined by the environment file
STUBROOT="${ROOT}_stub";	export STUBROOT

# contents of stdenv.sh inserted after next line:
# STDENV_START
# STDENV_END

#
# place ourselves in a new task, respecting BUILD_PROJECT if set.
#
if [ -z "$BUILD_PROJECT" ]; then
	/usr/bin/newtask -c $$
else
	/usr/bin/newtask -c $$ -p $BUILD_PROJECT
fi

ps -o taskid= -p $$ | read build_taskid
ps -o project= -p $$ | read build_project

#
# See if NIGHTLY_OPTIONS is set
#
if [ "$NIGHTLY_OPTIONS" = "" ]; then
	NIGHTLY_OPTIONS="-aBm"
fi

#
# If BRINGOVER_WS was not specified, let it default to CLONE_WS
#
if [ "$BRINGOVER_WS" = "" ]; then
	BRINGOVER_WS=$CLONE_WS
fi

#
# If CLOSED_BRINGOVER_WS was not specified, let it default to CLOSED_CLONE_WS
#
if [ "$CLOSED_BRINGOVER_WS" = "" ]; then
	CLOSED_BRINGOVER_WS=$CLOSED_CLONE_WS
fi

#
# If BRINGOVER_FILES was not specified, default to usr
#
if [ "$BRINGOVER_FILES" = "" ]; then
	BRINGOVER_FILES="usr"
fi

#
# If the closed sources are not present, the closed binaries must be
# present for the build to succeed.  If there's no pointer to the
# closed binaries, flag that now, rather than forcing the user to wait
# a couple hours (or more) to find out.
#
orig_closed_is_present="$CLOSED_IS_PRESENT"
check_closed_tree

#
# Note: changes to the option letters here should also be applied to the
#	bldenv script.  `d' is listed for backward compatibility.
#
NIGHTLY_OPTIONS=-${NIGHTLY_OPTIONS#-}
OPTIND=1
while getopts +ABCDdFfGIilMmNnOoPpRrS:TtUuWwxz FLAG $NIGHTLY_OPTIONS
do
	case $FLAG in
	  A )	A_FLAG=y
		#
		# If ELF_DATA_BASELINE_DIR is not defined, and we are on SWAN
		# (based on CLOSED_IS_PRESENT), then refuse to run. The value
		# of ELF version checking is greatly enhanced by including
		# the baseline gate comparison.
		if [ "$CLOSED_IS_PRESENT" = 'yes' -a \
		     "$ELF_DATA_BASELINE_DIR" = '' ]; then
			echo "ELF_DATA_BASELINE_DIR must be set if the A" \
			    "flag is present in\nNIGHTLY_OPTIONS and closed" \
			    "sources are present. Update environment file."
			exit 1;
		fi
		;;
	  B )	D_FLAG=y
		;; # old version of D
	  C )	C_FLAG=y
		;;
	  D )	D_FLAG=y
		;;
	  F )	F_FLAG=y
		;;
	  f )	f_FLAG=y
		;;
	  G )   u_FLAG=y
		;;
	  I )	m_FLAG=y
		p_FLAG=y
		u_FLAG=y
		;;
	  i )	i_FLAG=y
		;;
	  l )	l_FLAG=y
		;;
	  M )	M_FLAG=y
		;;
	  m )	m_FLAG=y
		;;
	  N )	N_FLAG=y
		;;
	  n )	n_FLAG=y
		;;
	  O )	O_FLAG=y
		;;
	  o )	o_FLAG=y
		;;
	  P )	P_FLAG=y
		;;
	  p )	p_FLAG=y
		;;
	  R )	m_FLAG=y
		p_FLAG=y
		;;
	  r )	r_FLAG=y
		;;
	  S )
		set_S_flag $OPTARG
		;;
	  T )	T_FLAG=y
		;; # obsolete
	 +t )	t_FLAG=n
		;;
	  U )   if [ -z "${PARENT_ROOT}" ]; then
			echo "PARENT_ROOT must be set if the U flag is" \
			    "present in NIGHTLY_OPTIONS."
			exit 1
		fi
		NIGHTLY_PARENT_ROOT=$PARENT_ROOT
		if [ -n "${PARENT_TOOLS_ROOT}" ]; then
			NIGHTLY_PARENT_TOOLS_ROOT=$PARENT_TOOLS_ROOT
		fi
		U_FLAG=y
		;;
	  u )	u_FLAG=y
		;;
	  W )	W_FLAG=y
		;;

	  w )	w_FLAG=y
		;;
	  x )	XMOD_OPT="-x"
		;;
	  z )	z_FLAG=y
		;;
	 \? )	echo "$USAGE"
		exit 1
		;;
	esac
done

if [ $ISUSER -ne 0 ]; then
	if [ "$o_FLAG" = "y" ]; then
		echo "Old-style build requires root permission."
		exit 1
	fi

	# Set default value for STAFFER, if needed.
	if [ -z "$STAFFER" -o "$STAFFER" = "nobody" ]; then
		STAFFER=`/usr/xpg4/bin/id -un`
		export STAFFER
	fi
fi

if [ -z "$MAILTO" -o "$MAILTO" = "nobody" ]; then
	MAILTO=$STAFFER
	export MAILTO
fi

PATH="$OPTHOME/onbld/bin:$OPTHOME/onbld/bin/${MACH}"
PATH="$PATH:$OPTHOME/SUNWspro/bin:$TEAMWARE/bin:/usr/bin:/usr/sbin:/usr/ucb"
PATH="$PATH:/usr/openwin/bin:/usr/sfw/bin:/opt/sfw/bin:."
export PATH

# roots of source trees, both relative to $SRC and absolute.
relsrcdirs="."
if [[ -d $CODEMGR_WS/usr/closed && "$CLOSED_IS_PRESENT" != no ]]; then
	relsrcdirs="$relsrcdirs ../closed"
fi
abssrcdirs=""
for d in $relsrcdirs; do
	abssrcdirs="$abssrcdirs $SRC/$d"
done

unset CH
if [ "$o_FLAG" = "y" ]; then
# root invoked old-style build -- make sure it works as it always has
# by exporting 'CH'.  The current Makefile.master doesn't use this, but
# the old ones still do.
	PROTOCMPTERSE="protocmp.terse"
	CH=
	export CH
else
	PROTOCMPTERSE="protocmp.terse -gu"
fi
POUND_SIGN="#"
# have we set RELEASE_DATE in our env file?
if [ -z "$RELEASE_DATE" ]; then
	RELEASE_DATE=$(LC_ALL=C date +"%B %Y")
fi
BUILD_DATE=$(LC_ALL=C date +%Y-%b-%d)
BASEWSDIR=$(basename $CODEMGR_WS)
DEV_CM="\"@(#)SunOS Internal Development: $LOGNAME $BUILD_DATE [$BASEWSDIR]\""

# we export POUND_SIGN, RELEASE_DATE and DEV_CM to speed up the build process
# by avoiding repeated shell invocations to evaluate Makefile.master definitions.
# we export o_FLAG for use by makebfu, and by usr/src/pkg/Makefile
export o_FLAG POUND_SIGN RELEASE_DATE DEV_CM

maketype="distributed"
MAKE=dmake

TMPDIR="/tmp/nightly.tmpdir.$$"
export TMPDIR
rm -rf ${TMPDIR}
mkdir -p $TMPDIR || exit 1
chmod 777 $TMPDIR

# Try finding dmake in BUILD_TOOLS or SPRO_ROOT.

# ON has a default BUILD_TOOLS and SPRO_ROOT in Makefile.master
# that construct SPRO_VROOT; if we can extract that, that's where to
# look for dmake.

if [[ -f ${SRC}/Makefile.master ]] ; then
	rm -f $TMPDIR/make-state
	export SRC
	MYPWD=$(pwd)
	cd $SRC
	if [[ -z "${SPRO_VROOT}" ]]; then
		SPRO_VROOT=$(make -K $TMPDIR/make-state -e spro-vroot \
		    2>/dev/null)
	fi
	# if that worked, use it
	if [[ -n "${SPRO_VROOT}" ]]; then
		MAKE=${SPRO_VROOT}/bin/dmake
	fi
	rm -f $TMPDIR/make-state
	cd $MYPWD
fi

# Other consolidations may not have SPRO_VROOT, or indeed no Makefile.master,
# but may use BUILD_TOOLS or SPRO_ROOT from the environment or the env file

if [[ -z ${SPRO_VROOT} ]] ; then
	if [[ -n "${BUILD_TOOLS}" ]] ; then 
		MAKE="${BUILD_TOOLS}/SUNWspro/bin/dmake"
	fi
	# SPRO_ROOT takes precedence, as in ON's Makefile.master
	if [[ -n "${SPRO_ROOT}" ]] ; then
		MAKE="${SPRO_ROOT}/bin/dmake"
	fi
fi

# Now we've found what we believe is the right dmake; get the dmake version 
DMAKE_VERSION=$( $MAKE -v )
DMAKE_VERSION=${DMAKE_VERSION#*: }

# focus in on just the dotted version number alone
DMAKE_MAJOR=$( echo $DMAKE_VERSION | \
	sed -e 's/.*\<\([^.]*\.[^   ]*\).*$/\1/' )
# extract the second (or final) integer
DMAKE_MINOR=${DMAKE_MAJOR#*.}
DMAKE_MINOR=${DMAKE_MINOR%%.*}
# extract the first integer
DMAKE_MAJOR=${DMAKE_MAJOR%%.*}
CHECK_DMAKE=${CHECK_DMAKE:-y}

# for ON (with SPRO_VROOT), require version 7.9 at a minimum
# (as comes with sunstudio12.1)
if [[ "$CHECK_DMAKE" = "y" ]] ; then
	if [[ ("$DMAKE_MAJOR" -lt 7) || \
              ((-n "$SPRO_VROOT") && ("$DMAKE_MAJOR" -eq 7) && \
	       ("$DMAKE_MINOR" -lt 9)) ]] ; then
		if [ -z "$DMAKE_VERSION" ]; then
			echo "$MAKE is missing."
			exit 1
		fi
		echo `whence $MAKE`" version is:"
		echo "  ${DMAKE_VERSION}"
		cat <<EOF

This version may not be safe for use.  Either set BUILD_TOOLS to a different 
path or (if you really want to use this version of dmake anyway), add
the following to your environment to disable this check:

  CHECK_DMAKE=n
EOF
		exit 1
	fi
fi

export PATH
export MAKE

#
# Make sure the crypto tarball is available if it's needed.
#

# Echo the non-DEBUG name corresponding to the given crypto tarball path.
function ndcrypto {
	typeset dir file

	if [ -z "$1" ]; then
		echo ""
		return
	fi

	dir=$(dirname "$1")
	file=$(basename "$1" ".$MACH.tar.bz2")

	echo "$dir/$file-nd.$MACH.tar.bz2"
}

# Return 0 (success) if the required crypto tarball(s) are present.
function crypto_is_present {
	if [ -z "$ON_CRYPTO_BINS" ]; then
		echo "ON_CRYPTO_BINS is null or not set."
		return 1
	fi
	if [ "$D_FLAG" = y ]; then
		if [ ! -f "$ON_CRYPTO_BINS" ]; then
			echo "DEBUG crypto tarball is unavailable."
			return 1
		fi
	fi
	if [ "$F_FLAG" = n ]; then
		if [ ! -f $(ndcrypto "$ON_CRYPTO_BINS") ]; then
			echo "Non-DEBUG crypto tarball is unavailable."
			return 1
		fi
	fi

	return 0
}

#
# Canonicalize ON_CRYPTO_BINS, just in case it was set to the -nd
# tarball.
#
if [ -n "$ON_CRYPTO_BINS" ]; then
	export ON_CRYPTO_BINS=$(echo "$ON_CRYPTO_BINS" | 
	    sed -e s/-nd.$MACH.tar/.$MACH.tar/)
fi

if [[ "$O_FLAG" = y && -z "$CODESIGN_USER" ]]; then
	if ! crypto_is_present; then
		echo "OpenSolaris deliveries need signed crypto."
		exit 1
	fi
fi

if [[ "$O_FLAG" = y ]]; then
	export TONICBUILD=""
else
	export TONICBUILD="#"
fi

if [ "${SUNWSPRO}" != "" ]; then
	PATH="${SUNWSPRO}/bin:$PATH"
	export PATH
fi

hostname=$(uname -n)
if [[ $DMAKE_MAX_JOBS != +([0-9]) || $DMAKE_MAX_JOBS -eq 0 ]]
then
	maxjobs=
	if [[ -f $HOME/.make.machines ]]
	then
		# Note: there is a hard tab and space character in the []s
		# below.
		egrep -i "^[ 	]*$hostname[ 	\.]" \
			$HOME/.make.machines | read host jobs
		maxjobs=${jobs##*=}
	fi

	if [[ $maxjobs != +([0-9]) || $maxjobs -eq 0 ]]
	then
		# default
		maxjobs=4
	fi

	export DMAKE_MAX_JOBS=$maxjobs
fi

DMAKE_MODE=parallel;
export DMAKE_MODE

if [ -z "${ROOT}" ]; then
	echo "ROOT must be set."
	exit 1
fi

#
# if -V flag was given, reset VERSION to V_ARG
#
if [ "$V_FLAG" = "y" ]; then
	VERSION=$V_ARG
fi

# Append source version
if [ "$SE_FLAG" = "y" ]; then
	VERSION="${VERSION}:EXPORT"
fi

if [ "$SD_FLAG" = "y" ]; then
	VERSION="${VERSION}:DOMESTIC"
fi

if [ "$SH_FLAG" = "y" ]; then
	VERSION="${VERSION}:MODIFIED_SOURCE_PRODUCT"
fi

if [ "$SO_FLAG" = "y" ]; then
	VERSION="${VERSION}:OPEN_ONLY"
fi

#
# Keep elfsign's use of pkcs11_softtoken from looking in the user home
# directory, which doesn't always work.   Needed until all build machines
# have the fix for 6271754
#
SOFTTOKEN_DIR=$TMPDIR
export SOFTTOKEN_DIR

#
# Tools should only be built non-DEBUG.  Keep track of the tools proto
# area path relative to $TOOLS, because the latter changes in an
# export build.
#
# TOOLS_PROTO is included below for builds other than usr/src/tools
# that look for this location.  For usr/src/tools, this will be
# overridden on the $MAKE command line in build_tools().
#
TOOLS=${SRC}/tools
TOOLS_PROTO_REL=proto/root_${MACH}-nd
TOOLS_PROTO=${TOOLS}/${TOOLS_PROTO_REL};	export TOOLS_PROTO

unset   CFLAGS LD_LIBRARY_PATH LDFLAGS

# create directories that are automatically removed if the nightly script
# fails to start correctly
function newdir {
	dir=$1
	toadd=
	while [ ! -d $dir ]; do
		toadd="$dir $toadd"
		dir=`dirname $dir`
	done
	torm=
	newlist=
	for dir in $toadd; do
		if staffer mkdir $dir; then
			newlist="$ISUSER $dir $newlist"
			torm="$dir $torm"
		else
			[ -z "$torm" ] || staffer rmdir $torm
			return 1
		fi
	done
	newdirlist="$newlist $newdirlist"
	return 0
}
newdirlist=

[ -d $CODEMGR_WS ] || newdir $CODEMGR_WS || exit 1

# since this script assumes the build is from full source, it nullifies
# variables likely to have been set by a "ws" script; nullification
# confines the search space for headers and libraries to the proto area
# built from this immediate source.
ENVLDLIBS1=
ENVLDLIBS2=
ENVLDLIBS3=
STUBENVLDLIBS1=
STUBENVLDLIBS2=
STUBENVLDLIBS3=
ENVCPPFLAGS1=
ENVCPPFLAGS2=
ENVCPPFLAGS3=
ENVCPPFLAGS4=
PARENT_ROOT=

export ENVLDLIBS3 STUBENVLDLIBS3 ENVCPPFLAGS1 ENVCPPFLAGS2 ENVCPPFLAGS3 \
	ENVCPPFLAGS4 PARENT_ROOT

PKGARCHIVE_ORIG=$PKGARCHIVE

#
# Juggle the logs and optionally send mail on completion.
# arg1: state of the finished build
#
function logshuffle {
	typeset -r state=$1

    	LLOG="$ATLOG/log.`date '+%F.%H:%M'`"
	if [ -f $LLOG -o -d $LLOG ]; then
	    	LLOG=$LLOG.$$
	fi
	mkdir $LLOG
	export LLOG

	if [ "$state" = "Completed" ]; then
		mv $ATLOG/proto_list_${MACH} $LLOG

		[ -d $ATLOG/parfait_analysis_${MACH} ] &&
			mv $ATLOG/parfait_analysis_${MACH} $LLOG
		[ -d $ATLOG/parfait_analysis_${MACH}-nd ] &&
			mv $ATLOG/parfait_analysis_${MACH}-nd $LLOG

		if [ -f $ATLOG/proto_list_tools_${MACH} ]; then
			mv $ATLOG/proto_list_tools_${MACH} $LLOG
	        fi

		if [ -f $TMPDIR/wsdiff.results ]; then
		    	mv $TMPDIR/wsdiff.results $LLOG
		fi

		if [ -f $TMPDIR/wsdiff-nd.results ]; then
			mv $TMPDIR/wsdiff-nd.results $LLOG
		fi
	fi

	#
	# Now that we're about to send mail, it's time to check the noise
	# file.  In the event that an error occurs beyond this point, it will
	# be recorded in the nightly.log file, but nowhere else.  This would
	# include only errors that cause the copying of the noise log to fail
	# or the mail itself not to be sent.
	#

	exec >>$LOGFILE 2>&1
	if [ -s $build_noise_file ]; then
	    	echo "\n==== Nightly build noise ====\n" |
		    tee -a $LOGFILE >>$mail_msg_file
		cat $build_noise_file >>$LOGFILE
		cat $build_noise_file >>$mail_msg_file
		echo | tee -a $LOGFILE >>$mail_msg_file
	fi
	rm -f $build_noise_file

	cat $build_time_file $build_environ_file $mail_msg_file \
	    > ${LLOG}/mail_msg
	if [ "$m_FLAG" = "y" ]; then
	    	cat ${LLOG}/mail_msg | /usr/bin/mailx -s \
	"Nightly ${MACH} Build of `basename ${CODEMGR_WS}` ${state}." \
			${MAILTO}
	fi

	if [ "$u_FLAG" = "y" -a "$state" = "Completed" ]; then
	    	staffer cp ${LLOG}/mail_msg $PARENT_WS/usr/src/mail_msg-${MACH}
		staffer cp $LOGFILE $PARENT_WS/usr/src/nightly-${MACH}.log
	fi

	mv $LOGFILE $LLOG
}

#
# Call post-nightly hooks, do final log processing and remove the locks and
# temporary files on any exit. This function should not be called explicitly
# because it calls the hooks.
#
function cleanup {
	typeset leave=0

	case "$build_ok" in
	y)
		state=Completed
		;;
	i)
		state=Interrupted
		;;
	*)
    		state=Failed
		;;
	esac
	NIGHTLY_STATUS=$state
	export NIGHTLY_STATUS

	if ! run_hook POST_NIGHTLY $state; then
		leave=1
	fi

	# We want to run SYS_POST_NIGHTLY even if POST_NIGHTLY fails in order
	# to allow build machine admins to capture that event of all nightlies.
	if ! run_hook SYS_POST_NIGHTLY $state; then
		leave=1
	fi

    	logshuffle $state

	[ -z "$lockfile" ] || staffer rm -f $lockfile
	[ -z "$atloglockfile" ] || rm -f $atloglockfile
	[ -z "$ulockfile" ] || staffer rm -f $ulockfile
	[ -z "$Ulockfile" ] || rm -f $Ulockfile

	set -- $newdirlist
	while [ $# -gt 0 ]; do
		ISUSER=$1 staffer rmdir $2
		shift; shift
	done
	rm -rf $TMPDIR

	if [ $leave -gt 0 ]; then
		exit 1
	fi
}

function cleanup_signal {
    	build_ok=i
	# this will trigger cleanup(), above.
	exit 1
}

trap cleanup 0
trap cleanup_signal 1 2 3 15

#
# Generic lock file processing -- make sure that the lock file doesn't
# exist.  If it does, it should name the build host and PID.  If it
# doesn't, then make sure we can create it.  Clean up locks that are
# known to be stale (assumes host name is unique among build systems
# for the workspace).
#
function create_lock {
	lockf=$1
	lockvar=$2

	ldir=`dirname $lockf`
	[ -d $ldir ] || newdir $ldir || exit 1
	eval $lockvar=$lockf

	while ! staffer ln -s $hostname.$STAFFER.$$ $lockf 2> /dev/null; do
		basews=`basename $CODEMGR_WS`
		ls -l $lockf | nawk '{print $NF}' | IFS=. read host user pid
		if [ "$host" != "$hostname" ]; then
			echo "$MACH build of $basews apparently" \
			    "already started by $user on $host as $pid."
			exit 1
		elif kill -s 0 $pid 2>/dev/null; then
			echo "$MACH build of $basews already started" \
			    "by $user as $pid."
			exit 1
		else
			# stale lock; clear it out and try again
			rm -f $lockf
		fi
	done
}

#
# Return the list of interesting proto areas, depending on the current
# options.
#
function allprotos {
	typeset roots="$ROOT $STUBROOT"

	if [[ "$F_FLAG" = n && "$MULTI_PROTO" = yes ]]; then
		roots="$roots $ROOT-nd $STUBROOT-nd"
	fi

	if [[ $O_FLAG = y ]]; then
		roots="$roots $ROOT-closed"
		[ $MULTI_PROTO = yes ] && roots="$roots $ROOT-nd-closed"
	fi

	echo $roots
}

# Ensure no other instance of this script is running on this host.
# LOCKNAME can be set in <env_file>, and is by default, but is not
# required due to the use of $ATLOG below.
if [ -n "$LOCKNAME" ]; then
	create_lock /tmp/$LOCKNAME "lockfile"
fi
#
# Create from one, two, or three other locks:
#	$ATLOG/nightly.lock
#		- protects against multiple builds in same workspace
#	$PARENT_WS/usr/src/nightly.$MACH.lock
#		- protects against multiple 'u' copy-backs
#	$NIGHTLY_PARENT_ROOT/nightly.lock
#		- protects against multiple 'U' copy-backs
#
# Overriding ISUSER to 1 causes the lock to be created as root if the
# script is run as root.  The default is to create it as $STAFFER.
ISUSER=1 create_lock $ATLOG/nightly.lock "atloglockfile"
if [ "$u_FLAG" = "y" ]; then
	create_lock $PARENT_WS/usr/src/nightly.$MACH.lock "ulockfile"
fi
if [ "$U_FLAG" = "y" ]; then
	# NIGHTLY_PARENT_ROOT is written as root if script invoked as root.
	ISUSER=1 create_lock $NIGHTLY_PARENT_ROOT/nightly.lock "Ulockfile"
fi

# Locks have been taken, so we're doing a build and we're committed to
# the directories we may have created so far.
newdirlist=

#
# Create mail_msg_file
#
mail_msg_file="${TMPDIR}/mail_msg"
touch $mail_msg_file
build_time_file="${TMPDIR}/build_time"
build_environ_file="${TMPDIR}/build_environ"
touch $build_environ_file
#
#	Move old LOGFILE aside
#	ATLOG directory already made by 'create_lock' above
#
if [ -f $LOGFILE ]; then
	mv -f $LOGFILE ${LOGFILE}-
fi
#
#	Build OsNet source
#
START_DATE=`date`
SECONDS=0
echo "\n==== Nightly $maketype build started:   $START_DATE ====" \
    | tee -a $LOGFILE > $build_time_file

echo "\nBuild project:  $build_project\nBuild taskid:   $build_taskid" | \
    tee -a $mail_msg_file >> $LOGFILE

# make sure we log only to the nightly build file
build_noise_file="${TMPDIR}/build_noise"
exec </dev/null >$build_noise_file 2>&1

if [ -f /etc/nightly.conf ]; then
	echo "\n==== Contents of /etc/nightly.conf ====\n" >> $LOGFILE
	cat /etc/nightly.conf >> $LOGFILE
fi

if ! run_hook SYS_PRE_NIGHTLY; then
	exit 1
fi
if ! run_hook PRE_NIGHTLY; then
	exit 1
fi

echo "\n==== list of environment variables ====\n" >> $LOGFILE
env >> $LOGFILE

echo "\n==== Nightly argument issues ====\n" | tee -a $mail_msg_file >> $LOGFILE

if [ "$T_FLAG" = "y" ]; then
	obsolete_build TRACE | tee -a $mail_msg_file >> $LOGFILE
fi

if [ "$z_FLAG" = "y" ]; then
	obsolete_build "compressed archive (-z)" | tee -a $mail_msg_file >> $LOGFILE
fi

if is_source_build; then
	if [ "$i_FLAG" = "y" -o "$i_CMD_LINE_FLAG" = "y" ]; then
		echo "WARNING: the -S flags do not support incremental" \
		    "builds; forcing clobber\n" | tee -a $mail_msg_file >> $LOGFILE
		i_FLAG=n
		i_CMD_LINE_FLAG=n
	fi
	if [ "$N_FLAG" = "n" ]; then
		echo "WARNING: the -S flags do not support protocmp;" \
		    "protocmp disabled\n" | \
		    tee -a $mail_msg_file >> $LOGFILE
		N_FLAG=y
	fi
	if [ "$l_FLAG" = "y" ]; then
		echo "WARNING: the -S flags do not support lint;" \
		    "lint disabled\n" | tee -a $mail_msg_file >> $LOGFILE
		l_FLAG=n
	fi
	if [ "$P_FLAG" = "y" ]; then
		echo "WARNING: the -S flags are incompatible with a Parfait build;" \
		    "Parfait disabled\n" | tee -a  $mail_msg_file >> $LOGFILE
		P_FLAG=n
	fi
	if [ "$C_FLAG" = "y" ]; then
		echo "WARNING: the -S flags do not support cstyle;" \
		    "cstyle check disabled\n" | tee -a $mail_msg_file >> $LOGFILE
		C_FLAG=n
	fi
else
	if [ "$N_FLAG" = "y" ]; then
		if [ "$p_FLAG" = "y" ]; then
			cat <<EOF | tee -a $mail_msg_file >> $LOGFILE
WARNING: the p option (create packages) is set, but so is the N option (do
         not run protocmp); this is dangerous; you should unset the N option
EOF
		else
			cat <<EOF | tee -a $mail_msg_file >> $LOGFILE
Warning: the N option (do not run protocmp) is set; it probably shouldn't be
EOF
		fi
		echo "" | tee -a $mail_msg_file >> $LOGFILE
	fi
	if [ "$P_FLAG" = "y" -a "$i_FLAG" = "y" ]; then
		# There is no easy way for the parfait analyser to distinguish
		# between debug and non-debug .bc files, so 'i' trumps 'P' and
		# we decrease the chance of spurious failures.
		echo "\nIncremental build selected, disabling Parfait\n" \
			| tee -a $mail_msg_file >> $LOGFILE
		P_FLAG="n"
	fi
fi

if [ "$D_FLAG" = "n" -a "$l_FLAG" = "y" ]; then
	#
	# In the past we just complained but went ahead with the lint
	# pass, even though the proto area was built non-DEBUG.  It's
	# unlikely that non-DEBUG headers will make a difference, but
	# rather than assuming it's a safe combination, force the user
	# to specify a DEBUG build.
	#
	echo "WARNING: DEBUG build not requested; disabling lint.\n" \
	    | tee -a $mail_msg_file >> $LOGFILE
	l_FLAG=n
fi

if [ "$f_FLAG" = "y" ]; then
	if [ "$i_FLAG" = "y" ]; then
		echo "WARNING: the -f flag cannot be used during incremental" \
		    "builds; ignoring -f\n" | tee -a $mail_msg_file >> $LOGFILE
		f_FLAG=n
	fi
	if [ "${l_FLAG}${p_FLAG}" != "yy" ]; then
		echo "WARNING: the -f flag requires -l, and -p;" \
		    "ignoring -f\n" | tee -a $mail_msg_file >> $LOGFILE
		f_FLAG=n
	fi
fi

if [ "$w_FLAG" = "y" -a ! -d $ROOT ]; then
	echo "WARNING: -w specified, but $ROOT does not exist;" \
	    "ignoring -w\n" | tee -a $mail_msg_file >> $LOGFILE
	w_FLAG=n
fi

if [ "$t_FLAG" = "n" ]; then
	#
	# We're not doing a tools build, so make sure elfsign(1) is
	# new enough to safely sign non-crypto binaries.  We test
	# debugging output from elfsign to detect the old version.
	#
	newelfsigntest=`SUNW_CRYPTO_DEBUG=stderr /usr/bin/elfsign verify \
	    -e /usr/lib/security/pkcs11_softtoken.so.1 2>&1 \
	    | egrep algorithmOID`
	if [ -z "$newelfsigntest" ]; then
		echo "WARNING: /usr/bin/elfsign out of date;" \
		    "will only sign crypto modules\n" | \
		    tee -a $mail_msg_file >> $LOGFILE
		export ELFSIGN_OBJECT=true
	elif [ "$VERIFY_ELFSIGN" = "y" ]; then
		echo "WARNING: VERIFY_ELFSIGN=y requires" \
		    "the -t flag; ignoring VERIFY_ELFSIGN\n" | \
		    tee -a $mail_msg_file >> $LOGFILE
	fi
fi

[ "$O_FLAG" = y ] && MULTI_PROTO=yes

case $MULTI_PROTO in
yes|no)	;;
*)
	echo "WARNING: MULTI_PROTO is \"$MULTI_PROTO\"; " \
	    "should be \"yes\" or \"no\"." | tee -a $mail_msg_file >> $LOGFILE
	echo "Setting MULTI_PROTO to \"no\".\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
	export MULTI_PROTO=no
	;;
esac

# If CODESIGN_USER is set, we'll want the crypto that we just built.
if [[ -n "$CODESIGN_USER" && -n "$ON_CRYPTO_BINS" ]]; then
	echo "Clearing ON_CRYPTO_BINS for signing build." >> "$LOGFILE"
	unset ON_CRYPTO_BINS
fi

echo "\n==== Build version ====\n" | tee -a $mail_msg_file >> $LOGFILE
echo $VERSION | tee -a $mail_msg_file >> $LOGFILE

# Save the current proto area if we're comparing against the last build
if [ "$w_FLAG" = "y" ]; then
	typeset rdirs="${ROOT} ${STUBROOT}"
	if [ "$MULTI_PROTO" = "yes" ]; then
		rdirs="${rdirs} ${ROOT}-nd ${STUBROOT}-nd"
	fi

	for rd in ${rdirs}; do
		if [ -d ${rd} ]; then
			rm -rf ${rd}.prev
			mv ${rd} ${rd}.prev
		fi
	done
fi

# Echo the SCM types of $CODEMGR_WS and $BRINGOVER_WS
function wstypes {
	typeset parent_type child_type junk

	CODEMGR_WS="$BRINGOVER_WS" "$WHICH_SCM" 2>/dev/null \
	    | read parent_type junk
	if [[ -z "$parent_type" || "$parent_type" == unknown ]]; then
		# Probe BRINGOVER_WS to determine its type
		if [[ $BRINGOVER_WS == svn*://* ]]; then
			parent_type="subversion"
		elif [[ $BRINGOVER_WS == file://* ]] &&
		    egrep -s "This is a Subversion repository" \
		    ${BRINGOVER_WS#file://}/README.txt 2> /dev/null; then
			parent_type="subversion"
		elif [[ $BRINGOVER_WS == ssh://* ]]; then
			parent_type="mercurial"
		elif svn info $BRINGOVER_WS > /dev/null 2>&1; then
			parent_type="subversion"
		elif [[ $BRINGOVER_WS == http://* ]] && \
		    http_get "$BRINGOVER_WS/?cmd=heads" | \
		    egrep -s "application/mercurial" 2> /dev/null; then
			parent_type="mercurial"
		else
			parent_type="none"
		fi
	fi

	# Probe CODEMGR_WS to determine its type
	if [[ -d $CODEMGR_WS ]]; then
		$WHICH_SCM | read child_type junk || exit 1
	fi

	# fold both unsupported and unrecognized results into "none"
	case "$parent_type" in
	none|subversion|teamware|mercurial)
		;;
	*)	parent_type=none
		;;
	esac
	case "$child_type" in
	none|subversion|teamware|mercurial)
		;;
	*)	child_type=none
		;;
	esac

	echo $child_type $parent_type
}

wstypes | read SCM_TYPE PARENT_SCM_TYPE
export SCM_TYPE PARENT_SCM_TYPE

#
#	Decide whether to clobber
#
if [ "$i_FLAG" = "n" -a -d "$SRC" ]; then
	echo "\n==== Make clobber at `date` ====\n" >> $LOGFILE

	cd $SRC
	# remove old clobber file
	rm -f $SRC/clobber.out
	rm -f $SRC/clobber-${MACH}.out

	# Remove all .make.state* files, just in case we are restarting
	# the build after having interrupted a previous 'make clobber'.
	find . \( -name SCCS -o -name .hg -o -name .svn \
		-o -name 'interfaces.*' \) -prune \
		-o -name '.make.*' -print | xargs rm -f

	$MAKE -ek clobber 2>&1 | tee -a $SRC/clobber-${MACH}.out >> $LOGFILE
	echo "\n==== Make clobber ERRORS ====\n" >> $mail_msg_file
	grep "$MAKE:" $SRC/clobber-${MACH}.out |
		egrep -v "Ignoring unknown host" \
		>> $mail_msg_file

	if [[ "$t_FLAG" = "y" || "$O_FLAG" = "y" ]]; then
		echo "\n==== Make tools clobber at `date` ====\n" >> $LOGFILE
		cd ${TOOLS}
		rm -f ${TOOLS}/clobber-${MACH}.out
		$MAKE TOOLS_PROTO=$TOOLS_PROTO -ek clobber 2>&1 | \
			tee -a ${TOOLS}/clobber-${MACH}.out >> $LOGFILE
		echo "\n==== Make tools clobber ERRORS ====\n" \
			>> $mail_msg_file
		grep "$MAKE:" ${TOOLS}/clobber-${MACH}.out \
			>> $mail_msg_file
		rm -rf ${TOOLS_PROTO}
		mkdir -p ${TOOLS_PROTO}
	fi

	typeset roots=$(allprotos)
	echo "\n\nClearing $roots" >> "$LOGFILE"
	rm -rf $roots

	# Get back to a clean workspace as much as possible to catch
	# problems that only occur on fresh workspaces.
	# Remove all .make.state* files, libraries, and .o's that may
	# have been omitted from clobber.  A couple of libraries are
	# under source code control, so leave them alone.
	# We should probably blow away temporary directories too.
	cd $SRC
	find $relsrcdirs \( -name SCCS -o -name .hg -o -name .svn \
	    -o -name 'interfaces.*' \) -prune -o \
	    \( -name '.make.*' -o -name 'lib*.a' -o -name 'lib*.so*' -o \
	       -name '*.o' \) -print | \
	    grep -v 'tools/ctf/dwarf/.*/libdwarf' | xargs rm -f

	# If we're doing a parfait build, clobber the bytecode
	if [ "$P_FLAG" = "y" ]; then
		# Until OpenSSL is updated to remove this file, we need to
		# make sure we don't clobber it and munge the workspace.
		EXCLUDETHIS=usr/src/common/openssl/crypto/des/makefile.bc
       		echo "\nClobbering old parfait bytecode files\n" \
			| tee -a $mail_msg_file >> $LOGFILE
		( cd $CODEMGR_WS ; \
			find $SRC $SRC/../closed -name '*.bc' -type f \
			-newer ${EXCLUDETHIS} | xargs rm -f )
	fi
else
	echo "\n==== No clobber at `date` ====\n" >> $LOGFILE
fi

type bringover_teamware > /dev/null 2>&1 || function bringover_teamware {
	# sleep on the parent workspace's lock
	while egrep -s write $BRINGOVER_WS/Codemgr_wsdata/locks
	do
		sleep 120
	done

	if [[ -z $BRINGOVER ]]; then
		BRINGOVER=$TEAMWARE/bin/bringover
	fi

	staffer $BRINGOVER -c "nightly update" -p $BRINGOVER_WS \
	    -w $CODEMGR_WS $BRINGOVER_FILES < /dev/null 2>&1 ||
		touch $TMPDIR/bringover_failed

        staffer bringovercheck $CODEMGR_WS >$TMPDIR/bringovercheck.out 2>&1
	if [ -s $TMPDIR/bringovercheck.out ]; then
		echo "\n==== POST-BRINGOVER CLEANUP NOISE ====\n"
		cat $TMPDIR/bringovercheck.out
	fi
}

type bringover_mercurial > /dev/null 2>&1 || function bringover_mercurial {
	typeset -x PATH=$PATH

	# If the repository doesn't exist yet, then we want to populate it.
	if [[ ! -d $CODEMGR_WS/.hg ]]; then
		staffer hg init $CODEMGR_WS
		staffer echo "[paths]" > $CODEMGR_WS/.hg/hgrc
		staffer echo "default=$BRINGOVER_WS" >> $CODEMGR_WS/.hg/hgrc
		touch $TMPDIR/new_repository
	fi

	#
	# If the user set CLOSED_BRINGOVER_WS and didn't set CLOSED_IS_PRESENT
	# to "no," then we'll want to initialise the closed repository
	#
	# We use $orig_closed_is_present instead of $CLOSED_IS_PRESENT,
	# because for newly-created source trees, the latter will be "no"
	# until after the bringover completes.
	#
	if [[ "$orig_closed_is_present" != "no" && \
	    -n "$CLOSED_BRINGOVER_WS" && \
	    ! -d $CODEMGR_WS/usr/closed/.hg ]]; then
		staffer mkdir -p $CODEMGR_WS/usr/closed
		staffer hg init $CODEMGR_WS/usr/closed
		staffer echo "[paths]" > $CODEMGR_WS/usr/closed/.hg/hgrc
		staffer echo "default=$CLOSED_BRINGOVER_WS" >> $CODEMGR_WS/usr/closed/.hg/hgrc
		touch $TMPDIR/new_closed
		export CLOSED_IS_PRESENT=yes
	fi

	typeset -x HGMERGE="/bin/false"

	#
	# If the user has changes, regardless of whether those changes are
	# committed, and regardless of whether those changes conflict, then
	# we'll attempt to merge them either implicitly (uncommitted) or
	# explicitly (committed).
	#
	# These are the messages we'll use to help clarify mercurial output
	# in those cases.
	#
	typeset mergefailmsg="\
***\n\
*** nightly was unable to automatically merge your changes.  You should\n\
*** redo the full merge manually, following the steps outlined by mercurial\n\
*** above, then restart nightly.\n\
***\n"
	typeset mergepassmsg="\
***\n\
*** nightly successfully merged your changes.  This means that your working\n\
*** directory has been updated, but those changes are not yet committed.\n\
*** After nightly completes, you should validate the results of the merge,\n\
*** then use hg commit manually.\n\
***\n"

	#
	# For each repository in turn:
	#
	# 1. Do the pull.  If this fails, dump the output and bail out.
	#
	# 2. If the pull resulted in an extra head, do an explicit merge.
	#    If this fails, dump the output and bail out.
	#
	# Because we can't rely on Mercurial to exit with a failure code
	# when a merge fails (Mercurial issue #186), we must grep the
	# output of pull/merge to check for attempted and/or failed merges.
	#
	# 3. If a merge failed, set the message and fail the bringover.
	#
	# 4. Otherwise, if a merge succeeded, set the message
	#
	# 5. Dump the output, and any message from step 3 or 4.
	#

	typeset HG_SOURCE=$BRINGOVER_WS
	if [ ! -f $TMPDIR/new_repository ]; then
		HG_SOURCE=$TMPDIR/open_bundle.hg
		staffer hg --cwd $CODEMGR_WS incoming --bundle $HG_SOURCE \
		    -v $BRINGOVER_WS > $TMPDIR/incoming_open.out

		#
		# If there are no incoming changesets, then incoming will
		# fail, and there will be no bundle file.  Reset the source,
		# to allow the remaining logic to complete with no false
		# negatives.  (Unlike incoming, pull will return success
		# for the no-change case.)
		#
		if (( $? != 0 )); then
			HG_SOURCE=$BRINGOVER_WS
		fi
	fi

	staffer hg --cwd $CODEMGR_WS pull -u $HG_SOURCE \
	    > $TMPDIR/pull_open.out 2>&1
	if (( $? != 0 )); then
		printf "%s: pull failed as follows:\n\n" "$CODEMGR_WS"
		cat $TMPDIR/pull_open.out
		if grep "^merging.*failed" $TMPDIR/pull_open.out > /dev/null 2>&1; then
			printf "$mergefailmsg"
		fi
		touch $TMPDIR/bringover_failed
		return
	fi

	if grep "not updating" $TMPDIR/pull_open.out > /dev/null 2>&1; then
		staffer hg --cwd $CODEMGR_WS merge \
		    >> $TMPDIR/pull_open.out 2>&1
		if (( $? != 0 )); then
			printf "%s: merge failed as follows:\n\n" \
			    "$CODEMGR_WS"
			cat $TMPDIR/pull_open.out
			if grep "^merging.*failed" $TMPDIR/pull_open.out \
			    > /dev/null 2>&1; then
				printf "$mergefailmsg"
			fi
			touch $TMPDIR/bringover_failed
			return
		fi
	fi

	printf "updated %s with the following results:\n" "$CODEMGR_WS"
	cat $TMPDIR/pull_open.out
	if grep "^merging" $TMPDIR/pull_open.out >/dev/null 2>&1; then
		printf "$mergepassmsg"
	fi
	printf "\n"

	#
	# We only want to update usr/closed if it exists, and we haven't been
	# told not to via $CLOSED_IS_PRESENT, and we actually know where to
	# pull from ($CLOSED_BRINGOVER_WS).
	#
	if [[ $CLOSED_IS_PRESENT = yes && \
	    -d $CODEMGR_WS/usr/closed/.hg && \
	    -n $CLOSED_BRINGOVER_WS ]]; then

		HG_SOURCE=$CLOSED_BRINGOVER_WS
		if [ ! -f $TMPDIR/new_closed ]; then
			HG_SOURCE=$TMPDIR/closed_bundle.hg
			staffer hg --cwd $CODEMGR_WS/usr/closed incoming \
			    --bundle $HG_SOURCE -v $CLOSED_BRINGOVER_WS \
			    > $TMPDIR/incoming_closed.out

			#
			# If there are no incoming changesets, then incoming will
			# fail, and there will be no bundle file.  Reset the source,
			# to allow the remaining logic to complete with no false
			# negatives.  (Unlike incoming, pull will return success
			# for the no-change case.)
			#
			if (( $? != 0 )); then
				HG_SOURCE=$CLOSED_BRINGOVER_WS
			fi
		fi

		staffer hg --cwd $CODEMGR_WS/usr/closed pull -u \
			$HG_SOURCE > $TMPDIR/pull_closed.out 2>&1
		if (( $? != 0 )); then
			printf "closed pull failed as follows:\n\n"
			cat $TMPDIR/pull_closed.out
			if grep "^merging.*failed" $TMPDIR/pull_closed.out \
			    > /dev/null 2>&1; then
				printf "$mergefailmsg"
			fi
			touch $TMPDIR/bringover_failed
			return
		fi

		if grep "not updating" $TMPDIR/pull_closed.out > /dev/null 2>&1; then
			staffer hg --cwd $CODEMGR_WS/usr/closed merge \
			    >> $TMPDIR/pull_closed.out 2>&1
			if (( $? != 0 )); then
				printf "closed merge failed as follows:\n\n"
				cat $TMPDIR/pull_closed.out
				if grep "^merging.*failed" $TMPDIR/pull_closed.out > /dev/null 2>&1; then
					printf "$mergefailmsg"
				fi
				touch $TMPDIR/bringover_failed
				return
			fi
		fi

		printf "updated %s with the following results:\n" \
		    "$CODEMGR_WS/usr/closed"
		cat $TMPDIR/pull_closed.out
		if grep "^merging" $TMPDIR/pull_closed.out > /dev/null 2>&1; then
			printf "$mergepassmsg"
		fi
	fi

	#
	# Per-changeset output is neither useful nor manageable for a
	# newly-created repository.
	#
	if [ -f $TMPDIR/new_repository ]; then
		return
	fi

	printf "\nadded the following changesets to open repository:\n"
	cat $TMPDIR/incoming_open.out

	#
	# The closed repository could have been newly created, even though
	# the open one previously existed...
	#
	if [ -f $TMPDIR/new_closed ]; then
		return
	fi

	if [ -f $TMPDIR/incoming_closed.out ]; then
		printf "\nadded the following changesets to closed repository:\n"
		cat $TMPDIR/incoming_closed.out
	fi
}

type bringover_subversion > /dev/null 2>&1 || function bringover_subversion {
	typeset -x PATH=$PATH

	if [[ ! -d $CODEMGR_WS/.svn ]]; then
		staffer svn checkout $BRINGOVER_WS $CODEMGR_WS ||
			touch $TMPDIR/bringover_failed
	else
		typeset root
		root=$(staffer svn info $CODEMGR_WS |
			nawk '/^Repository Root:/ {print $NF}')
		if [[ $root != $BRINGOVER_WS ]]; then
			# We fail here because there's no way to update
			# from a named repo.
			cat <<-EOF
			\$BRINGOVER_WS doesn't match repository root:
			  \$BRINGOVER_WS:  $BRINGOVER_WS
			  Repository root: $root
			EOF
			touch $TMPDIR/bringover_failed
		else
			# If a conflict happens, svn still exits 0.
			staffer svn update $CODEMGR_WS | tee $TMPDIR/pull.out ||
				touch $TMPDIR/bringover_failed
			if grep "^C" $TMPDIR/pull.out > /dev/null 2>&1; then
				touch $TMPDIR/bringover_failed
			fi
		fi
	fi
}

type bringover_none > /dev/null 2>&1 || function bringover_none {
	echo "Couldn't figure out what kind of SCM to use for $BRINGOVER_WS."
	touch $TMPDIR/bringover_failed
}

# Parse the URL.
# The other way to deal with empty components is to echo a string that can
# be eval'ed by the caller to associate values (possibly empty) with
# variables.  In that case, passing in a printf string would let the caller
# choose the variable names.
function parse_url {
	typeset url method host port path

	url=$1
	method=${url%%://*}
	host=${url#$method://}
	path=${host#*/}
	host=${host%%/*}
	if [[ $host == *:* ]]; then
		port=${host#*:}
		host=${host%:*}
	fi

	# method can never be empty.  host can only be empty if method is
	# file, and that implies it's localhost.  path can default to / if
	# it's otherwise empty, leaving port as the only component without
	# a default, so it has to go last.
	echo $method ${host:-localhost} ${path:-/} $port
}

function http_get {
	typeset url method host port path

	url=$1

	if [[ -n $http_proxy ]]; then
		parse_url $http_proxy | read method host path port
		echo "GET $url HTTP/1.0\r\n" |
			mconnect -p ${port:-8080} $host
	else
		parse_url $url | read method host path port
		echo "GET $path HTTP/1.0\r\n" |
			mconnect -p ${port:-80} $host
	fi
}

#
# proto_update: A function allowing different methods of updating
# your proto area. The default is to use rsync, falling back to tar.
#
function proto_update {
	typeset method
	typeset srcloc
	typeset dstloc

	method=$1
	srcloc=$2
	dstloc=$3

	RSYNC=/usr/bin/rsync
	TAR=/usr/bin/tar

	if [ "$method" = "rsync" -a ! -x $RSYNC ]; then
		method="tar"
		echo "$RSYNC not found, updating proto area with $TAR" | \
			tee -a $mail_msg_file >> $LOGFILE
	fi

	if [ "$method" != "rsync" -a "$method" != "tar" ]; then
		echo "Invalid or unsupported proto update method: $method\n" \
		    "Not updating proto area $dstloc" | \
		tee -a $mail_msg_file >> $LOGFILE
		return
	fi

	echo "Updating $dstloc from $srcloc" | tee -a $mail_msg_file >> $LOGFILE

	if [ "$method" = "rsync" ]; then
		IDENT_USER=${RSYNC_IDENT_USER:-$STAFFER}
		ARGS="/usr/bin/ssh -l $IDENT_USER"
		[[ -n $RSYNC_IDENT_KEY ]] && ARGS="$ARGS -i $RSYNC_IDENT_KEY"
		$RSYNC -e "$ARGS" -aHz --delete $srcloc/* $dstloc 2>&1 | \
			tee -a $mail_msg_file >> $LOGFILE
	else 
		# we're using tar, as in days of yore
		rm -rf $dstloc/* > /dev/null 2>&1
		mkdir -p $dstloc
		(cd $srcloc ; $TAR cEf - . | \
			(cd $dstloc ; umask 0 ; $TAR xpf - ) ) 2>&1 | \
		tee -a $mail_msg_file >> $LOGFILE
	fi
}


#
#	Decide whether to bringover to the codemgr workspace
#
if [ "$n_FLAG" = "n" ]; then

	if [[ $SCM_TYPE != none && $SCM_TYPE != $PARENT_SCM_TYPE ]]; then
		echo "cannot bringover from $PARENT_SCM_TYPE to $SCM_TYPE, " \
		    "quitting at `date`." | tee -a $mail_msg_file >> $LOGFILE
		exit 1
	fi

	if ! run_hook PRE_BRINGOVER; then
		exit 1
	fi

	echo "\n==== bringover to $CODEMGR_WS at `date` ====\n" >> $LOGFILE
	echo "\n==== BRINGOVER LOG ====\n" >> $mail_msg_file

	eval "bringover_${PARENT_SCM_TYPE}" 2>&1 |
		tee -a $mail_msg_file >> $LOGFILE

	if [ -f $TMPDIR/bringover_failed ]; then
		rm -f $TMPDIR/bringover_failed
		build_ok=n
		echo "trouble with bringover, quitting at `date`." |
			tee -a $mail_msg_file >> $LOGFILE
		exit 1
	fi

	#
	# It's possible that we used the bringover above to create
	# $CODEMGR_WS.  If so, then SCM_TYPE was previously "none,"
	# but should now be the same as $BRINGOVER_WS.
	#
	[[ $SCM_TYPE = none ]] && SCM_TYPE=$PARENT_SCM_TYPE

	if ! run_hook POST_BRINGOVER; then
		exit 1
	fi

	#
	# Possible transition from pre-split workspace to split
	# workspace.  See if the bringover changed anything.
	#
	CLOSED_IS_PRESENT="$orig_closed_is_present"
	check_closed_tree

else
	echo "\n==== No bringover to $CODEMGR_WS ====\n" >> $LOGFILE
fi

if [[ "$O_FLAG" = y && "$CLOSED_IS_PRESENT" != "yes" ]]; then
	build_ok=n
	echo "OpenSolaris binary deliverables need usr/closed." \
	    | tee -a "$mail_msg_file" >> $LOGFILE
	exit 1
fi

if [ "$CLOSED_IS_PRESENT" = no ]; then
	#
	# Not all consolidations have a closed tree, and even if they
	# did, they wouldn't necessarily have signed crypto.  But if
	# the current source base does have signed crypto and it can't
	# be generated, error out, rather than silently building
	# unusable binaries.
	#
	grep -s ELFSIGN_CRYPTO "$SRC/Makefile.master" > /dev/null
	if (( $? == 0 )); then
		crypto_is_present >> "$LOGFILE"
		if (( $? != 0 )); then
			build_ok=n
			echo "A crypto tarball must be provided when" \
			    "there is no closed tree." |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
			exit 1
		fi
	fi
fi

echo "\n==== Build environment ====\n" | tee -a $build_environ_file >> $LOGFILE

# System
whence uname | tee -a $build_environ_file >> $LOGFILE
uname -a 2>&1 | tee -a $build_environ_file >> $LOGFILE
echo | tee -a $build_environ_file >> $LOGFILE

# nightly
echo "$0 $@" | tee -a $build_environ_file >> $LOGFILE
if [[ $nightly_path = "/opt/onbld/bin/nightly" ]]; then
	# We assume that if you have /opt/onbld/bin/nightly, then
	# you have some form of the onbld package installed. If this
	# is not true then your nightly is almost definitely out of
	# date and should not be used.
	/usr/bin/pkg info \*onbld\* | \
	    egrep "Name:|Publisher:|Version:|Packaging:|FMRI:"
else
	echo "$nightly_ls"
fi | tee -a $build_environ_file >> $LOGFILE
echo | tee -a $build_environ_file >> $LOGFILE

# make
whence $MAKE | tee -a $build_environ_file >> $LOGFILE
$MAKE -v | tee -a $build_environ_file >> $LOGFILE
echo "number of concurrent jobs = $DMAKE_MAX_JOBS" |
    tee -a $build_environ_file >> $LOGFILE

#
# Report the compiler versions.
#

if [[ ! -f $SRC/Makefile ]]; then
	build_ok=n
	echo "\nUnable to find \"Makefile\" in $SRC." | \
	    tee -a $build_environ_file >> $LOGFILE
	exit 1
fi

( cd $SRC
  for target in cc-version cc64-version java-version; do
	echo
	#
	# Put statefile somewhere we know we can write to rather than trip
	# over a read-only $srcroot.
	#
	rm -f $TMPDIR/make-state
	export SRC
	if $MAKE -K $TMPDIR/make-state -e $target 2>/dev/null; then
		continue
	fi
	touch $TMPDIR/nocompiler
  done
  echo
) | tee -a $build_environ_file >> $LOGFILE

if [ -f $TMPDIR/nocompiler ]; then
	rm -f $TMPDIR/nocompiler
	build_ok=n
	echo "Aborting due to missing compiler." |
		tee -a $build_environ_file >> $LOGFILE
	exit 1
fi

# as
whence as | tee -a $build_environ_file >> $LOGFILE
as -V 2>&1 | head -1 | tee -a $build_environ_file >> $LOGFILE
echo | tee -a $build_environ_file >> $LOGFILE

# Check that we're running a capable link-editor
whence ld | tee -a $build_environ_file >> $LOGFILE
LDVER=`ld -V 2>&1`
echo $LDVER | tee -a $build_environ_file >> $LOGFILE
LDVER=`echo $LDVER | sed -e "s/.*-1\.//" -e "s/:.*//"`
if [ `expr $LDVER \< 422` -eq 1 ]; then
	echo "The link-editor needs to be at version 422 or higher to build" | \
	    tee -a $build_environ_file >> $LOGFILE
	echo "the latest stuff.  Hope your build works." | \
	    tee -a $build_environ_file >> $LOGFILE
fi

#
# Build and use the workspace's tools if requested
#
if [[ "$t_FLAG" = "y" || "$O_FLAG" = y ]]; then
	set_non_debug_build_flags

	build_tools ${TOOLS_PROTO}
	if [[ $? != 0  && "$t_FLAG" = y ]]; then
		use_tools $TOOLS_PROTO
	fi
fi

if [ "$i_FLAG" = "y" -a "$SH_FLAG" = "y" ]; then
	echo "\n==== NOT Building base OS-Net source ====\n" | \
	    tee -a $LOGFILE >> $mail_msg_file
else
	# timestamp the start of the normal build; the findunref tool uses it.
	touch $SRC/.build.tstamp

	[ "$P_FLAG" = "y" ] && parfait_setup
	normal_build
fi

#
# Generate the THIRDPARTYLICENSE files if needed.  This is done after
# the build, so that dynamically-created license files are there.
# It's done before findunref to help identify license files that need
# to be added to tools/opensolaris/license-list.
#
if [ "$O_FLAG" = y -a "$build_ok" = y ]; then
	echo "\n==== Generating THIRDPARTYLICENSE files ====\n" |
	    tee -a "$mail_msg_file" >> "$LOGFILE"

	if [ -d $ROOT/licenses/usr ]; then
		( cd $ROOT/licenses ; \
		    mktpl $SRC/pkg/license-list ) >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create THIRDPARTYLICENSE files" |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
		fi
	else
		echo "No licenses found under $ROOT/licenses" |
		    tee -a "$mail_msg_file" >> "$LOGFILE"
	fi
fi

ORIG_SRC=$SRC
BINARCHIVE=${CODEMGR_WS}/bin-${MACH}.cpio.Z

if [ "$SE_FLAG" = "y" -o "$SD_FLAG" = "y" -o "$SH_FLAG" = "y" ]; then
	save_binaries
fi


# EXPORT_SRC comes after CRYPT_SRC since a domestic build will need
# $SRC pointing to the export_source usr/src.

if [ "$SE_FLAG" = "y" -o "$SD_FLAG" = "y" -o "$SH_FLAG" = "y" ]; then
	if [ "$SD_FLAG" = "y" -a $build_ok = y ]; then
	    set_up_source_build ${CODEMGR_WS} ${CRYPT_SRC} CRYPT_SRC
	fi

	if [ $build_ok = y ]; then
	    set_up_source_build ${CODEMGR_WS} ${EXPORT_SRC} EXPORT_SRC
	fi
fi

if [ "$SD_FLAG" = "y" -a $build_ok = y ]; then
	# drop the crypt files in place.
	cd ${EXPORT_SRC}
	echo "\nextracting crypt_files.cpio.Z onto export_source.\n" \
	    >> ${LOGFILE}
	zcat ${CODEMGR_WS}/crypt_files.cpio.Z | \
	    cpio -idmucvB 2>/dev/null >> ${LOGFILE}
	if [ "$?" = "0" ]; then
		echo "\n==== DOMESTIC extraction succeeded ====\n" \
		    >> $mail_msg_file
	else
		echo "\n==== DOMESTIC extraction failed ====\n" \
		    >> $mail_msg_file
	fi

fi

if [ "$SO_FLAG" = "y" -a "$build_ok" = y ]; then
	#
	# Copy the open sources into their own tree, set up the closed
	# binaries, and set up the environment.  The build looks for
	# the closed binaries in a location that depends on whether
	# it's a DEBUG build, so we might need to make two copies.
	#
	# If copy_source fails, it will have already generated an
	# error message and set build_ok=n, so we don't need to worry
	# about that here.
	#
	copy_source $CODEMGR_WS $OPEN_SRCDIR OPEN_SOURCE usr/src
fi

if [ "$SO_FLAG" = "y" -a "$build_ok" = y ]; then

	echo "\n==== Generating skeleton closed binaries for" \
	    "open-only build ====\n" | \
	    tee -a $LOGFILE >> $mail_msg_file

	rm -rf $CODEMGR_WS/closed.skel
	if [ "$D_FLAG" = y ]; then
		mkclosed $MACH $ROOT $CODEMGR_WS/closed.skel/root_$MACH \
		    >>$LOGFILE 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create skeleton DEBUG closed binaries." |
			    tee -a $mail_msg_file >> $LOGFILE
		fi
	fi
	if [ "$F_FLAG" = n ]; then
		root=$ROOT
		[ "$MULTI_PROTO" = yes ] && root=$ROOT-nd
		mkclosed $MACH $root $CODEMGR_WS/closed.skel/root_$MACH-nd \
		    >>$LOGFILE 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create skeleton non-DEBUG closed binaries." |
			    tee -a $mail_msg_file >> $LOGFILE
		fi
	fi
      
	SRC=$OPEN_SRCDIR/usr/src
	# Try not to clobber any user-provided closed binaries.
	export ON_CLOSED_BINS=$CODEMGR_WS/closed.skel
	export CLOSED_IS_PRESENT=no
fi

if is_source_build && [ $build_ok = y ] ; then
	# remove proto area(s) here, since we don't clobber
	rm -rf `allprotos`
	if [ "$t_FLAG" = "y" ]; then
		set_non_debug_build_flags
		ORIG_TOOLS=$TOOLS
		#
		# SRC was set earlier to point to the source build
		# source tree (e.g., $EXPORT_SRC).
		#
		TOOLS=${SRC}/tools
		TOOLS_PROTO=${TOOLS}/${TOOLS_PROTO_REL}; export TOOLS_PROTO
		build_tools ${TOOLS_PROTO}
		if [[ $? != 0 ]]; then
			use_tools ${TOOLS_PROTO}
		fi
	fi

	export EXPORT_RELEASE_BUILD ; EXPORT_RELEASE_BUILD=#
	normal_build
fi

if [[ "$SO_FLAG" = "y" && "$build_ok" = "y" ]]; then
	rm -rf $ON_CLOSED_BINS
fi

#
# There are several checks that need to look at the proto area, but
# they only need to look at one, and they don't care whether it's
# DEBUG or non-DEBUG.
#
if [[ "$MULTI_PROTO" = yes && "$D_FLAG" = n ]]; then
	checkroot=$ROOT-nd
else
	checkroot=$ROOT
fi

if [ "$build_ok" = "y" ]; then
	echo "\n==== Creating protolist system file at `date` ====" \
		>> $LOGFILE
	protolist $checkroot > $ATLOG/proto_list_${MACH}
	echo "==== protolist system file created at `date` ====\n" \
		>> $LOGFILE

	if [ "$N_FLAG" != "y" ]; then

		E1=
		f1=
		if [ -d "$SRC/pkgdefs" ]; then
			f1="$SRC/pkgdefs/etc/exception_list_$MACH"
		fi

		for f in $f1; do
			if [ -f "$f" ]; then
				E1="$E1 -e $f"
			fi
		done

		E2=
		f2=
		if [ -d "$SRC/pkg" ]; then
			f2="$f2 exceptions/packaging"
			if [ "$CLOSED_IS_PRESENT" = "no" ]; then
				f2="$f2 exceptions/packaging.open"
			else
				f2="$f2 exceptions/packaging.closed"
			fi
		fi

		for f in $f2; do
			if [ -f "$f" ]; then
				E2="$E2 -e $f"
			fi
		done
	fi

	if [ "$N_FLAG" != "y" -a -f $SRC/pkgdefs/Makefile ]; then
		echo "\n==== Impact on SVr4 packages ====\n" >> $mail_msg_file
		#
		# Compare the build's proto list with current package
		# definitions to audit the quality of package
		# definitions and makefile install targets. Use the
		# current exception list.
		#
		PKGDEFS_LIST=""
		for d in $abssrcdirs; do
			if [ -d $d/pkgdefs ]; then
				PKGDEFS_LIST="$PKGDEFS_LIST -d $d/pkgdefs"
			fi
		done

		$PROTOCMPTERSE \
		    "Files missing from the proto area:" \
		    "Files missing from packages:" \
		    "Inconsistencies between pkgdefs and proto area:" \
		    ${E1} \
		    ${PKGDEFS_LIST} \
		    $ATLOG/proto_list_${MACH} \
		    >> $mail_msg_file
	fi

	if [ "$N_FLAG" != "y" -a -d $SRC/pkg ]; then
		echo "\n==== Validating manifests against proto area ====\n" \
		    >> $mail_msg_file
		( cd $SRC/pkg ; $MAKE -e protocmp ROOT="$checkroot" ) \
		    >> $mail_msg_file

	fi

	if [ "$N_FLAG" != "y" -a -f "$REF_PROTO_LIST" ]; then
		echo "\n==== Impact on proto area ====\n" >> $mail_msg_file
		if [ -n "$E2" ]; then
			ELIST=$E2
		else
			ELIST=$E1
		fi
		$PROTOCMPTERSE \
			"Files in yesterday's proto area, but not today's:" \
			"Files in today's proto area, but not yesterday's:" \
			"Files that changed between yesterday and today:" \
			${ELIST} \
			-d $REF_PROTO_LIST \
			$ATLOG/proto_list_${MACH} \
			>> $mail_msg_file
	fi
fi

if [ "$u_FLAG" = "y"  -a "$build_ok" = "y" ]; then
	staffer cp $ATLOG/proto_list_${MACH} \
		$PARENT_WS/usr/src/proto_list_${MACH}
fi

# Update parent proto area if necessary. This is done now
# so that the proto area has either DEBUG or non-DEBUG kernels.
# Note that this clears out the lock file, so we can dispense with
# the variable now.
if [ "$U_FLAG" = "y" -a "$build_ok" = "y" ]; then

	# Allow use of an rsync uri for the destination
        METHOD=${PROTO_UPDATE_METHOD:-"rsync"}
	DEST=${RSYNC_PARENT:-$NIGHTLY_PARENT_ROOT}

	echo "\n==== Copying proto area to $DEST using $METHOD started at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE

	unset Ulockfile

	if [[ "$MULTI_PROTO" = no || "$D_FLAG" = y ]]; then
		proto_update $METHOD $ROOT $DEST
	fi

	if [[ "$MULTI_PROTO" = yes && "$F_FLAG" = n ]]; then
		proto_update $METHOD $ROOT-nd $DEST-nd
	fi

	if [ -n "$NIGHTLY_PARENT_TOOLS_ROOT" ]; then
		DEST=${RSYNC_TOOLS_PARENT:-$NIGHTLY_PARENT_TOOLS_ROOT}
		echo "\n==== Copying tools proto area to $DEST ====\n" | \
		    tee -a $LOGFILE >> $mail_msg_file

		if [[ "$MULTI_PROTO" = no || "$D_FLAG" = y ]]; then
			proto_update $METHOD $TOOLS_PROTO $DEST
		fi
	fi
	echo "\n==== proto area update finished at `date` ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE
fi

#
# ELF verification: ABI (-A) and runtime (-r) checks
#
if [[ ($build_ok = y) && ( ($A_FLAG = y) || ($r_FLAG = y) ) ]]; then
	# Directory ELF-data.$MACH holds the files produced by these tests.
	elf_ddir=$SRC/ELF-data.$MACH

	# If there is a previous ELF-data backup directory, remove it. Then,
	# rotate current ELF-data directory into its place and create a new
	# empty directory
	rm -rf $elf_ddir.ref
	if [[ -d $elf_ddir ]]; then
		mv $elf_ddir $elf_ddir.ref
	fi
	mkdir -p $elf_ddir

	# Call find_elf to produce a list of the ELF objects in the proto area.
	# This list is passed to check_rtime and interface_check, preventing
	# them from separately calling find_elf to do the same work twice.
	find_elf -fr $checkroot > $elf_ddir/object_list

	if [[ $A_FLAG = y ]]; then
	       	echo "\n==== Check versioning and ABI information ====\n"  | \
		    tee -a $LOGFILE >> $mail_msg_file

		# Produce interface description for the proto. Report errors.
		interface_check -o -w $elf_ddir -f object_list \
			-i interface -E interface.err
		if [[ -s $elf_ddir/interface.err ]]; then
			tee -a $LOGFILE < $elf_ddir/interface.err \
				>> $mail_msg_file
		fi

		# If ELF_DATA_BASELINE_DIR is defined, compare the new interface
		# description file to that from the baseline gate. Issue a
		# warning if the baseline is not present, and keep going.
		if [[ "$ELF_DATA_BASELINE_DIR" != '' ]]; then
			base_ifile="$ELF_DATA_BASELINE_DIR/interface"

		       	echo "\n==== Compare versioning and ABI information" \
			    "to baseline ====\n"  | \
			    tee -a $LOGFILE >> $mail_msg_file
		       	echo "Baseline:  $base_ifile\n" >> $LOGFILE

			if [[ -f $base_ifile ]]; then
				if [[ ${ELF_DATA_BASELINE_AGE:-0} -gt 0 ]]; then
					find $base_ifile \! -mtime \
					    -$ELF_DATA_BASELINE_AGE \
					    -exec echo "baseline" \{\} \
					    "is more than" \
					    $ELF_DATA_BASELINE_AGE \
					    "days old" \; | \
					    tee -a $LOGFILE >> $mail_msg_file
				fi
				interface_cmp -d -o $base_ifile \
				    $elf_ddir/interface > $elf_ddir/interface.cmp
				if [[ -s $elf_ddir/interface.cmp ]]; then
					echo | tee -a $LOGFILE >> $mail_msg_file
					tee -a $LOGFILE < \
					    $elf_ddir/interface.cmp \
					    >> $mail_msg_file
				fi
			else
			       	echo "baseline not available. comparison" \
                                    "skipped" | \
				    tee -a $LOGFILE >> $mail_msg_file
			fi

		fi
	fi

	if [[ $r_FLAG = y ]]; then
		echo "\n==== Check ELF runtime attributes ====\n" | \
		    tee -a $LOGFILE >> $mail_msg_file

		# If we're doing a DEBUG build the proto area will be left
		# with debuggable objects, thus don't assert -s.
		if [[ $D_FLAG = y ]]; then
			rtime_sflag=""
		else
			rtime_sflag="-s"
		fi
		check_rtime -i -m -v $rtime_sflag -o -w $elf_ddir \
			-D object_list  -f object_list -E runtime.err \
			-I runtime.attr.raw

		# check_rtime -I output needs to be sorted in order to 
		# compare it to that from previous builds.
		sort $elf_ddir/runtime.attr.raw > $elf_ddir/runtime.attr
		rm $elf_ddir/runtime.attr.raw

		# Report errors
		if [[ -s $elf_ddir/runtime.err ]]; then
			tee -a $LOGFILE < $elf_ddir/runtime.err \
				>> $mail_msg_file
		fi

		# If there is an ELF-data directory from a previous build,
		# then diff the attr files. These files contain information
		# about dependencies, versioning, and runpaths. There is some
		# overlap with the ABI checking done above, but this also
		# flushes out non-ABI interface differences along with the
		# other information.
		echo "\n==== Diff ELF runtime attributes" \
		    "(since last build) ====\n" | \
		    tee -a $LOGFILE >> $mail_msg_file >> $mail_msg_file

		if [[ -f $elf_ddir.ref/runtime.attr ]]; then
			diff $elf_ddir.ref/runtime.attr \
				$elf_ddir/runtime.attr \
				>> $mail_msg_file
		fi
	fi

	# If -u set, copy contents of ELF-data.$MACH to the parent workspace.
	if [[ "$u_FLAG" = "y" ]]; then

		# If PARENT_ELF_DATA_DIR is defined then use that for the
		# destination of the ELF data files.
		if [[ -n "$PARENT_ELF_DATA_DIR" ]]; then
			p_elf_ddir=$PARENT_ELF_DATA_DIR/ELF-data.$MACH
		else
			p_elf_ddir=$PARENT_WS/usr/src/ELF-data.$MACH
		fi

		# If parent lacks the ELF-data.$MACH directory, create it
		if [[ ! -d $p_elf_ddir ]]; then
			staffer mkdir -p $p_elf_ddir
		fi

		# These files are used asynchronously by other builds for ABI
		# verification, as above for the -A option. As such, we require
		# the file replacement to be atomic. Copy the data to a temp
		# file in the same filesystem and then rename into place. 
		(
			cd $elf_ddir
			for elf_dfile in *; do
				staffer cp $elf_dfile \
				    ${p_elf_ddir}/${elf_dfile}.new
				staffer mv -f ${p_elf_ddir}/${elf_dfile}.new \
				    ${p_elf_ddir}/${elf_dfile}
			done
		)
	fi
fi

# DEBUG lint of kernel begins

if [ "$i_CMD_LINE_FLAG" = "n" -a "$l_FLAG" = "y" ]; then
	if [ "$LINTDIRS" = "" ]; then
		# LINTDIRS="$SRC/uts y $SRC/stand y $SRC/psm y"
		LINTDIRS="$SRC y"
	fi
	set $LINTDIRS
	while [ $# -gt 0 ]; do
		dolint $1 $2; shift; shift
	done
else
	echo "\n==== No '$MAKE lint' ====\n" >> $LOGFILE
fi

# "make check" begins

if [ "$i_CMD_LINE_FLAG" = "n" -a "$C_FLAG" = "y" ]; then
	# remove old check.out
	rm -f $SRC/check.out

	rm -f $SRC/check-${MACH}.out
	cd $SRC
	$MAKE -ek check 2>&1 | tee -a $SRC/check-${MACH}.out >> $LOGFILE
	echo "\n==== cstyle/hdrchk errors ====\n" >> $mail_msg_file

	grep ":" $SRC/check-${MACH}.out |
		egrep -v "Ignoring unknown host" | \
		sort | uniq >> $mail_msg_file
else
	echo "\n==== No '$MAKE check' ====\n" >> $LOGFILE
fi

echo "\n==== Find core files ====\n" | \
    tee -a $LOGFILE >> $mail_msg_file

find $abssrcdirs -name core -a -type f -exec file {} \; | \
	tee -a $LOGFILE >> $mail_msg_file

if [ "$f_FLAG" = "y" -a "$build_ok" = "y" ]; then
	echo "\n==== Diff unreferenced files (since last build) ====\n" \
	    | tee -a $LOGFILE >>$mail_msg_file
	rm -f $SRC/unref-${MACH}.ref
	if [ -f $SRC/unref-${MACH}.out ]; then
		mv $SRC/unref-${MACH}.out $SRC/unref-${MACH}.ref
	fi

	findunref -S $SCM_TYPE -t $SRC/.build.tstamp -s usr $CODEMGR_WS \
	    ${TOOLS}/findunref/exception_list 2>> $mail_msg_file | \
	    sort > $SRC/unref-${MACH}.out

	if [ ! -f $SRC/unref-${MACH}.ref ]; then
		cp $SRC/unref-${MACH}.out $SRC/unref-${MACH}.ref
	fi

	diff $SRC/unref-${MACH}.ref $SRC/unref-${MACH}.out >>$mail_msg_file
fi

#
# Generate the OpenSolaris deliverables if requested.  Some of these
# steps need to come after findunref and are commented below.
#

#
# Copy an input crypto tarball to the canonical destination (with
# datestamp), and point the non-stamped symlink at it.
# Usage: copyin_crypto from_path suffix
# Returns 0 if successful, non-zero if not.
#
function copyin_crypto {
	typeset from=$1
	typeset suffix=$2
	typeset to=$(cryptodest "$suffix").bz2
	typeset -i stat
	cp "$from" "$to"
	stat=$?
	if (( $stat == 0 )); then
		cryptolink "$to" "$suffix"
		stat=$?
	fi
	return $stat
}

#
# Copy a crypto tarball to $CODEMGR_WS to go with the other
# OpenSolaris deliverables.
# Usage: copyout_crypto suffix
# where $suffix is "" or "-nd".
#
function copyout_crypto {
	typeset suffix=$1
	typeset cryptof=on-crypto$suffix.$MACH.tar.bz2
	[ -f $cryptof ] && rm $cryptof
	cp $(cryptodest "$suffix").bz2 $cryptof
}

#
# Pass through the crypto tarball(s) that we were given, putting it in
# the same place that crypto_from_proto puts things.
# Returns with non-zero status if there is a problem.
#
function crypto_passthrough {
	echo "Reusing $ON_CRYPTO_BINS for crypto tarball(s)..." >> "$LOGFILE"
	typeset -i stat=0
	if [ "$D_FLAG" = y ]; then
		copyin_crypto "$ON_CRYPTO_BINS" "" >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create DEBUG crypto tarball." |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
			stat=1
		fi
	fi
	if [ "$F_FLAG" = n ]; then
		copyin_crypto $(ndcrypto "$ON_CRYPTO_BINS") "-nd" \
		    >> "$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create non-DEBUG crypto tarball." |
			    tee -a "$mail_msg_file" >> "$LOGFILE"
			stat=1
		fi
	fi

	return $stat
}

# If we are doing an OpenSolaris _source_ build (-S O) then we do
# not have usr/closed available to us to generate closedbins from,
# so skip this part.
if [ "$SO_FLAG" = n -a "$O_FLAG" = y -a "$build_ok" = y ]; then
	echo "\n==== Generating OpenSolaris tarballs ====\n" | \
	    tee -a $mail_msg_file >> $LOGFILE

	cd $CODEMGR_WS

	#
	# This step grovels through the package manifests, so it
	# must come after findunref.
	#
	# We assume no DEBUG vs non-DEBUG package content variation
	# here; if that changes, then the "make all" in $SRC/pkg will
	# need to be moved into the conditionals and repeated for each
	# different build.
	#
	echo "Generating closed binaries tarball(s)..." >> $LOGFILE
	closed_basename=on-closed-bins
	if [ "$D_FLAG" = y ]; then
		bindrop "$closed_basename" >>"$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create DEBUG closed binaries." |
			    tee -a $mail_msg_file >> $LOGFILE
			build_ok=n
		fi
	fi
	if [ "$F_FLAG" = n ]; then
		bindrop -n "$closed_basename-nd" >>"$LOGFILE" 2>&1
		if (( $? != 0 )) ; then
			echo "Couldn't create non-DEBUG closed binaries." |
			    tee -a $mail_msg_file >> $LOGFILE
			build_ok=n
		fi
	fi

	echo "Generating README.opensolaris..." >> $LOGFILE
	cp $SRC/tools/opensolaris/README.opensolaris $CODEMGR_WS \
	    >> $LOGFILE 2>&1
	if (( $? != 0 )) ; then
		echo "Couldn't create README.opensolaris." |
		    tee -a $mail_msg_file >> $LOGFILE
		build_ok=n
	fi

	typeset have_crypto=y
	if [ -n "$ON_CRYPTO_BINS" ]; then
		crypto_passthrough || have_crypto=n
	fi
	#
	# Make another copy of the crypto so that all the OpenSolaris
	# deliverables are in $CODEMGR_WS.
	#
	if [ "$have_crypto" != y ]; then
		build_ok=n
	else
		echo "Copying crypto tarball to $CODEMGR_WS" >> "$LOGFILE"
		if [ "$D_FLAG" = y ]; then
			copyout_crypto "" >> "$LOGFILE" 2>&1
			if (( $? != 0 )) ; then
				echo "Couldn't create DEBUG crypto tarball" |
				    tee -a $mail_msg_file >> "$LOGFILE"
				build_ok=n
			fi
		fi
		if [ "$F_FLAG" = n ]; then
			copyout_crypto "-nd" >> "$LOGFILE" 2>&1
			if (( $? != 0 )) ; then
				echo "Couldn't create non-DEBUG" \
				    "crypto tarball" |
				    tee -a $mail_msg_file >> "$LOGFILE"
				build_ok=n
			fi
		fi
	fi
fi

# Verify that the usual lists of files, such as exception lists,
# contain only valid references to files.  If the build has failed,
# then don't check the proto area.
CHECK_PATHS=${CHECK_PATHS:-y}
if [ "$CHECK_PATHS" = y -a "$N_FLAG" != y ]; then
	echo "\n==== Check lists of files ====\n" | tee -a $LOGFILE \
		>>$mail_msg_file
	arg=-b
	[ "$build_ok" = y ] && arg=
	checkpaths $arg $checkroot 2>&1 | tee -a $LOGFILE >>$mail_msg_file
fi

if [ "$M_FLAG" != "y" -a "$build_ok" = y ]; then
	echo "\n==== Impact on file permissions ====\n" \
		>> $mail_msg_file

	abspkgdefs=
	abspkg=
	for d in $abssrcdirs; do
		if [ -d "$d/pkgdefs" ]; then
			abspkgdefs="$abspkgdefs $d"
		fi
		if [ -d "$d/pkg" ]; then
			abspkg="$abspkg $d"
		fi
	done

	if [ -n "$abspkgdefs" ]; then
		pmodes -qvdP \
		    `find $abspkgdefs -name pkginfo.tmpl -print -o \
		    -name .del\* -prune | sed -e 's:/pkginfo.tmpl$::' | \
		    sort -u` >> $mail_msg_file
	fi

	if [ -n "$abspkg" ]; then
		for d in "$abspkg"; do
			( cd $d/pkg ; $MAKE -e pmodes ) >> $mail_msg_file
		done
	fi
fi

if [ "$w_FLAG" = "y" -a "$build_ok" = "y" ]; then
	if [[ "$MULTI_PROTO" = no || "$D_FLAG" = y ]]; then
		do_wsdiff DEBUG $ROOT.prev $ROOT
	fi

	if [[ "$MULTI_PROTO" = yes && "$F_FLAG" = n ]]; then
		do_wsdiff non-DEBUG $ROOT-nd.prev $ROOT-nd
	fi
fi

END_DATE=`date`
echo "==== Nightly $maketype build completed: $END_DATE ====" | \
    tee -a $LOGFILE >> $build_time_file

typeset -i10 hours
typeset -Z2 minutes
typeset -Z2 seconds

elapsed_time=$SECONDS
((hours = elapsed_time / 3600 ))
((minutes = elapsed_time / 60  % 60))
((seconds = elapsed_time % 60))

echo "\n==== Total build time ====" | \
    tee -a $LOGFILE >> $build_time_file
echo "\nreal    ${hours}:${minutes}:${seconds}" | \
    tee -a $LOGFILE >> $build_time_file

if [ "$u_FLAG" = "y" -a "$f_FLAG" = "y" -a "$build_ok" = "y" ]; then
	staffer cp ${SRC}/unref-${MACH}.out $PARENT_WS/usr/src/

	#
	# Produce a master list of unreferenced files -- ideally, we'd
	# generate the master just once after all of the nightlies
	# have finished, but there's no simple way to know when that
	# will be.  Instead, we assume that we're the last nightly to
	# finish and merge all of the unref-${MACH}.out files in
	# $PARENT_WS/usr/src/.  If we are in fact the final ${MACH} to
	# finish, then this file will be the authoritative master
	# list.  Otherwise, another ${MACH}'s nightly will eventually
	# overwrite ours with its own master, but in the meantime our
	# temporary "master" will be no worse than any older master
	# which was already on the parent.
	#

	set -- $PARENT_WS/usr/src/unref-*.out
	cp "$1" ${TMPDIR}/unref.merge
	shift

	for unreffile; do
		comm -12 ${TMPDIR}/unref.merge "$unreffile" > ${TMPDIR}/unref.$$
		mv ${TMPDIR}/unref.$$ ${TMPDIR}/unref.merge
	done

	staffer cp ${TMPDIR}/unref.merge $PARENT_WS/usr/src/unrefmaster.out
fi

#
# All done save for the sweeping up.
# (whichever exit we hit here will trigger the "cleanup" trap which
# optionally sends mail on completion).
#
if [ "$build_ok" = "y" ]; then
	exit 0
fi
exit 1
