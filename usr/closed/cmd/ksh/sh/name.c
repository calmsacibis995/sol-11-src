/*
 * Copyright (c) 1989, 2010, Oracle and/or its affiliates. All rights reserved.
 */

/*
 * AT&T Bell Laboratories
 *
 */

#include	<limits.h>
#include	<string.h>
#include	<libintl.h>
#include	"defs.h"
#include	"sym.h"
#include	"builtins.h"
#include	"history.h"
#include	"timeout.h"
#include	<locale.h>

#ifdef ECHOPRINT
#   undef ECHO_RAW
#   undef ECHO_N
#endif /* ECHOPRINT */

#ifdef ECHO_RAW
char		*echo_mode();
#endif	/* ECHO_RAW */
#ifdef apollo
void		ev_$set_var();
#endif	/* apollo */
void		name_unscope();

/* This module references the following external routines */
extern char	**environ;
extern struct Amemory *gettree();
extern void	gsort();
extern int	gscan_all();
extern int	gscan_some();
extern int	rand();
extern int	scan_all();
extern void	srand();
extern int	strcmp();
extern char	*utos();

#ifdef ECHO_RAW
static char	*echo_arg;
#endif	/* ECHO_RAW */
static void	attstore();
static long	get_rand();
static long	get_second();
static struct Amemory *inittree();
static void	no_export();
static void	pushnam();
static void	pushnid();
void	rehash();
static void	rm_node();
static void	set_second(long);
static void	set_rand(long);
static long	get_lineno();
static void	set_lineno(int);
static long	get_errno();
static void	set_errno(long);
static char	*staknam();

static int rsflag; /* used to see if "SHELL" has been set in the environment */
static int	initenv;
static int	pwdset;
static char	**argnam;
static struct Amemory	*namebase;
static int	attsize;
static char	*attval;

struct Bfunction sh_seconds = { get_second, set_second};
struct Bfunction sh_randnum = { get_rand, set_rand};
struct Bfunction line_numbers = { get_lineno, set_lineno};
struct Bfunction sh_errno = { get_errno, set_errno };

/*
 * env_ignd: used to maintain a linked list which records illegal env
 * variables ignored by the env_init().
 */
static struct env_ignd {
	char	*name;
	struct env_ignd	*next;
} *env_igndp;


/* ========	variable and string handling	======== */

/*
 *  Table lookup routine
 *  The table <syswds> is searched for string <w> and corresponding value is returned
 *  Even if CSI, assume <syswds> contains only portable sysnam's.
 */
int
sh_lookup(const char *w, SYSTAB syswds)
{
	register int first;
	register const struct sysnod	*syscan;
	register int c;
	if(w==0 || (first= *w)==0)
		return(0);
	syscan=syswds;
	while((c= *syscan->sysnam) && c <= first)
	{
		if(first == c && eq(w,syscan->sysnam))
			return(syscan->sysval);
		syscan++;
	}
	return(0);
}

#ifdef FS_3D
    /*
     * set or unset the mappings given a colon separated list of directories
     */
    static void vpath_set(str,mode)
    char *str;
    int mode;
    {
	register char *lastp, *oldp=str, *newp=strchr(oldp,':');
	while(newp)
	{
		*newp++ = 0;
		if(lastp=strchr(newp,':'))
			*lastp = 0;
		mount((mode?newp:""),oldp,2);
		newp[-1] = ':';
		oldp = newp;
		newp=lastp;
	}
    }
#endif /* FS_3D */
/*
 * perform parameter assignment on an argument list
 */

void env_setlist(arg,xp)
register struct argnod	*arg;
register int xp;
{
	register char *s;
	int traceon;
	if(is_option(ALLEXP))
		xp |= N_EXPORT;
	if(arg)
		traceon = sh_trace((char**)0,0);
	while(arg)
	{
		if(arg->argflag&A_MAC)
			s=mac_trim(arg->argval,0);
		else
			s = arg->argval;
		env_namset(s,sh.var_tree,xp);
		arg=arg->argnxt.ap;
		if(traceon)
		{
			p_setout(ERRIO);
			p_str(s,arg?SP:NL);
		}
	}
}

/*
 * Put <arg> into associative memory.
 * If <xp> & V_FLAG then subscript is not allowed
 * If <xp> & G_FLAG then use the current scope only
 * If <xp> & P_FLAG then assignment is not allowed
 */


