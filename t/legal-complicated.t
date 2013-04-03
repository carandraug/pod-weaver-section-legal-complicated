## This is in part copied from t/legal_section.t in Pod-Weaver-3.101638

use strict;
use warnings;

use Test::More tests => 2;
use Test::Differences;
use Moose::Autobox 0.10;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

my ($in, $out);


$in = <<'EOF';

# AUTHOR:  John Doe <john.doe@otherside.com>
# AUTHOR:  Mary Jane <mary.jane@thisside.com>
# OWNER:   University of Over Here
# OWNER:   Mary Jane
# LICENSE: GPL_3

EOF

$out = <<'EOF';
=pod

=head1 LEGAL

=head2 Authors

John Doe <john.doe@otherside.com>

Mary Jane <mary.jane@thisside.com>

=head2 Copyright and License

This software is Copyright (c) by University of Over Here, and Mary Jane and released under the license of The GNU General Public License, Version 3, June 2007

=cut
EOF

eq_or_diff (weave ($in), $out);

## test removal of trailing whitespace
$in = <<'EOF';

# AUTHOR:  John Doe <john.doe@otherside.com>   
# AUTHOR:  Mary Jane <mary.jane@thisside.com>   
# OWNER:   University of Over Here    
# OWNER:   Mary Jane	
# LICENSE: GPL_3

EOF
eq_or_diff (weave ($in), $out);


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
