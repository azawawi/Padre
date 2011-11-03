package Padre::Wx::Diff2;

use 5.008;
use strict;
use warnings;
use Padre::Wx               ();
use Padre::Wx::FBP::Diff    ();
use Wx::Scintilla::Constant ();
use Padre::Logger qw(TRACE);


our $VERSION = '0.91';
our @ISA     = qw{
	Padre::Wx
	Padre::Wx::FBP::Diff
};

# Constructor
sub new {
	my $class = shift;
	my $main  = shift;
	my $self  = $class->SUPER::new($main);

	# Bitmap tooltips and icons
	$self->{prev_diff}->SetBitmapLabel( Padre::Wx::Icon::find("actions/go-up") );
	$self->{prev_diff}->SetToolTip( Wx::gettext('Previous difference') );
	$self->{next_diff}->SetBitmapLabel( Padre::Wx::Icon::find("actions/go-down") );
	$self->{next_diff}->SetToolTip( Wx::gettext('Next difference') );

	# Readonly!
	$self->{left_editor}->SetReadOnly(1);
	$self->{right_editor}->SetReadOnly(1);

	return $self;
}

sub show {
	my $self = shift;

	# TODO replace these with parameter-based stuff once it is working
	my $left_text = <<'CODE';
1
2
3
4
CODE
	my $right_text = <<'CODE';
1
1.1
2
3.1
4
CODE

	# TODO this should be task-based once it is working
	my $diffs = $self->find_diffs( $left_text, $right_text );

	#use Data::Dumper; print Dumper($diffs);

	# Set the left side text
	my $left_editor = $self->{left_editor};
	$self->show_line_numbers($left_editor);
	$left_editor->SetReadOnly(0);
	$left_editor->SetText($left_text);
	$left_editor->SetReadOnly(1);

	# Set the right side text
	my $right_editor = $self->{right_editor};
	$self->show_line_numbers($right_editor);
	$right_editor->SetReadOnly(0);
	$right_editor->SetText($right_text);
	$right_editor->SetReadOnly(1);

	$left_editor->StyleSetForeground( 1, Wx::Colour->new( 0xff, 0xff, 0xff ) );
	$left_editor->StyleSetBackground( 1, Wx::Colour->new( 0xff, 0x00, 0x00 ) );
	$left_editor->StyleSetForeground( 2, Wx::Colour->new( 0xff, 0xff, 0xff ) );
	$left_editor->StyleSetBackground( 2, Wx::Colour->new( 0x00, 0xff, 0x00 ) );
	$right_editor->StyleSetForeground( 1, Wx::Colour->new( 0xff, 0xff, 0xff ) );
	$right_editor->StyleSetBackground( 1, Wx::Colour->new( 0xff, 0x00, 0x00 ) );
	$right_editor->StyleSetForeground( 2, Wx::Colour->new( 0xff, 0xff, 0xff ) );
	$right_editor->StyleSetBackground( 2, Wx::Colour->new( 0x00, 0xff, 0x00 ) );
	for my $diff_chunk (@$diffs) {

		for my $diff (@$diff_chunk) {
			my ( $type, $line, $text ) = @$diff;


			if ( $type eq '-' ) {

				# left side
				$left_editor->StartStyling( $left_editor->PositionFromLine($line), 0xFF );
				$left_editor->SetStyling( length($text), 1 );
			} else {

				# right side
				$right_editor->StartStyling( $right_editor->PositionFromLine($line), 0xFF );
				$right_editor->SetStyling( length($text), 2 );
			}
		}
	}

	$self->Show;

	return;
}

sub show_line_numbers {
	my $self   = shift;
	my $editor = shift;

	my $width = $editor->TextWidth(
		Wx::Scintilla::Constant::STYLE_LINENUMBER,
		"m" x List::Util::max( 2, length $editor->GetLineCount )
	) + 5; # 5 pixel left "margin of the margin

	$editor->SetMarginWidth(
		Padre::Constant::MARGIN_LINE,
		$width,
	);
	return;
}

# Find differences between left and right text
sub find_diffs {
	my ( $self, $left_text, $right_text ) = @_;

	my @left_seq  = split /^/, $left_text;
	my @right_seq = split /^/, $right_text;
	my @diff = Algorithm::Diff::diff( \@left_seq, \@right_seq );
	return \@diff;
}

sub on_prev_diff_click {
	$_[0]->main->error('on_prev_diff_click');
}

sub on_next_diff_click {
	$_[0]->main->error('on_next_diff_click');
}

sub on_close_click {
	$_[0]->Destroy;
}

1;

# Copyright 2008-2011 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.