/* CSI assumptions1(ascii),5(slash) made here. See csi.h. */
struct namnod	*env_namset(argi,root,xp)
char *argi;
struct Amemory *root;
int 	xp;
{
	char *argscan=argi;
	register struct namnod	*n;
	register int sep = *argscan;
	char *sim;

	/*
	 * XPG4: Allow file name starts with '-'
	 * ie.: hash -- -fooy
	 */
	if(root==sh.alias_tree || root == sh.track_tree)
	{
		while((sep= *argscan) != '=' && !expchar(sep) && sep!='/')
			mb_nextc((const char **)&argscan);
	}
	else if(sh_isalpha(sep))
	{
		do
		{
			mb_nextc((const char **)&argscan);
			sep = *argscan;
		}
#ifdef apollo		
		/* 
		 * dsee defines environment variables that contain .(dots),
		 * allow then to be passed through.
		 */
		while(isalnum(sep) || sep == '.');
#else
		while(sh_isalnum(sep));
#endif /* apollo */
	}
	if(argscan!=argi)
	{
		*argscan = 0;
		n = nam_search(argi,root,N_ADD|(xp&G_FLAG));
		*argscan = sep;
		/* check for subscript*/
		if(sep=='[' && !(xp&V_FLAG))
		{
			argscan = array_subscript(n,argscan);
			sep = *argscan;
		}
		else if(nam_istype(n,N_ARRAY))
			array_dotset(n,ARRAY_UNDEF);
		if(sep && ((sep!='=')||(xp&P_FLAG)))
		{
			if(initenv)
				return(0);
			goto failed;
		}
		if(root==sh.alias_tree)
		{
			if(nam_istype(n,T_FLAG|NO_ALIAS))
				nam_offtype(n,~(NO_ALIAS|T_FLAG|N_EXPORT));
		}
		if(sep == '=')
		{
			argscan++;
			if(n==SHELLNOD)
			{
				sim = path_basename(argscan);
				if(strmatch(sim,"*r*sh"))
					rsflag = 0;	/* restricted shell */
			}
			if(initenv)
			{
				nam_fputval(n, argscan);
				if(n==PWDNOD)
					pwdset++;
			}
			else
			{
#ifdef FS_3D
				if(n==VPATHNOD)
				{
					char *cp = nam_fstrval(n);
					if(cp)
						vpath_set(cp,0);
					vpath_set(argscan,1);
				}
#endif /* FS_3D */
				nam_putval(n, argscan);
			}
			nam_ontype(n, xp&~(G_FLAG|V_FLAG|P_FLAG));
#ifdef apollo
			/*
			 * Set environment variable defined in the underlying
			 * DOMAIN_OS cache. This is done because dsee will only
			 * process the path if it has changed since the last
			 * time it looked.
			 */
			if(nam_istype(n,N_EXPORT) && !nam_istype(n,N_IMPORT) 
				&& !(xp&(G_FLAG|V_FLAG|P_FLAG)))
			{
				short namlen,vallen;
				namlen =strlen(n->namid);
				vallen = strlen(argscan);
				ev_$set_var(n->namid,&namlen,argscan,&vallen);
			}
			/*
			 * if env variable is PATH or SYSTYPE then rehash
			 * the shells tracked_tree.
			 */
			if(n==PATHNOD || n==SYSTYPENOD)
#else			
			if(n==PATHNOD)			
#endif /* apollo */
			{
				sh.lastpath = 0;
				gscan_some(rehash,sh.track_tree,T_FLAG,T_FLAG);
#ifdef ECHO_RAW
				echo_arg = NIL;
#endif	/* ECHO_RAW */
			}
			else if(n==VISINOD || ((n==EDITNOD)&&isnull(VISINOD)))
			{
				/* turn on vi or emacs option if editor name is either*/
				argscan = path_basename(argscan);
				if(strmatch(argscan,"*vi"))
				{
					off_option(EDITVI|EMACS|GMACS);
					on_option(EDITVI);
				}
				if(strmatch(argscan,"*macs"))
				{
					off_option(EDITVI|EMACS|GMACS);
					if(*argscan=='g')
						on_option(GMACS);
					else
						on_option(EMACS);
				}
			}

			else if (n == LANGNOD)
				cb_lang();
			else if (n == LCTYPENOD)
				cb_lcctype();
			else if (n == LCCOLLNOD)
				cb_lccollate();
			else if (n == LCMESGNOD)
				cb_lcmessages();
			else if (n == LCALLNOD)
				cb_lcall();
		}
		return(n);
	}
	if(initenv)
		return(0);
failed:
	sh_fail (argi,(root==sh.alias_tree?e_aliname:e_ident));
	/* NOTREACHED */
	return(0);
}

/* CSI assumptions1(ascii),5(slash) made here. See csi.h. */
struct namnod	*env_namset_wcs(argi,root,xp)
wchar_t *argi;
struct Amemory *root;
int 	xp;
{
	char	*mbs;
	struct namnod	*rv;

	if (!(mbs = wcstombs_alloc(argi)))
		return (NULL);

	rv = env_namset(mbs, root, xp);
	xfree((void *)mbs);
	return (rv);
}

/*
 * Mark each node is invalid
 */

void rehash(np)
register struct namnod *np;
{
	nam_ontype(np,NO_ALIAS);
}

/*
 * Assign values to an array
 */

