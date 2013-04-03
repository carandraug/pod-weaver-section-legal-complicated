## This is in part copied from t/legal_section.t in Pod-Weaver-3.101638

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences;
use Moose::Autobox 0.10;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

## basic usage
eq_or_diff (weave (<<'IN'), <<'OUT');
# AUTHOR:  Mary Jane <mary.jane@thisside.com>
# OWNER:   Mary Jane
# LICENSE: Perl_5
IN
=pod

=head1 AUTHOR

Mary Jane <mary.jane@thisside.com>

=head1 COPYRIGHT

This software is copyright (c) by Mary Jane.

This software is available under the same terms as the perl 5 programming language system itself.

=cut
OUT

## basic usage with multiple authors and owners
eq_or_diff (weave (<<'IN'), <<'OUT');
# AUTHOR:  John Doe <john.doe@otherside.com>
# AUTHOR:  Mary Jane <mary.jane@thisside.com>
# OWNER:   University of Over Here
# OWNER:   Mary Jane
# LICENSE: GPL_3
IN
=pod

=head1 AUTHORS

John Doe <john.doe@otherside.com>

Mary Jane <mary.jane@thisside.com>

=head1 COPYRIGHT

This software is copyright (c) by University of Over Here, and Mary Jane.

This software is available under The GNU General Public License, Version 3, June 2007.

=cut
OUT

## test removal of trailing whitespace
eq_or_diff (weave (<<'IN'), <<'OUT');
# AUTHOR:  John Doe <john.doe@otherside.com>   
# AUTHOR:  Mary Jane <mary.jane@thisside.com>   
# OWNER:   University of Over Here    
# OWNER:   Mary Jane	
# LICENSE: GPL_3
IN
=pod

=head1 AUTHORS

John Doe <john.doe@otherside.com>

Mary Jane <mary.jane@thisside.com>

=head1 COPYRIGHT

This software is copyright (c) by University of Over Here, and Mary Jane.

This software is available under The GNU General Public License, Version 3, June 2007.

=cut
OUT

## multiple authors, owners, and licenses
eq_or_diff (weave (<<'IN'), <<'OUT');
# AUTHOR:  John Doe <john.doe@otherside.com>
# AUTHOR:  Mary Jane <mary.jane@thisside.com>
# OWNER:   University of Over Here
# OWNER:   Mary Jane
# LICENSE: GPL_3
# LICENSE: Perl_5
IN
=pod

=head1 AUTHORS

John Doe <john.doe@otherside.com>

Mary Jane <mary.jane@thisside.com>

=head1 COPYRIGHT

This software is copyright (c) by University of Over Here, and Mary Jane.

This software is available under The GNU General Public License, Version 3, June 2007, and the same terms as the perl 5 programming language system itself.

=cut
OUT


sub weave {
  my $perl_source   = shift;
  my $ppi_document  = PPI::Document->new(\$perl_source);

  ## prepare the weaver
  my $assembler = Pod::Weaver::Config::Assembler->new;
  $assembler->sequence->add_section(
    $assembler->section_class->new({ name => '_' })
  );
  $assembler->change_section('Legal::Complicated');
  my $weaver = Pod::Weaver->new_from_config_sequence( $assembler->sequence );

  my $woven = $weaver->weave_document({
    pod_document => Pod::Elemental->read_string("=pod\n=cut"),
    ppi_document => $ppi_document,
  });

  return $woven->as_pod_string;
}

done_testing;
