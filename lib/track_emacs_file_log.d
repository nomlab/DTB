#!/usr/sbin/dtrace -s

syscall::open:entry
/
  execname == "Emacs-10.7"
/
{
  printf("%s %s %d", execname, copyinstr(arg0), walltimestamp);
}