Tested both scripts under MINGW64 on my laptop (Intel Core i7-3630QM @2.40 GHz) on large elasticsearch log

```
$ wc elasticsearch.log
  17999982  175999824 2137997862 elasticsearch.log
```

#### Perl
```
$ which perl
/usr/bin/perl

$ perl -v

This is perl 5, version 22, subversion 0 (v5.22.0) built for x86_64-msys-thread-multi

Copyright 1987-2015, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

$ md5sum logparse.pl
89b455a980a73de13e8fe6e30ed2a216 *logparse.pl

$ time perl logparse.pl elasticsearch.log+multi '^\[\d{4}-\d{2}-\d{2}\s\d{2}[:]\d{2}[:]\d{2}[,]\d{3}\]' 'WARN' &> /dev/null     
real    0m52.325s
user    0m50.875s
sys     0m1.452s
```

#### Python
```
$ which python
/c/python35/python

$ python --version
Python 3.5.1

$ md5sum logparse.py
70180907326d5d9be55c3c382704e5fc *logparse.py

$ time python logparse.py elasticsearch.log+multi '^\[\d{4}-\d{2}-\d{2}\s\d{2}[:]\d{2}[:]\d{2}[,]\d{3}\]' 'WARN' &> /dev/null

real    1m32.951s
user    0m0.000s
sys     0m0.000s
```