void env_arrayset(np, argn, argv)
register struct namnod *np;
register int argn;
register char *argv[];
{
	while(--argn > 0)
	{
		if(argn>1  || nam_istype(np,N_ARRAY))
			array_dotset(np,argn-1);
		nam_putval(np,argv[argn]);
	}
}

/*
 * This is the code to read a line and to split it into tokens
 */

void env_readline(names,fd,raw)
char **names;
int fd;
{
	register struct fileblk	*fp;
	register wchar_t c;
	int	i;
	int issep;
	wchar_t mask;
	int maxtry = 10;
	register struct namnod	*n;
	register char *name;
	int checksep = 1;		/* set when looking for separators */
	int	rel;
	wchar_t	escape;
	char	*seppro;
	wchar_t *seps, *seps_save = NULL;
	char is_eol;
	int savstates = st.states;
	/* save in history file if S_FLAG is set */
	if((raw&S_FLAG) && hist_open())
		st.states |= (RWAIT|FIXFLG);
	if(raw&R_FLAG)
		escape = 0;
	else
		escape = ESCAPE;
	if(names && (name = *names))
	{
		if(seppro = mbschr(name, '?'))
			*seppro = '\0';
		n = env_namset(name,sh.var_tree,P_FLAG);
		name = *++names;
		if(seppro)
			*seppro = '?';
	}
	else
	{
		name = 0;
		if(sh.var_tree->nexttree)
			n = nam_search((node_names+(REPLYNOD-sh.bltin_nodes))->nv_name,sh.var_tree,N_ADD);
		else
			n = REPLYNOD;
	}
	{
		char	*mbifs;
		if (mbifs = nam_fstrval(IFSNOD))
			seps_save= seps= mbstowcs_alloc(nam_fstrval(IFSNOD));
		else
			seps = NULL;
	}
	if (seps==NULL)
		seps = (wchar_t *)we_sptbnl;
	if(wcscmp(seps,we_sptbnl)==0)
		mask =  ~(L' '|L'\t'|L'\n');
	else
		mask = 0;
	fp = io_get_ftbl(fd);
	if(!fp || fp == &io_stdout)
	{
		io_init(fd,(struct fileblk*)0,(char*)0);
		fp = io_get_ftbl(fd);
	}
	if(fp->flag&IOWRT)
	{
		int saveout = output;
		output = fd;
		p_flush();
		output = saveout;
		fp->flag &= ~IOWRT;
		fp->last = fp->ptr;
	}
	if(fp->flag&IOSLOW)
		fp->flag |= IOEDIT;
	rel= staktell();
	while(1)
	{
		while((c = io_getc(fd))==0);
		/* check for interrupt */
		if (c == escape)
		{
			if (io_getc(fd) == NL) {
				if (fp->flag & IOEDIT)
					sh_prompt(0);
				continue;
			}
			io_ungetc(fd);
		}
		else if(c==WEOF && !fiseof(fp) && io_intr(fp)<0)
		{
			if(--maxtry > 0)
				continue;
			fp->flag |= IOERR;
		}
		issep = (wcschr(seps,c) != NULL);
		is_eol = (c==NL || c==EOF);
		if(checksep && issep && !is_eol)
		{
			/* visible adjacent separators signify null fields*/
			if(mask || wcschr(we_sptbnl,c)!=0)
				continue;
		}
		checksep = 0;
		if((issep && name) || is_eol)	/* from non-separator to separator */
		{
			if(name==NULL)
			{
				/* remove trailing separators */
				i = staktell();
				while(i > rel)
				{
					i -= sizeof(wchar_t);
					if(wcschr(seps,*(wchar_t *)stakptr(i)))
						continue;
					i += sizeof(wchar_t);
					break;
				}
				stakseek(i);
			}
			wstakputwc(0);
			nam_putval_wcs(n,stakptr(rel));
			stakseek(rel);
		again:
			if(is_option(ALLEXP))
				nam_ontype(n,N_EXPORT);
			if(name)
			{
				n = env_namset(name,sh.var_tree,P_FLAG);
				name = *++names;
			}
			else
				n = 0;
			if(is_eol)
			{
				if(n==0)
					break;
				nam_putval(n, NULLSTR);
				goto again;
				
			}
			checksep = 1;
		}
		else 		/* not a separator */
		{
			if(c==escape)
				c = io_getc(fd);
			wstakputwc(c);
		}
	}
	if(st.states&FIXFLG)
		hist_flush();
	st.states = savstates;
	if (seps_save)
		xfree((void *)seps_save);
}


/*
 * print out the name and value of a name-value pair <n>
 */

