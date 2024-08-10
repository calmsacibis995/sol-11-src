#ident	"%Z%%M%	%I%	%E% SMI"	/* From AT&T Toolchest */

/*
 *  sh_tilde - process tilde expansion
 *
 *   David Korn
 *   AT&T Bell Laboratories
 *   Room 3C-526B
 *   Murray Hill, N. J. 07974
 *   Tel. x7975
 *
 *   February, 1983
 *   revised March, 1988
 */                                              

#include	"sh_config.h"
#include	"defs.h"
#ifdef NOGETPW
/*
 * If we're not using the standard getpwent()
 * routines, we'll need all the standard ksh
 * definitions.
 */
#   ifdef KSHELL
#	include	"defs.h"
#   else
	extern char	*strrchr();
	extern char	*strcpy();
#   endif	/* KSHELL */
#else	/* NOGETPW */
/*
 * Otherwise, we just need access to <pwd.h>,
 * which also includes <stdio.h>, which is
 * incompatible with the standard ksh defs.h.
 */
#   include	<pwd.h>
#   include	<string.h>
#endif	/* NOGETPW */

#ifdef RDS
#   ifdef _mnttab_
#	include <mnttab.h>
#   else
#	undef RDS
#   endif /* _mnttab_ */
#   ifdef _sys_utsname_
#	include <sys/utsname.h>
#   else
#	undef RDS
#   endif /* _sys_utsname_ */
#endif /* RDS */

#define UNAME	20
#define LOGDIR	64            
#define LINSZ	256
static char u_name[UNAME];
static char u_logdir[LOGDIR];
static wchar_t wu_logdir[LOGDIR];

char	*logdir();
static int	passwdent();
#ifndef apollo
    static int	finddir();
#endif /* !apollo */

#ifdef RDS
    /* ~host!user added by Gary J. Murakami for PDU use July 1984 */
    /* generalized for random RFS mount points for R&D (12/87 emk) */
    /* merged with official KornShell source, 1988 */
#   define HOSTLEN	10
#   define NENTS	(IOBSIZE/sizeof(struct mnttab))
    static char	*getpbase();
    static char *bang;
    static char	name_set = 0;
    static struct utsname name;
    extern int	uname();
#endif /* RDS */
/*
 * This routine is used to resolve ~ filenames.
 * If string starts with ~ then ~name is replaced with login directory of name.
 * A ~ by itself is replaced with the users login directory.
 * A ~- is replaced by the last working directory in Shell.
 * If string doesn't start with ~ then NULL returned.
 * If not found then the NULL string is returned.
 */

/* CSI assumptions1(ascii),5(slash) made here. See csi.h. */
char *sh_tilde(string)
char *string;
{
	register char *sp = string;
	register char *cp;
	register int c;
	char	*log;
	char	*usrname;
	if(*sp++!='~')
		return(NULL);
	if((c = *sp)==0 || c=='/')
	{
		return("$HOME");
	}
#ifdef KSHELL
	if((c=='-' || c=='+') && ((c= *(sp+1))==0 || c=='/'))
	{
		if(*sp=='+')
			return("$PWD");
		else
			return("$OLDPWD");
	}
#endif	/* KSHELL */
	/* mbsrchr() not needed here */
	if ((cp = strrchr(sp, '/')) != NULL)
		*cp = 0;
	sp = logdir(sp);
	if(cp)
		*cp = '/';
	return(sp);
}
                                                            
