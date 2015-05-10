#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Proclet::Declare;

env();

service('api', 'morbo myapp.pl');
service('web', 'grunt serve');

worker(api => 1, web => 1);

color;
run;