int env_prnamval(n,flag)
register struct namnod	*n;
register int	flag;
{
	register char *s;

	if(sh.trapnote&SIGSET)
		sh_exit(SIGFAIL);
	if(flag)
		flag = NL;
	if(nam_istype(n,NO_PRINT)==NO_PRINT)
		return(0);
	if(is_afunction(n))
	{
		if(!flag)
			p_str(e_bltfn,0);
		if(n->value.namval.ip==0 || n->value.namval.rp->hoffset <0)
			flag = NL;
		p_str(n->namid,flag);
		if(!flag)
		{
			p_str(e_fnhdr,0);
			hist_list(n->value.namval.rp->hoffset,0,"\n");
		}
		return(n->value.namsz+1);
	}
	if(s=nam_strval(n))
	{
		char numbuf[30];
#ifdef MULTIDIM
		struct Nodval *nv= &n->value;
#endif /* MULTIDIM */
		p_str(n->namid,0);
		if(!flag)
			flag = '=';
	        if (nam_istype (n, N_ARRAY))
		{
#ifdef MULTIDIM
			int i = 0;
#endif /* MULTIDIM */
			if(nam_istype(n,N_INTGER))
			{
				/* copy to a save place */
				strcpy(numbuf,s);
				s = numbuf;
			}
#ifdef MULTIDIM
			do
			{
				int dot = array_ptr(n)->cur[i++]&ARRAY_MASK;
				p_sub(dot,0);
				nv = nv->namval.aray->val[dot];
			}
			while(nv && (nv->namflg&N_ARRAY));
#else
			p_sub(((int)array_ptr(n)->cur[0]&ARRAY_MASK)-1,0);
#endif /* MULTIDIM */
		}
		p_char(flag);
		if(flag != NL)
#ifdef POSIX
			p_qstr(s,NL);
#else
			p_str(s,NL);
#endif /* POSIX */
		return(1);
	}
	else
		p_str(n->namid,NL);
	return(0);
}

/*
 * print the name of a node followed by the character c
 */


static void pushnid(np)
struct namnod *np;
{
	*argnam++ = np->namid;
}

/*
 * print the nodes in tree <root> which have attributes <flag> set
 */

void env_scan(file,flag,root,option)
int file;
struct Amemory *root;
{
	register char **argv;
	register struct namnod *np;
	register int namec;
	struct namnod *onp = 0;
	p_setout(file);
	namec = gscan_some((void(*)())0,root,flag,flag);
	argv = argnam  = (char**)stakalloc((namec+1)*BYTESPERWORD);
	namec = gscan_some(pushnid,root,flag,flag);
	gsort(argv,namec,strcmp);
	while(namec--)
	{
		if((np = nam_search(*argv++,root,N_NULL)) && np!=onp)
		{
			onp = np;
			if(nam_istype(np,N_ARRAY))
			{
				array_dotset(np,ARRAY_AT);
				do
				{
					env_prnamval(np,option);
				}
				while(array_next(np));
			}
			else
				env_prnamval(np,option);
		}
	}
}

static char *staknam(n,value)
char *	value;
register struct namnod	*n;
{
	register char *p,*q;
	q = stakalloc(strlen(n->namid)+(value?strlen(value):0)+2);
	p=sh_copy(n->namid,q);
	if(value)
	{
		*p++ = '=';
		strcpy(p,value);
	}
	return(q);
}


/*
 * print the attributes of name value pair give by <n>
 */

void	env_prattr(n)
register struct namnod	*n;
{
	register const struct sysnod	*syscan;
	register unsigned val;
#ifdef FLOAT
	register unsigned mask;
#endif /* FLOAT */
	if (namflag(n) != N_DEFAULT)
	{
		syscan=tab_attributes;
		while(*syscan->sysnam)
		{
			val = syscan->sysval;
#ifdef FLOAT
			mask = val;
			if(val&N_INTGER)
				mask |= N_DOUBLE;
			if(nam_istype(n,mask)==val)
#else
			if(nam_istype(n,val)==val)
#endif /* FLOAT */
			{
				p_str(syscan->sysnam,SP);
				if(val == (N_BLTNOD|N_INTGER))
					break;
		                if (nam_istype (n, N_LJUST|N_RJUST|N_ZFILL))
					p_num(n->value.namsz,SP);
			}
		        if(val == N_INTGER && nam_istype(n,N_INTGER))
			{
				if(n->value.namsz != 10)
				{
#ifdef FLOAT
					if(nam_istype(n, N_DOUBLE))
						p_str(e_precision,SP);
					else
#endif /* FLOAT */
						p_str(e_intbase,SP);
					p_num(n->value.namsz,SP);
				}
				break;
			}
			syscan++;
		}
		p_str(n->namid,NL);
	}
}

/*
 * read in the process environment and set up name-value pairs
 * skip over items that are not name-value pairs
 */

