#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::Differences;

use File::Spec;
use File::Spec::Functions qw( catpath splitpath rel2abs );

my $bin_dir = catpath( ( splitpath( rel2abs $0 ) )[ 0, 1 ] );

use Test::Trap
    qw(
    trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn
    );

use Socket qw(:crlf);

sub _normalize_lf
{
    my ($s) = @_;
    $s =~ s#$CRLF#$LF#g;
    return $s;
}

trap
{
    system('./black-hole-solve',
        '--game', 'black_hole',
        File::Spec->catfile(
            $bin_dir, "data", "26464608654870335080.bh.board.txt"
        )
    );
};

# TEST
ok (! ($trap->exit), "Running the program successfully.");

my $expected_output = <<'EOF';
Solved!
Move a card from stack 16 to the foundations

Info: Card moved is 2D


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3H


====================

Move a card from stack 16 to the foundations

Info: Card moved is 2S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3C


====================

Move a card from stack 2 to the foundations

Info: Card moved is 4H


====================

Move a card from stack 3 to the foundations

Info: Card moved is 5S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 6D


====================

Move a card from stack 15 to the foundations

Info: Card moved is 7C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 8C


====================

Move a card from stack 16 to the foundations

Info: Card moved is 9H


====================

Move a card from stack 14 to the foundations

Info: Card moved is TH


====================

Move a card from stack 3 to the foundations

Info: Card moved is 9S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 8S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9D


====================

Move a card from stack 12 to the foundations

Info: Card moved is TC


====================

Move a card from stack 0 to the foundations

Info: Card moved is JS


====================

Move a card from stack 9 to the foundations

Info: Card moved is QC


====================

Move a card from stack 14 to the foundations

Info: Card moved is KS


====================

Move a card from stack 7 to the foundations

Info: Card moved is QH


====================

Move a card from stack 7 to the foundations

Info: Card moved is JC


====================

Move a card from stack 8 to the foundations

Info: Card moved is TS


====================

Move a card from stack 0 to the foundations

Info: Card moved is JH


====================

Move a card from stack 9 to the foundations

Info: Card moved is QS


====================

Move a card from stack 10 to the foundations

Info: Card moved is KH


====================

Move a card from stack 7 to the foundations

Info: Card moved is AC


====================

Move a card from stack 14 to the foundations

Info: Card moved is 2C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 3D


====================

Move a card from stack 8 to the foundations

Info: Card moved is 4S


====================

Move a card from stack 15 to the foundations

Info: Card moved is 5D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 6S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 7D


====================

Move a card from stack 4 to the foundations

Info: Card moved is 6H


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5C


====================

Move a card from stack 1 to the foundations

Info: Card moved is 4C


====================

Move a card from stack 4 to the foundations

Info: Card moved is 3S


====================

Move a card from stack 6 to the foundations

Info: Card moved is 2H


====================

Move a card from stack 15 to the foundations

Info: Card moved is AD


====================

Move a card from stack 12 to the foundations

Info: Card moved is KC


====================

Move a card from stack 4 to the foundations

Info: Card moved is AH


====================

Move a card from stack 0 to the foundations

Info: Card moved is KD


====================

Move a card from stack 8 to the foundations

Info: Card moved is QD


====================

Move a card from stack 3 to the foundations

Info: Card moved is JD


====================

Move a card from stack 2 to the foundations

Info: Card moved is TD


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 8D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 7S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 8H


====================

Move a card from stack 2 to the foundations

Info: Card moved is 7H


====================

Move a card from stack 9 to the foundations

Info: Card moved is 6C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5H


====================

Move a card from stack 12 to the foundations

Info: Card moved is 4D


====================



--------------------
Total number of states checked is 8636.
This scan generated 8672 states.
EOF

# TEST
eq_or_diff (_normalize_lf($trap->stdout()), _normalize_lf($expected_output), "Right output.");

trap
{
    system('./black-hole-solve',
        '--game', 'black_hole',
        File::Spec->catfile(
            $bin_dir, "data", "1.bh.board.txt"
        )
    );
};

$expected_output = <<'EOF';
Unsolved!


--------------------
Total number of states checked is 8.
This scan generated 8 states.
EOF

