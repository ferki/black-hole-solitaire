package Games::Solitaire::BlackHole::Solver::App::Base;

use Moo;
use Getopt::Long;
use Pod::Usage;
use Math::Random::MT ();

extends('Exporter');

has [
    '_active_record', '_active_task',
    '_board_cards',   '_board_lines',
    '_board_values',  '_init_foundation',
    '_init_queue',    '_is_good_diff',
    '_talon_cards',   '_positions',
    '_quiet',         '_output_handle',
    '_output_fn',     '_seeds',
    '_tasks',         '_task_idx',
] => ( is => 'rw' );
our %EXPORT_TAGS = ( 'all' => [qw($card_re)] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

my @ranks = ( "A", 2 .. 9, qw(T J Q K) );
my %ranks_to_n = ( map { $ranks[$_] => $_ } 0 .. $#ranks );

sub _RANK_KING
{
    return $ranks_to_n{'K'};
}

my $card_re_str = '[' . join( "", @ranks ) . '][HSCD]';
our $card_re = qr{$card_re_str};

sub _get_rank
{
    shift;
    return $ranks_to_n{ substr( shift(), 0, 1 ) };
}

sub _calc_lines
{
    my $self     = shift;
    my $filename = shift;

    my @lines;
    if ( $filename eq "-" )
    {
        @lines = <STDIN>;
    }
    else
    {
        open my $in, "<", $filename
            or die
            "Could not open $filename for inputting the board lines - $!";
        @lines = <$in>;
        close($in);
    }
    chomp @lines;
    $self->_board_lines( \@lines );
    return;
}

sub _trace_solution
{
    my ( $self, $final_state ) = @_;
    my $output_handle = $self->_output_handle;
    $output_handle->print("Solved!\n");

    return if $self->_quiet;

    my $state = $final_state;
    my ( $prev_state, $col_idx );

    my @moves;
LOOP:
    while ( ( $prev_state, $col_idx ) = @{ $self->_positions->{$state} } )
    {
        last LOOP if not defined $prev_state;
        push @moves,
            (
            ( $col_idx == @{ $self->_board_cards } )
            ? "Deal talon " . $self->_talon_cards->[ vec( $prev_state, 1, 8 ) ]
            : $self->_board_cards->[$col_idx]
                [ vec( $prev_state, 4 + $col_idx, 4 ) - 1 ]
            );
    }
    continue
    {
        $state = $prev_state;
    }
    print {$output_handle} map { "$_\n" } reverse(@moves);

    return;
}

sub _my_exit
{
    my ( $self, $verdict, ) = @_;
    my $output_handle = $self->_output_handle;

    if ( !$verdict )
    {
        $output_handle->print("Unsolved!\n");
    }

    if ( defined( $self->_output_fn ) )
    {
        close($output_handle);
    }

    exit( !$verdict );

    return;
}

sub _parse_board
{
    my ($self) = @_;
    my $lines = $self->_board_lines;

    my $found_line = shift(@$lines);

    my $init_foundation;
    if ( my ($card) = $found_line =~ m{\AFoundations: ($card_re)\z} )
    {
        $init_foundation = $self->_get_rank($card);
    }
    else
    {
        die "Could not match first foundation line!";
    }
    $self->_init_foundation($init_foundation);

    $self->_board_cards( [ map { [ split /\s+/, $_ ] } @$lines ] );
    $self->_board_values(
        [
            map {
                [ map { $self->_get_rank($_) } @$_ ]
            } @{ $self->_board_cards }
        ]
    );
    return;
}

sub _set_up_initial_position
{
    my ( $self, $talon_ptr ) = @_;

    my $init_state = "";

    vec( $init_state, 0, 8 ) = $self->_init_foundation;
    vec( $init_state, 1, 8 ) = $talon_ptr;

    my $board_values = $self->_board_values;
    foreach my $col_idx ( 0 .. $#$board_values )
    {
        vec( $init_state, 4 + $col_idx, 4 ) =
            scalar( @{ $board_values->[$col_idx] } );
    }

    # The values of $positions is an array reference with the 0th key being the
    # previous state, and the 1th key being the column of the move.
    $self->_positions( +{ $init_state => [ undef, undef, 1, 0, ], } );

    $self->_init_queue( [$init_state] );

    return;
}

sub _shuffle
{
    my ( $self, $gen, $arr ) = @_;

    my $i = $#$arr;
    while ( $i > 0 )
    {
        my $j = int( $gen->rand( $i + 1 ) );
        if ( $i != $j )
        {
            @$arr[ $i, $j ] = @$arr[ $j, $i ];
        }
        --$i;
    }
    return;
}

sub _process_cmd_line
{
    my ( $self, $args ) = @_;

    my $quiet = '';
    my $output_fn;
    my ( $help, $man, $version );
    my @seeds;

    GetOptions(
        "o|output=s" => \$output_fn,
        "quiet!"     => \$quiet,
        "seed=i\@"   => \@seeds,
        'help|h|?'   => \$help,
        'man'        => \$man,
        'version'    => \$version,
        %{ $args->{extra_flags} },
    ) or pod2usage(2);
    push @seeds, 0 if not @seeds;
    $self->_seeds( \@seeds );

    pod2usage(1) if $help;
    pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

    if ($version)
    {
        print
"black-hole-solve version $Games::Solitaire::BlackHole::Solver::App::Base::VERSION\n";
        exit(0);
    }

    $self->_quiet($quiet);
    my $output_handle;

    if ( defined($output_fn) )
    {
        open( $output_handle, ">", $output_fn )
            or die "Could not open '$output_fn' for writing";
    }
    else
    {
        open( $output_handle, ">&STDOUT" );
    }
    $self->_output_fn($output_fn);
    $self->_output_handle($output_handle);
    $self->_calc_lines( shift(@ARGV) );

    return;
}

sub _set_up_tasks
{
    my ($self) = @_;

    my @tasks;
    foreach my $iseed ( @{ $self->_seeds } )
    {
        push @tasks,
            Games::Solitaire::BlackHole::Solver::App::Base::Task->new(
            {
                _queue           => [ @{ $self->_init_queue } ],
                _seed            => $iseed,
                _gen             => Math::Random::MT->new( $iseed || 1 ),
                _remaining_iters => 100,
            }
            );
    }
    $self->_task_idx(0);
    $self->_tasks( \@tasks );
    return;
}

sub _next_task
{
    my ($self) = @_;
    my $tasks = $self->_tasks;
    return if !@$tasks;
    if ( !@{ $tasks->[ $self->_task_idx ]->_queue } )
    {
        splice @$tasks, $self->_task_idx, 1;
        return $self->_next_task;
    }
    my $task = $tasks->[ $self->_task_idx ];
    $self->_task_idx( ( $self->_task_idx + 1 ) % @$tasks );
    $task->_remaining_iters(100);
    $self->_active_task($task);

    return 1;
}

sub _get_next_state
{
    my ($self) = @_;

    return pop( @{ $self->_active_task->_queue } );
}

sub _get_next_state_wrapper
{
    my ($self) = @_;

    my $positions = $self->_positions;

    while ( my $state = $self->_get_next_state )
    {
        my $rec = $positions->{$state};
        $self->_active_record($rec);
        return $state if $rec->[2];
    }
    return;
}

sub _process_pending_items
{
    my ( $self, $_pending, $state ) = @_;

    my $rec  = $self->_active_record;
    my $task = $self->_active_task;

    if (@$_pending)
    {
        $self->_shuffle( $task->_gen, $_pending ) if $task->_seed;
        push @{ $task->_queue }, map { $_->[0] } @$_pending;
        $rec->[3] += ( scalar grep { !$_->[1] } @$_pending );
    }
    else
    {
        my $parent     = $state;
        my $parent_rec = $rec;
        my $positions  = $self->_positions;

    PARENT:
        while ( ( !$parent_rec->[3] ) or ( ! --$parent_rec->[3] ) )
        {
            $parent_rec->[2] = 0;
            $parent = $parent_rec->[0];
            last PARENT if not defined $parent;
            $parent_rec = $positions->{$parent};
        }
    }
    if ( not --$task->{_remaining_iters} )
    {
        return $self->_next_task;
    }
    return 1;
}

sub _find_moves
{
    my ( $self, $_pending, $board_values, $state, $no_cards ) = @_;
    my $fnd           = vec( $state, 0, 8 );
    my $positions     = $self->_positions;
    my $_is_good_diff = $self->_is_good_diff;
    foreach my $col_idx ( 0 .. $#$board_values )
    {
        my $pos = vec( $state, 4 + $col_idx, 4 );

        if ($pos)
        {
            $$no_cards = 0;

            my $card = $board_values->[$col_idx][ $pos - 1 ];
            if ( exists( $_is_good_diff->{ $card - $fnd } ) )
            {
                my $next_s = $state;
                vec( $next_s, 0, 8 ) = $card;
                --vec( $next_s, 4 + $col_idx, 4 );
                my $exists = exists( $positions->{$next_s} );
                my $to_add = 0;
                if ( !$exists )
                {
                    $positions->{$next_s} = [ $state, $col_idx, 1, 0 ];
                    $to_add = 1;
                }
                elsif ( $positions->{$next_s}->[2] )
                {
                    $to_add = 1;
                }
                if ($to_add)
                {
                    push( @$_pending, [ $next_s, $exists ] );
                }
            }
        }
    }

    return;
}

sub _set_up_solver
{
    my ( $self, $talon_ptr, $diffs ) = @_;

    $self->_parse_board;
    $self->_set_up_initial_position($talon_ptr);
    $self->_set_up_tasks;
    $self->_is_good_diff( +{ map { $_ => 1 } map { $_, -$_ } @$diffs, } );

    return;
}

package Games::Solitaire::BlackHole::Solver::App::Base::Task;

use Moo;

has [ '_queue', '_gen', '_remaining_iters', '_seed', ] => ( is => 'rw' );

1;

__END__

=head1 NAME

Games::Solitaire::BlackHole::Solver::App::Base - base class.

=head1 METHODS

=head2 new

For internal use.

=cut

