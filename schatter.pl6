#!/usr/bin/env raku

# schatter.pl6
# Theo van den Heuvel, March 2020
#
# UNFINISHED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

use v6;


# assess best fit given data
# data comes from Dutch corona data
# we try various curves
# linear
# exponential
# gaussian
my @data =
    503,
    614,
    804,
    959,
    1135,
    1413,
    1705,
    2051,
    2460,
    2994,
    3631,
    4204,
    4749,
    5560,
    6412,
    7431,
    8603,
    9762,
    10866;

my $trainset-size = 14;


# we look for the minimal squared error in all cases;
# the following are examples, not in actual use.

# sub linear($slope, $intercept) {
#     return -> $x { $slope * $x + $intercept };
# }

# sub exponential($base) {
#     return -> $x { $base ** $x }
# }

# sub gaussian($sigma, $mu) {
#     return -> $x { exp( - ( ($x - $mu) / $sigma ) ** 2  / 2 ) / ( $sigma * sqrt( 2 * pi )); }
# }


# # test

# my $l = linear(1, 3);
# my $e = exponential(1.2);
# my $g = gaussian(1,1);

# sub test-fungen() {
#     for ^10 {
#         say "lin $_ = {$l($_)}";
#         say "exp $_ = {$e($_)}";
#         say "gau $_ = {$g($_)}";
#     }
# }

class FunModel {
    has $!name;
    has &!calc;

    method new($name, &calc) {
        return self.bless(:$name, :&calc);
    }
    submethod BUILD(:$!name, :&!calc) {}

    method calculate(*@arg) {
        note "name $!name, sign: {&!calc.signature || '--'}";
        without &!calc {
            die "calc not defined";
        }
        say @arg.perl;
        my &f =  &!calc(|@arg);
        say &f.perl;
        &f;
    }
    method gist {
        return "$!name";
    }
}
# my &f = -> $slope, $intercept { say "calcing";  -> $x { $slope * $x + $intercept }};
# say &f;
# say &f.signature;

my FunModel $linear .= new:
    'linear', 
    -> $slope, $intercept { say "calcing";  -> $x { $slope * $x + $intercept }};


class Guess {
    has FunModel $!fun-model;
    has @!parm;
    has $!error;
    submethod BUILD(:$!fun-model, :@!parm) {}
    submethod TWEAK() {
        say "tweaking!";
        $!error = 42;
        with $!fun-model {
            $!error = errsqd($!fun-model.calculate(@!parm));
        }
        say "tweaking done";
    }
    method gist { say $!error }
}

sub errsqd(&f) {
    [+] @data.head($trainset-size).kv.map: -> $k, $v { ($v - &f($k)) ** 2 }
}

sub test1 () {
    say $linear;
}
sub test2 () {
    my Guess $guess .= new: fun-model=> $linear, parm=>(0, 0);
    say $guess;   
}

test2();

# # # find best 
# my @parm = 0, 0;

# my @best-so-far = |@parm, errsqd($linear(|@parm));
# say @best-so-far;
# my $optparm = 0; # parm being optimized
# my $pow = 0;
# for ^4 {
#     # switch optparm
#     $optparm = ($optparm + 1) % @parm.elems;
#     # find outer estimate of parm values
#     do {
#         my @new-parm = @parm;
#         my $stepsize = 2 ** $pow;
#         @new-parm[$optparm] = @parm[$optparm] + $stepsize;
#         my @up = |@new-parm, errsqd($linear(|@new-parm));
#         @new-parm[$optparm] = @parm[$optparm] - $stepsize;
#         my @down = |@new-parm, errsqd($linear(|@new-parm));
#         # last unless in-order(@down[2], @best-so-far[2], @up[2])
            
#     }
#     my @new-parm = @parm;
#     my $stepsize = 2 ** $pow;
#     @new-parm[$optparm] = @parm[$optparm] + $stepsize;
#     my @up = |@new-parm, errsqd($linear(|@new-parm));
#     @new-parm[$optparm] = @parm[$optparm] - $stepsize;
#     my @down = |@new-parm, errsqd($linear(|@new-parm));
#     # if up or down is lower than so far, move in that direction
#     # while doubling stepsize until it no longer goes down
#     # do search by repeatedly cutting in four 
#     # and limiting the search to between the two lowest points
# }

# # start values
# my &f = -> $x { $y0 + $grad * $x };


# # constant $big = 1_000_000_000;
# my $eps = .001;
# my $prev-err;
# my $tmp-err;
# my $cur-err;

# $prev-err = errsq();

# while !$cur-err or abs($prev-err - $cur-err) > $eps {
#     # try improve the parms
#     $cur-err = $prev-err;
#     # optimize y0
#     for 0..3 -> $grad {
#         my $unit = 1 / (10 ** $grad);
#         while $y0 += $unit 
#         my $err = errsq
#     }
#     # optimize grad
# } 
