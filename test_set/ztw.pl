#!/usr/bin/perl -w

######################################################################
# Here is an examination of the behavior of energy estimator;
# I will randomly select a beta window for estimation;
# Most of the codes are copied from the original C-language one;
#
# Written by Xingcheng Lin, 08/17/3014
# ####################################################################

use strict;
use warnings;

open(EAV, "<Eav.txt");
open(EVA, "<Efluc.txt");
open(WRITE, ">estimator-ztw.dat");

my @eav = <EAV>;
my @eva = <EVA>;

close(EAV);
close(EVA);

my @et;

my $i;
my $j;

my @t1;
my @s0;
my @s1;

my $winsize = 100;

for ($i=(0+$winsize); $i<(1000-$winsize); $i++){
   my $tb = 0.5 * $eva[$i];

   my $jx;
   my $lr;
   my $js = $i-$winsize;
   my $jt = $i+$winsize;

   for ($j=$js; $j<$jt; $j++){
      if($j<$i){
	 $jx = $js;
	 $lr = 0;
      }else{
	 $jx = $jt;
	 $lr = 1;
      }
      $s0[$lr] += 1;

      # This is a little different from the original code because the construction is different from there;
      my $ib = $j;
      $s1[$lr] += $eav[$ib];
      $t1[$lr] += $eva[$ib] * ($j - $jx + 0.5);
   }


   my $a = 1.0;
   my $b = 1.0;
   my $ip = $jt - $i;
   my $im = $i - $js;

   my $num = $t1[0] + $t1[1] + $tb * ($jt - $js);
   my $den = $t1[0] * $ip - $t1[1] * $im;

   if (abs($den) < 1e-8){
      $et[$i] = ($a * $s1[0] + $b * $s1[1]) / ($a * $s0[0] + $b * $s0[1]);
   }

   my $del = $num/$den;
   if (($a = 1.0 - $del*$ip) < 0.0){
      $a = 0.0;
   }
   if (($b = 1.0 + $del*$im) < 0.0){
      $b = 0.0;
   }

   my $tmp = 1.0/($a+$b);
   $a *= $tmp;
   $b *= $tmp;

   # Finally we have $et, the difference from the original code is every bin has value, so none of
   # s0[0] or s0[1] could be zero;
   #

   $et[$i] = ($a * $s1[0] + $b * $s1[1]) / ($a * $s0[0] + $b * $s0[1]);

   # Print the final result to a file;
   print WRITE "$i\t$et[$i]\n";
}
close(WRITE);