int	env_init()
{
	register char *cp;
	register struct namnod	*n;
	register char **e=environ;
	char *next=0;
	struct env_ignd *ie;

	rsflag = 1;
	initenv = 1;
	if(e)
	{
		while (cp = *e++) {
			if (*cp == 'A' && cp[1] == '_' && cp[2] == '_' &&
			    cp[3] == 'z' && cp[4] == '=') {
				next = cp +4;
			} else if (n = env_namset(cp, sh.var_tree, 
			    (N_IMPORT|N_EXPORT))) {
				n->value.namenv = cp;
			} else {
				/*
				 * found an env variable which is illegal
				 * (eg containing '-' dash in its name). Such
				 * env variable should not be a part of ksh
				 * variable, but needs to be retained in the
				 * execution environment as an env variable.
				 */
				ie = malloc(sizeof (struct env_ignd));
				if (ie == NULL)
					continue;
				if ((ie->name = strdup(cp)) == NULL) {
					free(ie);
					continue;
				}
				ie->next = env_igndp;
				env_igndp = ie;
			}
		}
		while(cp=next)
		{
			if(next = mbschr(++cp,'='))
				*next = 0;
			if(cp[2])
			{
				if(n=nam_search(cp+2,sh.var_tree,0))
					nam_newtype(n,(unsigned)(cp[0]-' ')|N_IMPORT|N_EXPORT,cp[1]-' ');
			}
		}
	}
	initenv = 0;
	if(pwdset)
		path_pwd(0);
	return(rsflag);
}

/*
 * put the name and attribute into value of attributes variable
 */

static void attstore(n)
register struct namnod	*n;
{
	register int flag = namflag(n);
	if(!(flag&N_EXPORT) || ((flag&N_INTGER) && (flag&N_BLTNOD)))
		return;
	flag &= (N_RDONLY|N_UTOL|N_LTOU|N_RJUST|N_LJUST|N_ZFILL|N_INTGER);
	*attval++ = '=';
	*attval++ = ' '+flag;
	if(flag&N_INTGER)
		*attval = ' '+n->value.namsz;
	else
		*attval = ' ';
	attval = sh_copy(n->namid,++attval);
}

static void pushnam(n)
register struct namnod	*n;
{
	register char *value;
	if(nam_istype(n,N_IMPORT))
	{
		if(n->value.namenv)
			*argnam++ = n->value.namenv;
	}
	else if(value=nam_strval(n))
		*argnam++ = staknam(n,value);
	if(nam_istype(n,N_RDONLY|N_UTOL|N_LTOU|N_RJUST|N_LJUST|N_ZFILL|N_INTGER))
		attsize += (strlen(n->namid)+4);
}

/*
 * Generate the environment list for the child.
 */


char **env_gen()
{
	register char **er;
	register int namec;
	register char *cp;
	struct env_ignd *ip;

	/* L_ARGNOD gets generated automatically as full path name of command */
	nam_offtype(L_ARGNOD,~N_EXPORT);
	attsize = 6;
	namec = gscan_some ((void(*)())0,sh.var_tree, N_EXPORT|N_IMPORT, N_EXPORT);
	for (ip = env_igndp; ip != NULL; ip = ip->next)
		namec++;
	er = (char**)stakalloc((namec+3)*BYTESPERWORD);
	argnam = ++er;
	gscan_some (pushnam, sh.var_tree, N_EXPORT|N_IMPORT, N_EXPORT);
	for (ip = env_igndp; ip != NULL; ip = ip->next)
		*argnam++ = ip->name;
	*argnam = (char*)stakalloc(attsize);
	cp = attval = sh_copy(e_envmarker,*argnam);
	gscan_some(attstore,sh.var_tree,
		(N_RDONLY|N_UTOL|N_LTOU|N_RJUST|N_LJUST|N_ZFILL|N_INTGER),
		(N_RDONLY|N_UTOL|N_LTOU|N_RJUST|N_LJUST|N_ZFILL|N_INTGER));
	*attval = 0;
	if(cp!=attval)
		argnam++;
	*argnam = 0;
	return(er);
}

/*
 * Initialize the shell name and alias table
 */

void nam_init()
{
	namebase = sh.var_tree = inittree(node_names);
	/* set up random number generator */
#ifdef apollo
	(PPIDNOD)->value.namval.cp = (char*)(&sh.ppid);
	(L_ARGNOD)->value.namval.cp = (char*)(&sh.lastarg);
	(TMOUTNOD)->value.namval.cp = (char*)(&sh_timeout);
	(SECONDS)->value.namval.cp = (char*)(&sh_seconds);
	(MCHKNOD)->value.namval.cp = (char*)(&sh_mailchk);
	(RANDNOD)->value.namval.cp = (char*)(&sh_randnum);
	(ERRNO)->value.namval.cp = (char*)(&sh_errno);
	(LINENO)->value.namval.cp = (char*)(&line_numbers);
	(OPTIND)->value.namval.cp = (char*)(&opt_index);
#endif	/* apollo */
	/* set up the seconds clock */
	set_second(0L);
	sh.alias_tree = inittree(alias_names);
	sh.track_tree = inittree(tracked_names);
	/* for back compatibility scope alias in front of tracked pathnames */
	sh.alias_tree->nexttree = sh.track_tree;
	sh.fun_tree = inittree(built_ins);
}