wchar_t *sh_tilde_wcs(string)
wchar_t *string;
{
	register wchar_t *sp = string;
	register wchar_t *cp;
	register wchar_t c;
	char	*log;
	char	*usrname;
	if (*sp++!='~')
		return(NULL);
	if ((c = *sp)==0 || c=='/')
	{
		return(L"$HOME");
	}
#ifdef KSHELL
	if ((c=='-' || c=='+') && ((c= *(sp+1))==0 || c=='/'))
	{
		if(*sp=='+')
			return(L"$PWD");
		else
			return(L"$OLDPWD");
	}
#endif	/* KSHELL */
	if ((cp = wcsrchr(sp, '/')) != NULL)
		*cp = 0;
	if (usrname = wcstombs_alloc(sp)) {
		log = logdir(usrname);
		xfree((void *)usrname);
		if (log) {
			int	l;
			l = sh_mbstowcs(wu_logdir, log, LOGDIR - 1);
			wu_logdir[l] = L'\0';
			sp = wu_logdir;
		} else
			sp = (wchar_t *)NULL;
	} else {
		sp = (wchar_t *)NULL;
	}
	if(cp)
		*cp = L'/';
	return(sp);
}
 

/*
 * This routine returns a pointer to a null-terminated string that
 * contains the login directory of the given <user>.
 * NULL is returned if there is no entry for the given user in the
 * /etc/passwd file or if no room for directory entry.
 * The most recent login directory is saved for future access
 */

char *logdir(user)
char *user;
{
	if(strcmp(user,u_name))
	{
#ifdef NOGETPW
		if(passwdent(user)<0)
			return(NULL);
#else	/* NOGETPW */
		struct passwd *pw;

		if ((pw = getpwnam(user)) == NULL ||
		    (int)strlen(pw->pw_dir) >= LOGDIR)
			return(NULL);
		strcpy(u_name,user);
		strcpy(u_logdir,pw->pw_dir);
		endpwent();
#endif	/* NOGETPW */
	}
	return(u_logdir);
}


#ifdef NOGETPW
/*
 * read the passwd entry for a given <user> and save the uid, gid and home
 */

#ifdef apollo
#	include <pwd.h>

static int passwdent(user)
char *user;
{
        struct passwd *pwd;
        pwd = getpwnam(user);
        if (!pwd) 
                return -1;
        else
	{
                strcpy(u_logdir, pwd->pw_dir);
                strcpy(u_name, pwd->pw_name);
        }
        return 0;
}

#else /* !apollo */

static int passwdent(user)
char *user;
{
	register char *cp;
	register char *bp;
	register int c;
	int fd;
	register int n = strlen(user);
	char buff[LINSZ+IOBSIZE+1];
	char *buff2;
#ifdef RDS
	char hostdir[LINSZ];
	char *host;
	int hostlen;
	extern char *getenv(), *getlogin(), *strchr();
#endif 	/*RDS*/

	if(n>=UNAME)
		return(-1);
#ifdef RDS
	/* check for  ~machine!user */
 	if((bang=strchr(user,'!')))
	{
		hostlen = bang-user;       /* when hostlen=0, on this machine */
		if (hostlen >= HOSTLEN)
			    hostlen = HOSTLEN - 1;
#ifdef PDU
		strcpy(buff,"/../");
		strcpy(buff+4,user);
		buff[hostlen+4] = 0;
		if ( (fd = open(buff,O_RDONLY)) < 0 )
			return( -1 );
#else
		(void) strncpy(hostdir, user, hostlen);
		hostdir[hostlen] = '\0';
		if ((hostlen==0) || !(bp=getpbase(hostdir,buff)))
		{
			if (!name_set)
			{
				if (uname(&name) <0)/* save for future access */
					return(-1);
				else
					name_set++;
			}
			if(hostlen && (strcmp(hostdir,name.nodename)!=0))
				return(-1);
			hostlen = 0;	       /* on this machine */
		}
		else
		{
			hostlen = strlen(bp);
			strcpy(hostdir, bp);
		}
		strcpy(hostdir+hostlen, "/etc/passwd");

		if((fd=open(hostdir,O_RDONLY))<0)
			return(-1);
		hostdir[hostlen] = 0;
#endif
		host = user;
		user = bp = bang + 1;
		if(*bp == '\0')
		{
			if((bp = getenv("LOGNAME")) != NULL)
				user = bp;
			else if((bp = getlogin()) != NULL)
				user = bp;
			else
				bp = user;	/* set back to null char  */
	    	}
		n = strlen(user);		/* have to do again */
 	}
	else
#endif	/*RDS*/
	if((fd=open("/etc/passwd",O_RDONLY))<0)
		return(-1);
	bp = buff2 = &buff[LINSZ];
	*bp = 0;
	while (1)
	{
		/* get a line at a time */
		while((c= *bp++) != '\n')
		{
			/* test for end of buffer */
			if(c==0)
			{
				/* c is length of buff2 entry so far */
				c = bp-buff2;
				if(--c >= LINSZ)
				{
					bp--;
					/* we already have a complete entry */
					break;
				}
				bp = &buff[LINSZ];
				buff2 = strcpy(bp-c,buff2);
				c = read(fd,bp,IOBSIZE);
				bp[c] = 0;
				if(c<=0)
					goto breakout;
			}
		}
		cp = buff2;
		buff2 = bp;
		*(bp-1) = 0;
#ifdef YELLOWP
		if (*cp == '+') cp++;
#endif /* YELLOWP */
		if (cp[n] == ':' && strncmp(cp,user,n) == 0)
		{
#ifdef RDS
			if (bang)
#ifdef PDU
				(void) sprintf( u_logdir,
						"/../%.*s",
						hostlen, host );
#else
	    			strcpy(u_logdir, hostdir);
#endif

#endif 	/*RDS*/
			if (finddir(cp))	/*found dir name*/
			{
				close(fd);
#ifdef RDS
				if (bang)
					strcpy(u_name, host);
				else
#endif 	/*RDS*/
				strcpy(u_name,user);
				return(0);
			}
			break;	/*No directory field; check YP*/
		}
	}
breakout:
	close(fd);
#ifdef YELLOWP
	/**we don't report err if network is down; */
	{		/*we just return search failure*/
		char *sp;
		char *domain;
		int len;

	if (yp_get_default_domain(&domain) == 0
		&& yp_match(domain,"passwd.byname",user,n,&sp,&len) == 0)
		if (finddir(sp))		/*found in YP*/
		{
			strcpy(u_name,user);
			return(0);
		}
	}
#endif /* YELLOWP */
	return(-1);
}

