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
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#

"""Name Service Switch base classes used by nscfg."""

import os, time
from .messages import *
from .nssscf import Nssscf as Nssscf
from .nssscf import error as NssscfError
from subprocess import *

class Nssbase(object):
    """Name Service Switch base class. Represents the common base
       class used by the other name service switch classes.
       ** USE AS BASE CLASS ONLY  **"""

    # Shared return codes:
    SUCCESS = 0
    FAIL = -1
    NOCONFIG = 1
    NOCHANGE = 1

    # Required class constants and variables.
    SERVICE = None		# Service name (string)
    LEGACY = None		# Legacy file name
    LEGACYDIR = None		# Legacy Directory location
    DEFPG = None		# 'default' program group (string)
    DEFPGTYPE = 'application'	# 'default' program group type (string)
    DEFPROP = None		# 'default' property (string)
    ALLPGS = []			# Supported Property groups
    ALLPROPS = {}		# Supported properties [key] = type
    BACKEND = None		# Set to backend name if nss_backend

    PERM = 0644			# Default file perm on create

    UNCONFPG = 'unconfig_group'	# Required property group with config state
    UNCONFPROP = 'unconfigured'	# Required property group with config state

    # Common constants/Variables

    no_write = False		# don't write/modify if True

    DNSHOSTCHARS = 'abcdefghijklmnopqrstuvwxyz0123456789-.'
    IPV4CHARS = '0123456789.'
    IPV6CHARS = 'abcdef0123456789:.'
    HEXCHARS = 'abcdef0123456789'

    # LOFS mount constants for read-only root option
    ETC_MNTTAB = '/etc/mnttab'
    LOFS_MOUNT = '/usr/sbin/mount -O -F lofs %s %s'
    LOFS_UMOUNT = '/usr/sbin/umount %s'

    # This is a mapping from pre-smf DB names [see nsswitch.conf(4)]
    # To SMF db names.  Note in SMF, all DBs are singular and there
    # is a single consistent mapping.  (aka hosts & ipnodes -> host)
    #
    # This mapping is placed in the base class so that it can be shared
    # across multiple subclasses.
    DBMAP = {'passwd': 'password',
	     'group': 'group',
	     'hosts': 'host',
	     'ipnodes': 'host',
	     'networks': 'network',
	     'protocols': 'protocol',
	     'rpc': 'rpc',
	     'ethers': 'ether',
	     'netmasks': 'netmask',
	     'bootparams': 'bootparam',
	     'publickey': 'publickey',
	     'netgroup': 'netgroup',
	     'automount': 'automount',
	     'aliases': 'alias',
	     'services': 'service',
	     'printers': 'printer',
	     'project': 'project',
	     'auth_attr': 'auth_attr',
	     'prof_attr': 'prof_attr',
	     'tnrhtp': 'tnrhtp',
	     'tnrhdb': 'tnrhdb'}

    # This tag is used to determine if a legacy file was previously
    # generated by an nscfg export
    AUTO_GEN = "# _AUTOGENERATED_FROM_SMF_V1_"

    # This is a shared copyright header used by multiple subclasses
    COPYRIGHT = """
#
# Copyright (c) YYYY, Oracle and/or its affiliates. All rights reserved.
#

#
AUTO_GEN
#
# WARNING: THIS FILE GENERATED FROM SMF DATA.
#   DO NOT EDIT THIS FILE.  EDITS WILL BE LOST.
"""
    DOC = None

    #  Methods
    def __init__(self):
	"""Base class init method.  Creates BASE service object.
	   Collects pg's and properties.
	   Required:  SERVICE, LEGACY"""
	self.reset_svc()
	self.volume = 0
	if os.path.exists('/var/tmp/nscfg_debug'):
	    self.volume = 2

    def nowrite(self):
	"""Disable writing of config or SMF properties."""
	self.no_write = True

    def verbose(self, volume = 1):
	"""Set verbose flag."""
	self.volume = volume

    def print_output(self, *args):
	"""Trace/Verbose message output, with a little bit of formatting."""
	for av in args:
	    try:
		if type(av) == type(''):
		    msg = _(av)
		    printStdout(msg, -1)
		elif type(av) == type(()) or type(av) == type([]):
		    first = True
		    dstr = ''
		    for a in av:
			if first:
			    if type(a) == type(''):
				dstr = _(a)
			    else:
				dstr = str(a)
			    first = False
			else:
			    dstr += '  ' + str(a)
		    outstr = "%s\n" % dstr
		    printStdout(outstr, -1)
		else:
		    printStdout(str(av), -1)
	    except:
		printStderr(_("Output Error"))

    def err_msg(self, emsg):
	"""Error message output, with a little bit of formatting."""
	if self.volume:
	    tag = _("Error in service: %s")
	    msg = tag % self.SERVICE
	    printStderr(msg, -1);
	tag = _("Error: %s ")
	msg = tag % _(emsg)
	printStderr(msg, -1);

    def err_list(self, emsg, tuple):
	"""Multi line error message output, with a little bit of formatting."""
	self.err_msg(emsg)
	try:
	    for em in tuple:
		msg = "  %s" % em
		printStderr(msg, -1);
	except:
	    pass

    def traceit(self, *args):
	"""Debugging output. IF debug = True"""
	if self.volume > 1:
	    self.print_output(args)

    def print_msg(self, *args):
	"""Verbose output. IF verbose == True or debug = True"""
	if self.volume > 0:
	    self.print_output(args)

    def reset_svc(self):
	"""Reset the service and all existing property information."""
	self.last_tmp = ''	# Contents of last known tmp file
	self.inited = False	# Instance has been loaded with SMF data
	self.svc = None		# Service's SMF object
	self.tmpfd = None	# Temp fd
	self.pgs = []		# SMF program groups for this instance
	self.props = []		# SMF properties for this instance
	self.MNTDIR = None	# Directory used in R/O lofs mounts

    def __del__(self):
	"""Base class delete method."""
	self.reset_svc()

    #
    # Methods that manipulate properties and property groups
    #

    def init_svc(self):
	if self.inited:
	    return True
	self.last_tmp = ''	# Contents of last known tmp file
	self.inited = False	# Remain pessimistic
	self.svc = None
	self.tmpfd = None	# Temp fd
	self.pgs = []
	self.props = []
	if self.SERVICE == None or self.LEGACY == None:
	    pass
	else:
	    try:
	        self.svc = Nssscf(self.SERVICE)
		# Warning SMF magic.
		# IF a service has not not imported
		#    some service properties/pgs may exist (e.g. dependencies)
		#    but the general pg should not exist
		# IF we are at early manifest import, an imported service 
		#    should have general pg, but may not have general/enabled
		# IF we are post early manifest import an imported service
		#    should have general pg, and may have general_ovr pg 
		# Therefore IF no general pg, no service
		fnd_general = False
		for pgl in self.svc.get_service_pgs():
		    pg = pgl[0]
		    if pg == 'general':
			fnd_general = True
		    self.pgs.append(pg)
		    for propl in self.svc.get_properties(pg):
			prop = propl[0]
			self.props.append('/'.join((pg, prop)))
		if not fnd_general:		# undo any initialization
		    self.svc = None
		    self.pgs = []
		    self.props = []
		    return
		self.inited = True	# if inited then the service exists
	    except:
		pass

    def get_prop_val(self, pg = None, prop = None):
	"""Get prop's [first] property value."""
	if not self.inited:
	    self.init_svc()
	if self.inited:
	    try:
		if pg == None and prop != None and prop.find('/') != -1:
		    (pg, prop) = prop.split('/', 2)
		if pg == None:
		    pg = self.DEFPG
		if prop == None:
		    prop = self.DEFPROP
		ret = self.svc.get_prop_values(pg, prop)
		if len(ret) == 1:
		    return ret[0]
		elif len(ret) > 1:
		    raise ValueError, \
			 "Multiple values returned, single value expected"
	    except:
		pass	# No property  found , or no value
	return None

    def get_prop_val_list(self, pg = None, prop = None):
	"""Get all of the prop's property values as a tuple."""
	if not self.inited:
	    self.init_svc()
	if self.inited:
	    try:
		if pg == None and prop != None and prop.find('/') != -1:
		    (pg, prop) = prop.split('/', 2)
		if pg == None:
		    pg = self.DEFPG
		if prop == None:
		    prop = self.DEFPROP
		return self.svc.get_prop_values(pg, prop)
	    except:
		pass
	return None

    def get_pgs(self):
	"""Get the list of the service's property groups."""
	if not self.inited:
	    self.init_svc()
	if self.inited:
	    return self.pgs
	return None

    def get_props(self, pg = None):
	"""Get the list of the service's properties."""
	if not self.inited:
	    self.init_svc()
	if self.inited:
	    if pg == None or pg == '':
		return self.props
	    gprops = []
	    for propl in self.svc.get_properties(pg):
		prop = propl[0]
		gprops.append('/'.join((pg, prop)))
	    return gprops
	return None

    def default_pg(self):
	"""Return the name of the 'default' property group."""
	return self.DEFPG

    def default_prop(self):
	"""Return the name of the 'default' property."""
	return self.DEFPROP

    def join(self, pg = None, prop = None):
	"""Join and return a pg/prop combination.
	   If pg or prop are None, use the default."""
	if pg == None and prop != None and prop.find('/') != -1:
	    return prop
	if pg == None:
	    pg = self.DEFPG
	if prop == None:
	    prop = self.DEFPROP
	return '/'.join((pg,prop))

    # Validate using libscf APIs directly
    # num_retries is ignored.
    def validate(self, num_tries=3):
	"""Validate the service properties. Retry num_tries times ignored."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	# Run validate through Nssscf library
	self.print_msg('Validate service properties for: ', self.SERVICE)
	try:
	    (ret, output) = self.svc.validate()
	    self.traceit('RET: ', ret)
	    self.traceit('OUTPUT: ', output)
	except:
	    output = 'Unable to process libscf validate command\n'
	    ret = -1
	if ret == 0:
	    return True
	self.err_msg('Validate Error:\n')
	self.err_msg(output)
	return False

    def commit(self, pg = None):
	"""Refresh the service and commit any new/changed properties.
	   If pg is not None, then wait for pg to exist in its most
	   current form."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	# Run refresh through svccfg, not through Nssscf library
	# Collect all error results if they exist for error output.
	instance = self.svc.get_instfmri()
	if instance == None or instance == '':
	    self.err_msg('No :default instance name found.')
	    return False
	cmd = ' '.join(('/usr/sbin/svccfg', '-s', instance, 'refresh'))
	self.print_msg('Refresh svccfg command: ', cmd)
	# Was previously calls to self.svc.refresh() and pgupdate
	try:
	    io = open('/dev/null', 'r+')
	    p = Popen(cmd, shell=True, bufsize=0, close_fds=True, \
		stdin=io, stdout=PIPE, stderr=STDOUT)
	    (output, ignore) = p.communicate()
	    ret = p.wait()
	    self.traceit('RET: ', ret)
	    self.traceit('OUTPUT: ', output)
	    io.close()
	    del io
	    del p
	except:
	    errout = 'Unable to process svccfg refresh command\n'
	    ret = -1
	if ret == 0 and len(output) == 0:
	    return True
	self.err_msg('Commit Error.  Svccfg says:\n')
	self.err_msg(output)
	return False

    def addpg(self, pg, pgtype):
	"""Add a property group with the given name and type."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.add_pg(pg, pgtype)
	except NssscfError, err:
	    self.err_msg(err)
	    ret = False
	if ret:			# Add value_authorization if it exists
	    try:
		val = self.VALUE_AUTH
		ret = self.add_prop_val(pg, \
			'value_authorization', 'astring', val)
	    except:
		pass
	return ret

    def delpg(self, pg):
	"""Delete property group with the given name."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    self.svc.delete_pg(pg)
	except:
	    pass
	return True

    def delcust_pg(self, pg):
	"""Delete property group customizations with the given name."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    self.svc.delcust_pg(pg)
	except:
	    pass
	return True

    def add_prop_val(self, pg, prop, ptype, val):
	"""Add property value val to property group/property of type ptype.
	   val may be a string, or a sequence of strings (tuple/array)."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.set_propvalue(pg, prop, ptype, val)
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    #
    # Methods that manipulate legacy files
    #

    def legacy_file(self, file = None):
	"""Modify/Return the name of the legacy file name."""
	if file != None and type(file) == type(''):
	    self.LEGACY = file
	return self.LEGACY

    def legacy_dir(self, dir = None):
	"""Modify/Return the name of the legacy directory component."""
	if dir != None and type(dir) == type(''):
	    self.LEGACYDIR = dir
	    self.MNTDIR = None
	return self.LEGACYDIR

    def legacy_path(self):
	"""Return the name of the full legacy pathname."""
	return os.path.join(self.LEGACYDIR, self.LEGACY)

    def legacy_exists(self):
	"""Was the legacy file generated from SMF data?"""
	return os.path.exists(self.legacy_path())

    def mnt_dir(self):
	"""Return the name of the lofs mountdir or LEGACYDIR ."""
	if self.MNTDIR != None:
	    return self.MNTDIR		# Use what was already found
	self.print_msg("Looking in /etc/mnttab, for lofs mount.")
	legacy = self.legacy_path()	# What to look for
	try:
	    data = open(self.ETC_MNTTAB, 'r').readlines()
	except:
	    self.print_msg("No lofs mountpoint found (using legacy dir).")
	    data = None
	self.MNTDIR = self.LEGACYDIR	# Fallback
	if data != None:
	    for l in data:
		try:
		    (src, mnt, type, opts, misc) = l.split()
		except:
		    continue
		if type == 'lofs':
		    if legacy == mnt:	# lofs mount point match
			self.MNTDIR = os.path.dirname(src)
			break
	return self.MNTDIR
    def mnt_path(self):
	"""Return the name of the lofs mount path or legacy_path ."""
	return os.path.join(self.mnt_dir(), self.LEGACY)

    def tmp_path(self):
	"""Return the name of the temp legacy pathname."""
	tmppath = '.'.join((self.mnt_path(), str(os.getpid())))
	self.traceit('in tmp_path: tmppath= ', tmppath)
	return tmppath

    def open_tmp(self):
	"""Create a new legacy temp file for writing."""
	self.traceit('in open_tmp: tmpfd= ', self.tmpfd)
	if self.tmpfd == None:
	    try:
		tmppath = self.tmp_path()
		self.traceit('    opening: tmppath= ', tmppath)
		self.tmpfd = open(tmppath, 'w+')
		os.fchmod(self.tmpfd.fileno(), self.PERM)
		self.last_tmp = ''
		self.traceit('    open successful')
	    except:
		self.tmpfd = None
		self.traceit('    open failed')
	return self.tmpfd

    def copyright_tmp(self, sep = None, pre = None, post = None):
	"""Write out copyright to opened tmpfile.
	   Modify default '#' comment tag using sep, pre, post."""
	if self.tmpfd == None:
	    return False
	copyright = ''
	if pre != None:
	    copyright += pre
	if sep != None:
	    tmp = self.COPYRIGHT.replace('#', sep)
	    copyright += tmp
	else:
	    copyright += self.COPYRIGHT
	if type(self.DOC) == type(''):		# Optional Doc reference
	    if sep != None:
		tmp = self.DOC.replace('#', sep)
	    else:
		tmp = self.DOC
	    copyright += tmp + '\n'
	if post != None:
	    copyright += post
	yr = time.strftime('%Y')
	# Insert initial copyright year if it exists
	try:
	    yr = '%s, %s' % (self.COPY_YR, yr)
	except:
	    pass
	copyright = copyright.replace('YYYY', yr)
	copyright = copyright.replace('AUTO_GEN', self.AUTO_GEN)
	self.tmpfd.write(copyright)
	self.last_tmp += copyright
	
    def close_tmp(self):
	"""Create a new legacy temp file for writing."""
	if self.tmpfd != None:
	    try:
		close(self.tmpfd)
	    except:
		pass
	self.tmpfd = None
	return True

    def unlink_tmp(self):
	tmppath = self.tmp_path()
	try:
	    if os.path.exists(tmppath):
		os.unlink(tmppath)
	except:
	    return False
	return True

    def save_to_tmp(self, copyright, data):
	"""All-in-one tmp file generation from data string."""
	if type(copyright) != type(True):
	    return False
	if data == None or type(data) != type(''):
	    return False
	fd = self.open_tmp()
	self.traceit('open fd= ', fd)
	if fd == None:				# Unable to create temp file
	    return False
	# Write 'DONT MODIFY' HEADER
	if copyright:
	    self.copyright_tmp()
	try:
	    fd.write(data)
	    self.last_tmp += data
	    self.traceit('written...')
	except:
	    self.close_tmp()
	    self.unlink_tmp()
	    self.traceit('write fail...')
	    return False
	self.close_tmp()
	return True
	
    def legacy_save(self, altpath = None):
	"""Save away an existing legacy file to ${legacy}.orig."""
	legacy = self.legacy_path()
	if altpath != None:
	    legacy = altpath
	if os.path.exists(legacy):	# Save away original
	    orig = '.'.join((legacy, 'orig'))
	    if os.path.exists(orig):	# But not 2 copies
		try:
		    os.unlink(orig)
		except:
		    return False	# Don't continue (unlink error)
	    try:
		os.rename(legacy, orig)
	    except:
		return False		# Don't continue (rename error)
	return True

    def orig_cleanup(self, altpath = None):
	"""Remove ${legacy}.orig if a legacy file exists."""
	legacy = self.legacy_path()
	if altpath != None:
	    legacy = altpath
	if os.path.exists(legacy):	# Save away original
	    orig = '.'.join((legacy, 'orig'))
	    if os.path.exists(orig):	# ${legacy}.orig exists
		try:
		    os.unlink(orig)	# Remove if possible
		    self.print_msg("Removed old (orig) backup.")
		except:
		    pass
	return True

    def lofs_legacy_save(self):
	"""Attempt to remount the legacy file as a lofs mount point.
	   For this to be successful, there must be a pre-existing mount
	   fail here mean fallback to the rename file method."""
	legacy = self.legacy_path()
	mntpath = self.mnt_path()
	tmppath = self.tmp_path()
	self.print_msg("    Try legacy re-mount using lofs.")
	if mntpath == legacy:
	    self.print_msg("    Legacy file is not currently using lofs.")
	    return False		# not a lofs mount candidate
	if self.legacy_save(mntpath) == False:
	    self.err_msg("Unable to archive existing legacy file.")
	    return False		# Cannot save away existing legacy
	self.print_msg("    Try to re-mount: ", mntpath, " to ", legacy)
	try:
	    self.print_msg("   Move temp: ", tmppath, " to ", mntpath)
	    os.rename(tmppath, mntpath)
	except:
	    self.print_msg("   Could not move temp to mount source.")
	    return False
	try:
	    io = open('/dev/null', 'r+')
	    # First clean up old lofs mount
	    umntcmd = self.LOFS_UMOUNT % legacy
	    self.traceit('UMNTCMD: ', umntcmd)
	    p = Popen(umntcmd, shell=True, bufsize=0, close_fds=True, \
		stdin=io, stdout=PIPE, stderr=STDOUT)
	    (output, ignore) = p.communicate()
	    ret = p.wait()
	    self.traceit('UMNT RET: ', ret)
	    self.traceit('UMNT OUTPUT: ', output)
	    if ret != 0:
		io.close()
		self.print_msg("    Could not umount previous lofs mount.")
		del io
		del p
		return False
	    # Try to cleanly remount file using lofs
	    mntcmd = self.LOFS_MOUNT % (mntpath, legacy)
	    self.traceit('LOFS MNTCMD: ', mntcmd)
	    p = Popen(mntcmd, shell=True, bufsize=0, close_fds=True, \
		stdin=io, stdout=PIPE, stderr=STDOUT)
	    (output, ignore) = p.communicate()
	    ret = p.wait()
	    self.traceit('MNT RET: ', ret)
	    self.traceit('MNT OUTPUT: ', output)
	    io.close()
	    del io
	    del p
	except:
	    self.print_msg("    Could not lofs re-mount legacy file.")
	    return False
	if ret == 0 and len(output) == 0:
	    self.print_msg("    lofs re-mount successful.")
	    self.orig_cleanup(mntpath)
	    return True
	self.err_msg("Warning: mount error on lofs re-mount: ", ret, output)
	return False

    def tmp_to_legacy(self):
	"""Replace legacy config file with tmp config file.
	   Save away existing legacy file as necessary.
	   Returns:  -1 - Error, 0 - Success, 1 - Unnecessary."""
	self.close_tmp()		# Close it, just in case it's open
	self.print_msg("Save new legacy file...")
	legacy = self.legacy_path()
	tmppath = self.tmp_path()
	read_legacy_file = False
	legdata = None
	try:
	    legdata = open(legacy, 'r').read()
	    read_legacy_file = True
	except:
	    pass
	if legdata != None:
	    if legdata == self.last_tmp:
		self.print_msg("    Legacy contents identical. skip save")
		try:
		    os.unlink(tmppath)
		except:
		    pass
		return self.NOCHANGE
	# Try a lofs mount if possible
	if read_legacy_file and self.lofs_legacy_save():
	    self.print_msg("Legacy save (lofs remount). success")
	    return self.SUCCESS
	# Otherwise copy temporary file to legacy file
	if self.legacy_save() == False:
	    self.err_msg("Unable to archive existing legacy file.")
	    return self.FAIL		# Cannot save away existing legacy
	self.print_msg("    Try legacy rename: ", tmppath, " to ", legacy)
	try:
	    os.rename(tmppath, legacy)
	except:
	    self.err_msg("Could not install legacy file.")
	    return self.FAIL	# Don't continue (rename error)
	self.print_msg("Legacy save. success")
	self.orig_cleanup()
	return self.SUCCESS

    def load_legacy(self):
	"""Readlines an existing legacy file.  Return a list of lines.
	   Return: None if no legacy file, [] if empty,  or [...]
	   Note: '\n' are pruned from all lines before return."""
	legacy = self.legacy_path()
	lines = []
	try:
	    lfd = open(legacy, 'r')
	    ln = lfd.readlines()
	    for l in ln:
		if l.endswith('\n'):
		    l = l[:-1]
		lines.append(l)
	    lfd.close()
	except:
	    return None
	return lines

    #
    # Service specific methods
    #
    def is_enabled(self):
	"""Return True if service is currently enabled."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.is_enabled()
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    def enable(self):
	"""Execute svcadm enable on this service."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.enable()
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    def disable(self):
	"""Execute svcadm disable on this service."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.disable()
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    def refresh(self):
	"""Execute svcadm refresh on this service."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.refresh()
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    def restart(self):
	"""Execute svcadm restart on this service."""
	if not self.inited:
	    self.init_svc()
	if not self.inited:
	   return False
	try:
	    ret = self.svc.restart()
	except NssscfError, err:
	    self.err_msg(err)
	    return False
	return ret

    #
    # Methods to nss "backend" specific methods
    #

    def is_backend(self):
	"""Return True if this is a class for a nss backend."""
	if self.BACKEND == None:
	    return False
	return True

    #
    # Methods that must be subclassed
    #

    def export_from_smf(self):
	"""Export from SMF.  -1 - Fail, 0 - Success, 1 - Unnecessary.
	** Must Subclass **"""
	return self.FAIL

    def import_to_smf(self):
	"""Import to SMF.  -1 - Fail, 0 - Success, 1 - no config to import.
	** Must Subclass **"""
	return self.FAIL

    def unconfig_smf(self):
	"""Unconfigure SMF.  -1 - Fail, 0 - Success.
	** Must Subclass **"""
	return self.FAIL

    #
    # Subclass as needed.  The default performs a simple check
    # to see that the default PG exists and contains at least
    # one property.  That may be insufficient.
    #
    def is_populated(self):
	"""Is SMF populated with this service?  True/False"""
	pgs = self.get_pgs()
	if pgs != None:
	    if self.DEFPG in pgs:		# default PG exists
		props = self.get_props(self.DEFPG)
		if props != None:
		    fndprop = False
		    for p in self.ALLPROPS.keys():
			tprop = '/'.join((self.DEFPG, p))
			if tprop in props:
			    fndprop = True
		    if fndprop:			# PG and at least 1 prop exist
			return True
	return False

    #
    # Check to see if the existing legacy file was generated from SMF data.
    # Check for the AUTO_GEN tag as a key.
    #
    def is_autogenerated(self):
	"""Was the legacy file generated from SMF data?"""
	if self.legacy_exists():	# legacy file must first exist
	    lines = self.load_legacy()
	    if type(lines) == type([]) and len(lines) > 0:
		if self.AUTO_GEN in lines:
		    return True		# and must contain the AUTO_GEN line
	return False

    #
    # Determine if configured or not.
    #
    def is_configured(self):
	"""Is this SMF service configured from SMF data?"""
	if self.is_enabled():			# Service is already 'online'
	    return True
	if self.is_populated():			# Service must be populated
	   if not self.legacy_exists():		# but with no legacy file
		return True
	   else:
	   	if self.is_autogenerated():	# OR legacy file must be
		    return True			# generated from SMF data
	return False

    #
    # Perform basic typechecking on a value
    #
    def typecheck_netaddress(self, smftype, value):
	if smftype == 'net_address':
	    if type(value) == type(''):
		if len(value.lower().translate(None, self.IPV4CHARS)) == 0:
		    digs = value.split('.')
		    if len(digs) != 4:
			return False
		    try:
			count = 0
			for d in digs:
			    x = int(d)
			    if x >= 0 and x <= 255:
				count += 1
			if count == 4:
			    return True		# Valid IPv4
		    except:
			pass
		if len(value.lower().translate(None, self.IPV6CHARS)) == 0:
		    digs = value.lower().split(':')
		    if len(digs) < 1 or len(digs) > 7:
			return False
		    for d in digs[:-1]:
			if len(d.translate(None, self.HEXCHARS)) != 0:
			    return False
		    d = digs[-1]
		    if len(d.translate(None, self.HEXCHARS)) == 0:
			return True		# Valid IPv6
		    if len(d.translate(None, self.IPV4CHARS)) == 0:
			digs = value.split('.')
			if len(digs) != 4:
			    return False
			try:
			    count = 0
			    for d in digs:
				x = int(d)
				if x >= 0 and x <= 255:
				    count += 1
			    if count == 4:
				return True	# Valid IPv6:ipv4
			except:
			    pass
	return False

    def typecheck(self, smftype, value):
	"""Is the value of this type or a string of this type?  True/False"""
	if smftype == 'boolean':
	    if type(value) == type(True):
		return True			# In native format
	    elif type(value) == type(''):
		if value == 'true' or value == 'false':
		    return True			# Legal SMF values
	elif smftype == 'integer':
	    if type(value) == type(1):
		return True			# In native format
	    elif type(value) == type(''):
		try:
		    i = int(value)
		    if str(i) == value:
			return True
		except:
		    pass			# Fall through
	elif smftype == 'hostname':
	    if type(value) == type(''):
		if len(value.lower().translate(None, self.DNSHOSTCHARS)) == 0:
		    return True			# Only legal DNS name chars
	elif smftype == 'net_address':
	    return self.typecheck_netaddress(smftype, value)
	elif smftype == 'host':
	    if self.typecheck_netaddress('net_address', value):
		return True
	    if type(value) == type(''):
		if len(value.lower().translate(None, self.DNSHOSTCHARS)) == 0:
		    return True			# Only legal DNS name chars
	elif smftype == 'astring':
	    if type(value) == type(''):
		return True			# In native format
	else:
	    pass				# XXX Fail on unknown types
	return False
