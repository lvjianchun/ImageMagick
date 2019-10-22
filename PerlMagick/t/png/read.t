#!/usr/bin/perl
#
# Test reading PNG images
#
# Contributed by Bob Friesenhahn <bfriesen@simple.dallas.tx.us>
#

BEGIN { $| = 1; $test=1; print "1..6\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't/png' || die 'Cd failed';

#
# 1) Test Black-and-white, bit_depth=1 PNG
# 
print( "1-bit grayscale PNG ...\n" );
testRead( 'input_bw.png',
  '2446f29e7ad13d93abb0e34bfca5340e6b7c50c7cc6fccfc12ba1d26f150e85d' );

#
# 2) Test Monochrome PNG
# 
++$test;
print( "8-bit grayscale PNG ...\n" );
testRead( 'input_mono.png',
  'fa43f8c3d45c3efadab6791a6de83b5a303f65e2c1d58e0814803a4846e68593' );

#
# 3) Test 16-bit Portable Network Graphics
# 
++$test;
print( "16-bit grayscale PNG ...\n" );
testRead( 'input_16.png',
  'd4bed86abb1849f69f1a5afb7c5cf8798e8192ba228357f189c277198c14f5a0',
  '2d30a8bed1ae8bd19c8320e861f3140dfc7497ca8a05d249734ab41c71272f08' );
#
# 4) Test 256 color pseudocolor PNG
# 
++$test;
print( "8-bit indexed-color PNG ...\n" );
testRead( 'input_256.png',
  'e3930ba2c0d7813f21e9ac16b058c10904470853dc6a59f9f3b3f1f47da7dc2c' );

#
# 5) Test TrueColor PNG
# 
++$test;
print( "24-bit Truecolor PNG ...\n" );
testRead( 'input_truecolor.png',
  '7d40e88aa651fd6234780c61a6cef9f34ae8f579975240cf5d33c86217a348c9' );

#
# 6) Test Multiple-image Network Graphics
# 
++$test;
print( "MNG with 24-bit Truecolor PNGs...\n" );
testRead( 'input.mng',
  '0cd7b340ab0c0bceac4e95a4248b12987446a9d2df07bcb6e7e7ecd4ddc44b13' );

