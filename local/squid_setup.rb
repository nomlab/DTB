# -*- coding: utf-8 -*-
require "fileutils"

$src = nil
DTB_LIB = File.dirname File.expand_path(__FILE__)
# DTB_LIB = Dir::pwd.force_encoding("utf-8")

# open default config file at DesktopBookmark/lib/squid/etc/squid.conf.default
File.open(DTB_LIB + "/squid/etc/squid.conf.default", "r"){|f|
  $src = f.read
}

$src.gsub!(/^# (cache_dir ufs )c:(.+)$/){ $1 + DTB_LIB + $2}

# $src

$src.gsub!(/^(access_log )c:(.+)$/){"#{$1}#{DTB_LIB}#{$2}"}

# logfile daemon
$src.gsub!(/^# (logfile_daemon )c:(.+)$/){ $1 + DTB_LIB + $2 }

# cache log
$src.gsub!(/^# (cache_log )c:(.+)$/){ $1 + DTB_LIB + $2 }

# cache_store log
$src.gsub!(/^# (cache_store_log )c:(.+)$/){ $1 + DTB_LIB + $2 }

# mime_table
$src.gsub!(/^# (mime_table )c:(.+)$/){ $1 + DTB_LIB + $2 }

# pid
$src.gsub!(/^# (pid_filename )c:(.+)$/){ $1 + DTB_LIB + $2 }

# netdb_filename
$src.gsub!(/^# (netdb_filename )c:(.+)$/){ $1 + DTB_LIB + $2 }

# diskd_program
$src.gsub!(/^# (diskd_program )c:(.+)$/){ $1 + DTB_LIB + $2 }

# unlinked_program
$src.gsub!(/^# (unlinkd_program )c:(.+)$/){ $1 + DTB_LIB + $2 }

# icon direcotry
$src.gsub!(/^# (icon_directory )c:(.+)$/){ $1 + DTB_LIB + $2 }

# error direcotry
$src.gsub!(/^# (error_directory )c:(.+)$/){ $1 + DTB_LIB + $2 }

# coredump direcotry
$src.gsub!(/^(coredump_dir )c:(.+)$/){ $1 + DTB_LIB + $2 }

File.open(DTB_LIB + "/squid/etc/squid.conf", "w"){|f| f.puts $src }
FileUtils::cp(DTB_LIB + "/squid/etc/mime.conf.default", DTB_LIB + "/squid/etc/mime.conf")

Dir::chdir(DTB_LIB + "/squid/sbin"){
  `./squid -z -f ../etc/squid.conf`
}