/*
 * initialize name-value pairs
 */

static struct Amemory *inittree(name_vals)
struct name_value *name_vals;
{
	register struct namnod *np;
	register struct name_value *nv;
	{
		register unsigned flag = 0;
		for(nv=name_vals;*nv->nv_name;nv++)
			flag++;
		np = (struct namnod*)malloc(flag*sizeof(struct namnod));
		if(sh.bltin_nodes==0)
			sh.bltin_nodes = np;
		else if(name_vals==built_ins)
			sh.bltin_cmds = np;
	}
	{
		register struct Amemory *treep;
		treep = gettree(MEMSIZE);
		for(nv=name_vals;*nv->nv_name;nv++,np++)
		{
			np->namid = (char*)nv->nv_name;
			np->value.namval.cp = (char*)nv->nv_value;
#ifdef apollo
			if(*nv->nv_value==0)
				np->value.namval.cp = 0;
#endif	/* apollo */
			nam_typeset(np,nv->nv_flags);
			if(nam_istype(np,N_INTGER))
				np->value.namsz = 10;
			else
				np->value.namsz = 0;
			nam_link(np, treep);
			np->value.namenv = 0;
		}
		return(treep);
	}
}

/*
 * create a new environment scope
 */

void nam_scope(envlist)
struct argnod *envlist;
{
	register struct Amemory *sav_var_tree = sh.var_tree;
	register struct Amemory *newscope;
	newscope = gettree(MEMSIZE/8);
	newscope->nexttree = sav_var_tree;
	sh.var_tree = newscope;
	env_setlist(envlist,N_EXPORT|G_FLAG);
	newscope->nexttree = NULL;
	sh.var_tree = sav_var_tree;
	scan_all(no_export,newscope);
	newscope->nexttree = sav_var_tree;
	sh.var_tree = newscope;
}

/*
 * Temporarily remove name from export list of previous scopes
 */

static void no_export(nnod)
register struct namnod *nnod;
{
	register struct namnod *np = nam_search(nnod->namid,sh.var_tree,N_NULL);
	if(np && nam_istype(np,N_EXPORT))
	{
		nam_offtype(np,~N_EXPORT);
		nam_ontype(np,E_FLAG);
	}
}

/*
 * free up top environment scope
 */

void nam_unscope()
{
	register struct Amemory *ap = sh.var_tree;
	if((sh.var_tree = ap->nexttree)==NULL)
		sh.var_tree = namebase;
	scan_all(rm_node,ap);
	free((char*)ap);
}

/*
 * free up all environment scopes except the first
 */

void name_unscope()
{
	while(sh.var_tree->nexttree)
		nam_unscope();
}

/*
 * Remove a node and free up all the space
 * Restate export attribute for hidden nodes if necessary
 */
static void rm_node(nnod)
register struct namnod *nnod;
{
	register struct namnod *np = nam_search(nnod->namid,sh.var_tree,N_NULL);
	if(np && nam_istype(np,E_FLAG))
	{
		nam_offtype(np,~E_FLAG);
		nam_ontype(np,N_EXPORT);
	}
	nam_offtype(nnod,~N_EXPORT);
	env_nolocal(nnod);
	free((char*)nnod);
}

/* 
 * Remove freeable local space associated with the namval field
 * of nnod. This includes any strings representing the value(s) of the
 * node, as well as its dope vector, if it is an array.
 */

void	env_nolocal (nnod)
register struct namnod *nnod;
{
	if (nam_istype(nnod, N_EXPORT|N_FREE))
		return;
	if (nam_istype(nnod, N_ARRAY))
		array_dotset(nnod,ARRAY_AT);
	nam_free(nnod);
	nam_typeset(nnod, N_DEFAULT);
}

/*
 * Get the value of a built-in node
 * A nam_search may not be necessary
 */

char *nam_fstrval(n)
register struct namnod	*n;
{
	if(sh.var_tree->nexttree)
		n = nam_search((node_names+(n-sh.bltin_nodes))->nv_name,sh.var_tree,N_ADD);
	return(nam_strval(n));
}

/*
 *  for the whence command
 */