/*
 * Returns true home directory is found in <passwdline>
 */

static	int finddir(passwdline)
char *passwdline;
{

	register char *cp;
	register char *sp;
	register int fields=0;

	for (cp = passwdline; *cp != '\0'; cp++)
	{
		if (*cp == ':' && ++fields == 5)
		{
			cp++;
#ifdef RDS
			if (bang)
				sp = u_logdir+strlen(u_logdir);
			else
#endif 	/* RDS */
			sp = u_logdir;

			while (*cp != ':' && *cp != '\n' && *cp != '\0')
			{
				*sp++ = *cp++;
				if (sp >= (u_logdir+LOGDIR))
					return(0);
			}
			*sp = '\0';
			return (sp != u_logdir);
		}
	}
	return(0);
}
#endif /* apollo */

#ifdef RDS
/*
 * Looks for <host> in the mount table, using buffer <buff>
 * returns 0 if can't find buff.
 * Otherwise, returns pointer to directory within <buff>
 */

static char *
getpbase(host,buff)
register char *host;
char *buff;
{
	register struct mnttab *tab;
	register int n;
	register int fd;
#ifdef KSHELL
	extern char *path_basename();
#else
#	define path_basename(s)	(strrchr(s,'/')+1)
#endif /* KSHELL */
	if ((fd = open(MNTTAB, O_RDONLY)) < 0)
		return (0); 	      /* oh, well... shouldn't EVER happen */
	/* we want to loop through mnttab, searching for the host  */
	while((n=read(fd,buff,NENTS*sizeof(struct mnttab)))>0)
	{
		for(tab=(struct mnttab*)buff;n>0;n-=sizeof(struct mnttab),tab++)
		{
			if(strcmp(path_basename(tab->mt_filsys),host)==0)
			{
				close(fd);
				return(tab->mt_filsys);
			}
		}
	}
	close(fd);
	return(0);
}
#endif 	/* RDS */
#endif	/* NOGETPW */