# TEST
eq_or_diff (_normalize_lf($trap->stdout()),
    _normalize_lf($expected_output), "Right output.");


trap
{
    system('./black-hole-solve',
        '--game', 'black_hole',
        "--max-iters", "10000",
        File::Spec->catfile(
            $bin_dir, "data", "26464608654870335080.bh.board.txt"
        )
    );
};

# TEST
ok (! ($trap->exit), "Running --max-iters program successfully.");

$expected_output = <<'EOF';
Solved!
Move a card from stack 16 to the foundations

Info: Card moved is 2D


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3H


====================

Move a card from stack 16 to the foundations

Info: Card moved is 2S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3C


====================

Move a card from stack 2 to the foundations

Info: Card moved is 4H


====================

Move a card from stack 3 to the foundations

Info: Card moved is 5S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 6D


====================

Move a card from stack 15 to the foundations

Info: Card moved is 7C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 8C


====================

Move a card from stack 16 to the foundations

Info: Card moved is 9H


====================

Move a card from stack 14 to the foundations

Info: Card moved is TH


====================

Move a card from stack 3 to the foundations

Info: Card moved is 9S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 8S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9D


====================

Move a card from stack 12 to the foundations

Info: Card moved is TC


====================

Move a card from stack 0 to the foundations

Info: Card moved is JS


====================

Move a card from stack 9 to the foundations

Info: Card moved is QC


====================

Move a card from stack 14 to the foundations

Info: Card moved is KS


====================

Move a card from stack 7 to the foundations

Info: Card moved is QH


====================

Move a card from stack 7 to the foundations

Info: Card moved is JC


====================

Move a card from stack 8 to the foundations

Info: Card moved is TS


====================

Move a card from stack 0 to the foundations

Info: Card moved is JH


====================

Move a card from stack 9 to the foundations

Info: Card moved is QS


====================

Move a card from stack 10 to the foundations

Info: Card moved is KH


====================

Move a card from stack 7 to the foundations

Info: Card moved is AC


====================

Move a card from stack 14 to the foundations

Info: Card moved is 2C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 3D


====================

Move a card from stack 8 to the foundations

Info: Card moved is 4S


====================

Move a card from stack 15 to the foundations

Info: Card moved is 5D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 6S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 7D


====================

Move a card from stack 4 to the foundations

Info: Card moved is 6H


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5C


====================

Move a card from stack 1 to the foundations

Info: Card moved is 4C


====================

Move a card from stack 4 to the foundations

Info: Card moved is 3S


====================

Move a card from stack 6 to the foundations

Info: Card moved is 2H


====================

Move a card from stack 15 to the foundations

Info: Card moved is AD


====================

Move a card from stack 12 to the foundations

Info: Card moved is KC


====================

Move a card from stack 4 to the foundations

Info: Card moved is AH


====================

Move a card from stack 0 to the foundations

Info: Card moved is KD


====================

Move a card from stack 8 to the foundations

Info: Card moved is QD


====================

Move a card from stack 3 to the foundations

Info: Card moved is JD


====================

Move a card from stack 2 to the foundations

Info: Card moved is TD


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 8D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 7S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 8H


====================

Move a card from stack 2 to the foundations

Info: Card moved is 7H


====================

Move a card from stack 9 to the foundations

Info: Card moved is 6C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5H


====================

Move a card from stack 12 to the foundations

Info: Card moved is 4D


====================



--------------------
Total number of states checked is 8636.
This scan generated 8672 states.
EOF

# TEST
eq_or_diff (_normalize_lf($trap->stdout()), _normalize_lf($expected_output),
    "Right output.");

trap
{
    system('./black-hole-solve',
        '--game', 'black_hole',
        File::Spec->catfile(
            $bin_dir, "data", "1.bh.board.txt"
        )
    );
};

$expected_output = <<'EOF';
Unsolved!


--------------------
Total number of states checked is 8.
This scan generated 8 states.
EOF

# TEST
eq_or_diff (_normalize_lf($trap->stdout()), _normalize_lf($expected_output),
    "Right output for --max-iters.");

my $ret_code;
trap
{
    $ret_code = system('./black-hole-solve', '--version');
};