int	sh_whence(com,flag)
char **com;
register int flag;
{
	register const char *a1;
	register struct namnod *np;
	register const char *cp;
	char    tmpbuf[LINE_MAX];
	size_t tmpbufsz = sizeof (tmpbuf);

	int notrack;
	int q = 0;
	int r;
	int pflag = (flag&P_FLAG);
	flag &= ~P_FLAG;
	while(a1 = *++com)
	{
		notrack = 1;
		tmpbuf[0] = 0;			/* Initialize buffer */
		r = 0;
		if(flag)
		{
			if (strlcat(tmpbuf, a1, tmpbufsz) >= tmpbufsz)
			{
				r = 2;
			}
		}
		if(pflag)
			goto search;
		/* reserved words first */
		if(sh_lookup(a1,tab_reserved))
		{
			if(flag)
				a1 = (const char *)gettext(is_reserved);
		}
		/* non-tracked aliases */
		else if((np=nam_search(a1,sh.alias_tree,N_NULL))
			&& (notrack=(nam_istype(np,T_FLAG)==0))
			&& (a1=nam_strval(np))) 
		{
			if(flag)
			{
				if(nam_istype(np,N_EXPORT))
					cp = (const char *)gettext(is_xalias);
				else
					cp = (const char *)gettext(is_alias);
				if (strlcat(tmpbuf, cp, tmpbufsz) >= tmpbufsz)
				{
					r = 2;
				}
			}
		}
		/* built-ins and functions next */
		else if(np=nam_search(a1,sh.fun_tree,N_NULL))
		{
			if(flag)
			{
				if(isnull(np))
				{
					if(!nam_istype(np,N_FUNCTION))
						goto search;
					a1 = (const char *)
						gettext(is_ufunction);
				}
				else if(is_abuiltin(np)) {
					if (is_asbuiltin(np))
						a1 = (const char *)
							gettext(is_sbuiltin);
					else
						a1 = (const char *)
							gettext(is_builtin);
				} else if(nam_istype(np,N_EXPORT))
					a1 = (const char *)
						gettext(is_xfunction);
				else
					a1 = (const char *)
						gettext(is_function);
			}
		}
		else
		{
		search:
			if(path_search(a1,2)==0)
				a1 = sh.lastpath;
			sh.lastpath = 0;
			if(a1)
			{
				if(flag)
				{
					if(*a1!= '/')
						a1 = (const char *)
							gettext(is_ufunction);
					else
					/* tracked aliases next */
					if(!notrack && *a1 == '/')
					{
						if (strlcat(tmpbuf,
							(const char *)
							gettext(is_talias),
							tmpbufsz) >= tmpbufsz)
						{
							r = 2;
						}
					}
					else
					{
						if (strlcat(tmpbuf,
							(const char *)
							gettext(is_), tmpbufsz)
							>= tmpbufsz)
						{
							r = 2;
						}
					}
				}
			}
			else 
			{
				r = ENOTFOUND;
				if(flag)
					a1 = (const char *)gettext(e_found);
				else
					a1 = e_nullstr;
			}
		}
		if (r)
			p_setout(ERRIO);
		else
			p_setout(st.standout);
		if (strlcat(tmpbuf, a1, tmpbufsz) >= tmpbufsz)
		{
			r = 2;
		}

		a1 = tmpbuf;
		if (tmpbuf[0])
#ifdef notdef	/* ifdef POSIX */
			p_qstr(a1,NL);
#else
			p_str(a1,NL);
#endif /* POSIX */
		if (!q && r)
			q = r;			/* Save results */
		if (r == 2)
		{
			sh_cwarn("alias too long");
		}
	}
	return(q);
}

/*
 * these functions are used to get and set the SECONDS variable
 */

static time_t sec_offset;

static void
set_second(long n)
{
	sec_offset =  time((time_t*)0) - (time_t)n ;
}

static long get_second()
{
	return((long)(time((time_t*)0)-sec_offset));
}

/*
 * These functions are used to get and set the RANDOM variable
 */

static unsigned last_rand;
static void
set_rand(long n)
{
	srand(n&0x7fff);
	last_rand = 0;
}

/*
 * get random number in range of 0 - 2**15
 * never pick same number twice in a row
 */

static long get_rand()
{
	register int cur;
	do
		cur = sh_rand(0);
	while(cur==last_rand);
	last_rand = cur;
	return((long)cur);
}

static long get_lineno()
{
	return((long)st.cmdline);
}

static void
set_lineno(int n)
{
	if(!initenv)
		st.standin->flin = n;
}

static long get_errno()
{
	return((long)errno);
}

static void
set_errno(long n)
{
		errno = n;
}

