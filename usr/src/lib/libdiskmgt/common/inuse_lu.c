/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */
/*
 * Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
 */

/*
 * Creates and maintains a short-term cache of live upgrade slices.
 */

#include <dirent.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <synch.h>
#include <sys/errno.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "libdiskmgt.h"
#include "disks_private.h"

#define	TMPNAME	_PATH_SYSVOL "/dm_lu_XXXXXX"

/*
 * The list of live upgrade slices in use.
 */

struct lu_list {
	struct lu_list	*next;
	char		*slice;
	char		*name;
};

static struct lu_list	*lu_listp = NULL;
static time_t		timestamp = 0;
static mutex_t		lu_lock = DEFAULTMUTEX;

static int		add_use_record(char *devname, char *name);
static void		free_lu(struct lu_list *listp);
static int		load_lu();
static int		lustatus(int fd);
static int		lufslist(int fd);
static int		run_cmd(char *path, char *cmd, char *arg, int fd);

/*
 * Search the list of devices under live upgrade for the specified device.
 */
int
inuse_lu(char *slice, nvlist_t *attrs, int *errp)
{
	int		found = 0;
	time_t		curr_time;

	*errp = 0;

	if (slice == NULL) {
	    return (found);
	}

	/*
	 * We don't want to have to re-read the live upgrade config for
	 * every slice, but we can't just cache it since there is no event
	 * when this changes.  So, we'll keep the config in memory for
	 * a short time (1 minute) before reloading it.
	 */
	(void) mutex_lock(&lu_lock);

	curr_time = time(NULL);
	if (timestamp < curr_time && (curr_time - timestamp) > 60) {
	    free_lu(lu_listp);	/* free old entries */
	    lu_listp = NULL;
	    *errp = load_lu();	/* load the cache */
	    timestamp = curr_time;
	}

	if (*errp == 0) {
	    struct lu_list	*listp;

	    listp = lu_listp;
	    while (listp != NULL) {
		if (strcmp(slice, listp->slice) == 0) {
		    libdiskmgt_add_str(attrs, DM_USED_BY, DM_USE_LU, errp);
		    libdiskmgt_add_str(attrs, DM_USED_NAME, listp->name, errp);
		    found = 1;
		    break;
		}
		listp = listp->next;
	    }
	}

	(void) mutex_unlock(&lu_lock);

	return (found);
}

static int
add_use_record(char *devname, char *name)
{
	struct lu_list *sp;

	sp = (struct lu_list *)malloc(sizeof (struct lu_list));
	if (sp == NULL) {
	    return (ENOMEM);
	}

	if ((sp->slice = strdup(devname)) == NULL) {
	    free(sp);
	    return (ENOMEM);
	}

	if ((sp->name = strdup(name)) == NULL) {
	    free(sp->slice);
	    free(sp);
	    return (ENOMEM);
	}

	sp->next = lu_listp;
	lu_listp = sp;

	return (0);
}

/*
 * Free the list of liveupgrade entries.
 */
static void
free_lu(struct lu_list *listp) {

	struct lu_list	*nextp;

	while (listp != NULL) {
	    nextp = listp->next;
	    free((void *)listp->slice);
	    free((void *)listp->name);
	    free((void *)listp);
	    listp = nextp;
	}
}

/*
 * Create a list of live upgrade devices.
 */
static int
load_lu(void)
{
	char	tmpname[] = TMPNAME;
	int	fd;
	int	status = 0;

	if ((fd = mkstemp(tmpname)) != -1) {
	    (void) unlink(tmpname);
	    if (run_cmd("/usr/sbin/lustatus", "lustatus", NULL, fd)) {
		status = lustatus(fd);
	    } else {
		(void) close(fd);
	    }
	}

	return (status);
}

/*
 * The XML generated by the live upgrade commands is not parseable by the
 * standard Solaris XML parser, so we have to do it ourselves.
 */
static int
lufslist(int fd)
{
	FILE	*fp;
	char	line[MAXPATHLEN];
	int	status;

	if ((fp = fdopen(fd, "r")) == NULL) {
	    (void) close(fd);
	    return (0);
	}

	(void) fseek(fp, 0L, SEEK_SET);
	while (fgets(line, sizeof (line), fp) == line) {
	    char *devp;
	    char *nmp;
	    char *ep;

	    if (strncmp(line, "<beFsComponent ", 15) != 0) {
		continue;
	    }

	    if ((devp = strstr(line, "fsDevice=\"")) == NULL) {
		continue;
	    }

	    devp = devp + 10;

	    if ((ep = strchr(devp, '"')) == NULL) {
		continue;
	    }

	    *ep = 0;

	    /* try to get the mountpoint name */
	    if ((nmp = strstr(ep + 1, "mountPoint=\"")) != NULL) {
		nmp = nmp + 12;

		if ((ep = strchr(nmp, '"')) != NULL) {
		    *ep = 0;
		} else {
		    nmp = "";
		}

	    } else {
		nmp = "";
	    }

	    if ((status = add_use_record(devp, nmp)) != 0) {
		break;
	    }
	}

	(void) fclose(fp);

	return (status);
}

static int
lustatus(int fd)
{
	FILE	*fp;
	char	line[MAXPATHLEN];
	int	status = 0;

	if ((fp = fdopen(fd, "r")) == NULL) {
	    (void) close(fd);
	    return (0);
	}

	(void) fseek(fp, 0L, SEEK_SET);
	while (fgets(line, sizeof (line), fp) == line) {
	    char	*sp;
	    char	*ep;
	    char	tmpname[] = TMPNAME;
	    int		ffd;

	    if (strncmp(line, "<beStatus ", 10) != 0) {
		continue;
	    }

	    if ((sp = strstr(line, "name=\"")) == NULL) {
		continue;
	    }

	    sp = sp + 6;

	    if ((ep = strchr(sp, '"')) == NULL) {
		continue;
	    }

	    *ep = 0;

	    if ((ffd = mkstemp(tmpname)) != -1) {
		(void) unlink(tmpname);

		if (run_cmd("/usr/sbin/lufslist", "lufslist", sp, ffd) == 0) {
		    (void) close(ffd);
		    break;
		}

		if ((status = lufslist(ffd)) != 0) {
		    break;
		}
	    }
	}

	(void) fclose(fp);

	return (status);
}

static int
run_cmd(char *path, char *cmd, char *arg, int fd)
{
	pid_t	pid;
	int	loc;

	/* create the server process */
	switch ((pid = fork1())) {
	case 0:
	    /* child process */
	    (void) close(1);
	    (void) dup(fd);
	    (void) close(2);
	    (void) dup(fd);
	    closefrom(3);
	    (void) execl(path, cmd, "-X", arg, NULL);
	    _exit(1);
	    break;

	case -1:
	    return (0);

	default:
	    /* parent process */
	    break;
	}

	(void) waitpid(pid, &loc, 0);

	/* printf("got 0x%x %d %d\n", loc, WIFEXITED(loc), WEXITSTATUS(loc)); */

	if (WIFEXITED(loc) && WEXITSTATUS(loc) == 0) {
	    return (1);
	}

	return (0);
}