# TEST
is ($ret_code, 0, "Exited successfully.");

# TEST
like ($trap->stdout(),
    qr/\Ablack-hole-solver version (\d+(?:\.\d+){2})\nLibrary version \1\n\z/,
    "Right otuput for --version."
);

trap
{
    system('./black-hole-solve',
        '--game', 'black_hole',
        '--iters-display-step', '1000',
        File::Spec->catfile(
            $bin_dir, "data", "26464608654870335080.bh.board.txt"
        )
    );
};

# TEST
ok (! ($trap->exit), "iters-display-step: running the program successfully.");

$expected_output = <<'EOF';
Iteration: 1000
Iteration: 2000
Iteration: 3000
Iteration: 4000
Iteration: 5000
Iteration: 6000
Iteration: 7000
Iteration: 8000
Solved!
Move a card from stack 16 to the foundations

Info: Card moved is 2D


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3H


====================

Move a card from stack 16 to the foundations

Info: Card moved is 2S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3C


====================

Move a card from stack 2 to the foundations

Info: Card moved is 4H


====================

Move a card from stack 3 to the foundations

Info: Card moved is 5S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 6D


====================

Move a card from stack 15 to the foundations

Info: Card moved is 7C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 8C


====================

Move a card from stack 16 to the foundations

Info: Card moved is 9H


====================

Move a card from stack 14 to the foundations

Info: Card moved is TH


====================

Move a card from stack 3 to the foundations

Info: Card moved is 9S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 8S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9D


====================

Move a card from stack 12 to the foundations

Info: Card moved is TC


====================

Move a card from stack 0 to the foundations

Info: Card moved is JS


====================

Move a card from stack 9 to the foundations

Info: Card moved is QC


====================

Move a card from stack 14 to the foundations

Info: Card moved is KS


====================

Move a card from stack 7 to the foundations

Info: Card moved is QH


====================

Move a card from stack 7 to the foundations

Info: Card moved is JC


====================

Move a card from stack 8 to the foundations

Info: Card moved is TS


====================

Move a card from stack 0 to the foundations

Info: Card moved is JH


====================

Move a card from stack 9 to the foundations

Info: Card moved is QS


====================

Move a card from stack 10 to the foundations

Info: Card moved is KH


====================

Move a card from stack 7 to the foundations

Info: Card moved is AC


====================

Move a card from stack 14 to the foundations

Info: Card moved is 2C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 3D


====================

Move a card from stack 8 to the foundations

Info: Card moved is 4S


====================

Move a card from stack 15 to the foundations

Info: Card moved is 5D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 6S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 7D


====================

Move a card from stack 4 to the foundations

Info: Card moved is 6H


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5C


====================

Move a card from stack 1 to the foundations

Info: Card moved is 4C


====================

Move a card from stack 4 to the foundations

Info: Card moved is 3S


====================

Move a card from stack 6 to the foundations

Info: Card moved is 2H


====================

Move a card from stack 15 to the foundations

Info: Card moved is AD


====================

Move a card from stack 12 to the foundations

Info: Card moved is KC


====================

Move a card from stack 4 to the foundations

Info: Card moved is AH


====================

Move a card from stack 0 to the foundations

Info: Card moved is KD


====================

Move a card from stack 8 to the foundations

Info: Card moved is QD


====================

Move a card from stack 3 to the foundations

Info: Card moved is JD


====================

Move a card from stack 2 to the foundations

Info: Card moved is TD


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 8D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 7S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 8H


====================

Move a card from stack 2 to the foundations

Info: Card moved is 7H


====================

Move a card from stack 9 to the foundations

Info: Card moved is 6C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5H


====================

Move a card from stack 12 to the foundations

Info: Card moved is 4D


====================



--------------------
Total number of states checked is 8636.
This scan generated 8672 states.
EOF

# TEST
eq_or_diff (_normalize_lf($trap->stdout()), _normalize_lf($expected_output), "Right output for iterations step.");