void cb_lcall()
{
	int		error = 0;

	/* If LC_ALL is non-null, non-empty string, use it. */
	if (!isnull(LCALLNOD) && !isempty(LCALLNOD)) {
		if (setlocale(LC_ALL, nam_strval(LCALLNOD)) == NULL)
			sh_cwarn(e_locale);
		return;
	}

	/* Otherwise, use LC_*, LANG or "C" for each category. */

	if (!isnull(LCTYPENOD) && !isempty(LCTYPENOD)) {
		if (setlocale(LC_CTYPE, nam_strval(LCTYPENOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_CTYPE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_CTYPE, "C") == NULL)
			error = 1;
	}

	if (!isnull(LCCOLLNOD) && !isempty(LCCOLLNOD)) {
		if (setlocale(LC_COLLATE, nam_strval(LCCOLLNOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_COLLATE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_COLLATE, "C") == NULL)
			error = 1;
	}

	if (!isnull(LCMESGNOD) && !isempty(LCMESGNOD)) {
		if (setlocale(LC_MESSAGES, nam_strval(LCMESGNOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_MESSAGES, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_MESSAGES, "C") == NULL)
			error = 1;
	}

	if (error)
		sh_cwarn(e_locale);

	return;
}

void cb_lcctype()
{
	int		error = 0;

	/* If LC_ALL is being used, LC_CTYPE change is ignored. */
	if (!isnull(LCALLNOD) && !isempty(LCALLNOD))
		return;

	/* Otherwise, use LC_CTYPE, LANG or "C". */
	if (!isnull(LCTYPENOD) && !isempty(LCTYPENOD)) {
		if (setlocale(LC_CTYPE, nam_strval(LCTYPENOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_CTYPE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_CTYPE, "C") == NULL)
			error = 1;
	}

	if (error)
		sh_cwarn(e_locale);

	return;
}

void cb_lccollate()
{
	int		error = 0;

	/* If LC_ALL is being used, LC_COLLATE change is ignored. */
	if (!isnull(LCALLNOD) && !isempty(LCALLNOD))
		return;

	/* Otherwise, use LC_COLLATE, LANG or "C". */
	if (!isnull(LCCOLLNOD) && !isempty(LCCOLLNOD)) {
		if (setlocale(LC_COLLATE, nam_strval(LCCOLLNOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_COLLATE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_COLLATE, "C") == NULL)
			error = 1;
	}

	if (error)
		sh_cwarn(e_locale);

	return;
}

void cb_lcmessages()
{
	int		error = 0;

	/* If LC_ALL is being used, LC_MESSAGES change is ignored. */
	if (!isnull(LCALLNOD) && !isempty(LCALLNOD))
		return;

	/* Otherwise, use LC_MESSAGES, LANG or "C". */
	if (!isnull(LCMESGNOD) && !isempty(LCMESGNOD)) {
		if (setlocale(LC_MESSAGES, nam_strval(LCMESGNOD)) == NULL)
			error = 1;
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_MESSAGES, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_MESSAGES, "C") == NULL)
			error = 1;
	}

	if (error)
		sh_cwarn(e_locale);

	return;
}

void cb_lang()
{
	int		error = 0;

	/* If LC_ALL is being used, LANG change is ignored. */
	if (!isnull(LCALLNOD) && !isempty(LCALLNOD))
		return;

	if (!isnull(LCTYPENOD) && !isempty(LCTYPENOD)) {
		; /* If LC_CTYPE is being used, LANG change is ignored. */
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_CTYPE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_CTYPE, "C") == NULL)
			error = 1;
	}

	if (!isnull(LCCOLLNOD) && !isempty(LCCOLLNOD)) {
		; /* If LC_COLLATE is being used, LANG change is ignored. */
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_COLLATE, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_COLLATE, "C") == NULL)
			error = 1;
	}

	if (!isnull(LCMESGNOD) && !isempty(LCMESGNOD)) {
		; /* If LC_MESSAGES is being used, LANG change is ignored. */
	} else if (!isnull(LANGNOD) && !isempty(LANGNOD)) {
		if (setlocale(LC_MESSAGES, nam_strval(LANGNOD)) == NULL)
			error = 1;
	} else {
		if (setlocale(LC_MESSAGES, "C") == NULL)
			error = 1;
	}

	if (error)
		sh_cwarn(e_locale);

	return;
}

#ifdef ECHO_RAW
char *echo_mode()
{
	register char *cp;
	optflag savopts;
	if(echo_arg==0)
	{
#ifdef apollo
		register struct namnod *np = nam_search("SYSTYPE",sh.var_tree,0);
		if(np && (cp=nam_strval(np)))
		{
			echo_arg = (*cp=='b'?(char*)e_echoflag:(char*)e_minus);
			return(echo_arg);
		}
#endif /* apollo */
		savopts = opt_flags;
		off_option(HASHALL);
#ifdef ECHO_N
		/* BSD style echo is default */
		cp = path_absolute(e_echobin+5); /* 5 == strlen("/bin/") */
		opt_flags = savopts;
		if(cp && eq(cp,e_echobin))
			echo_arg = (char*)e_echoflag;
		else
			echo_arg = (char*)e_minus;
#else
		/* System V style echo is default */
		/* for SVR4 /bin and /usr/bin are equivalent */
		cp = path_absolute(e_echobin+9); /* 9 == strlen("/usr/bin/") */
		opt_flags = savopts;
		/* anything except /usr/ucb/echo gives System V behavior */
		if(cp && eq(cp,e_echoucb))
			echo_arg = (char*)e_echoflag;
		else
			echo_arg = (char*)e_minus;
#endif
	}
	return(echo_arg);
}
#endif	/* ECHO_RAW */
