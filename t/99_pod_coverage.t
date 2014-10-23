#!/usr/bin/perl -w
use strict;

use Test::More tests => 1;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required" if $@;

pod_coverage_ok( "CGI::Application::Plugin::Session", "CGI::Application::Plugin::Session has good POD coverage" );