# TEST:$c=2;
foreach my $command (
    [
        './black-hole-solve',
        '--game', 'black_hole',
        '--iters-display-step', '1100',
        File::Spec->catfile(
            $bin_dir, "data", "26464608654870335080.bh.board.txt"
        )
    ],
    [
        './black-hole-solve-resume-api',
        '--game', 'black_hole',
        '--iters-display-step', '1100',
        File::Spec->catfile(
            $bin_dir, "data", "26464608654870335080.bh.board.txt"
        )
    ],
)
{


    trap
    {
        system( @$command);
    };

    # TEST*$c
    ok (! ($trap->exit), "iters-display-step second step: running the program successfully.");

    $expected_output = <<'EOF';
Iteration: 1100
Iteration: 2200
Iteration: 3300
Iteration: 4400
Iteration: 5500
Iteration: 6600
Iteration: 7700
Solved!
Move a card from stack 16 to the foundations

Info: Card moved is 2D


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3H


====================

Move a card from stack 16 to the foundations

Info: Card moved is 2S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 3C


====================

Move a card from stack 2 to the foundations

Info: Card moved is 4H


====================

Move a card from stack 3 to the foundations

Info: Card moved is 5S


====================

Move a card from stack 13 to the foundations

Info: Card moved is 6D


====================

Move a card from stack 15 to the foundations

Info: Card moved is 7C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 8C


====================

Move a card from stack 16 to the foundations

Info: Card moved is 9H


====================

Move a card from stack 14 to the foundations

Info: Card moved is TH


====================

Move a card from stack 3 to the foundations

Info: Card moved is 9S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 8S


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9D


====================

Move a card from stack 12 to the foundations

Info: Card moved is TC


====================

Move a card from stack 0 to the foundations

Info: Card moved is JS


====================

Move a card from stack 9 to the foundations

Info: Card moved is QC


====================

Move a card from stack 14 to the foundations

Info: Card moved is KS


====================

Move a card from stack 7 to the foundations

Info: Card moved is QH


====================

Move a card from stack 7 to the foundations

Info: Card moved is JC


====================

Move a card from stack 8 to the foundations

Info: Card moved is TS


====================

Move a card from stack 0 to the foundations

Info: Card moved is JH


====================

Move a card from stack 9 to the foundations

Info: Card moved is QS


====================

Move a card from stack 10 to the foundations

Info: Card moved is KH


====================

Move a card from stack 7 to the foundations

Info: Card moved is AC


====================

Move a card from stack 14 to the foundations

Info: Card moved is 2C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 3D


====================

Move a card from stack 8 to the foundations

Info: Card moved is 4S


====================

Move a card from stack 15 to the foundations

Info: Card moved is 5D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 6S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 7D


====================

Move a card from stack 4 to the foundations

Info: Card moved is 6H


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5C


====================

Move a card from stack 1 to the foundations

Info: Card moved is 4C


====================

Move a card from stack 4 to the foundations

Info: Card moved is 3S


====================

Move a card from stack 6 to the foundations

Info: Card moved is 2H


====================

Move a card from stack 15 to the foundations

Info: Card moved is AD


====================

Move a card from stack 12 to the foundations

Info: Card moved is KC


====================

Move a card from stack 4 to the foundations

Info: Card moved is AH


====================

Move a card from stack 0 to the foundations

Info: Card moved is KD


====================

Move a card from stack 8 to the foundations

Info: Card moved is QD


====================

Move a card from stack 3 to the foundations

Info: Card moved is JD


====================

Move a card from stack 2 to the foundations

Info: Card moved is TD


====================

Move a card from stack 5 to the foundations

Info: Card moved is 9C


====================

Move a card from stack 10 to the foundations

Info: Card moved is 8D


====================

Move a card from stack 6 to the foundations

Info: Card moved is 7S


====================

Move a card from stack 1 to the foundations

Info: Card moved is 8H


====================

Move a card from stack 2 to the foundations

Info: Card moved is 7H


====================

Move a card from stack 9 to the foundations

Info: Card moved is 6C


====================

Move a card from stack 11 to the foundations

Info: Card moved is 5H


====================

Move a card from stack 12 to the foundations

Info: Card moved is 4D


====================



--------------------
Total number of states checked is 8636.
This scan generated 8672 states.
EOF

    # TEST*$c
    eq_or_diff (_normalize_lf($trap->stdout()),
        _normalize_lf($expected_output),
        "Right output for iterations step on a second step."
    );

}
