# COPYRIGHT

package Template::Plugin::Filter::IDN;

# ABSTRACT: Template Toolkit plugin for encoding and decoding International Domain Names.

use strict;
use warnings;
use syntax 'junction';

use parent 'Template::Plugin::Filter';

use Carp ();
use Net::IDN::Encode ();

our $DYNAMIC = 1;

sub init {
    my $self = shift;

    $self->install_filter('idn');

    return $self;
}

sub filter {
    my ($self, $text, $args) = @_;

    my ($type) = @$args;

    # if no "type" was given, try to guess what we should do.  If we have
    # non-ascii chars, assume that we want to_ascii
    unless (defined $type) {
        $type = ($text =~ /[^ -~\s]/) ? 'to_ascii' : 'to_utf8';
    }

    if ($type eq any(qw(encode to_ascii))) {
        return Net::IDN::Encode::domain_to_ascii($text);
    }
    elsif ($type eq any(qw(decode to_utf8))) {
        return Net::IDN::Encode::domain_to_unicode($text);
    }
    else {
        Carp::croak "Unknown IDN filter action: $type";
    }
}

1;

__END__

=for Pod::Coverage init filter

=head1 SYNOPSIS

 #
 # Convert a UTF-8 domain name to Punycode:
 #
 [%- USE Filter.IDN -%]
 <a href="http://[% '域名.org' | idn('to_ascii') %]">Link</a>

 # Output
 <a href="http://xn--eqrt2g.org">Link</a>

 #
 # Convert Punycode to UTF-8:
 #
 [%- USE Filter.IDN -%]
 [% 'xn--eqrt2g.org' | idn('to_utf8') %]

 # Output:
 域名.org

=head1 DESCRIPTION

This is a Template Toolkit filter which handles conversion of International
Domain Names from UTF-8 to ASCII (in Punycode encoding) and vice versa.

=head1 USAGE

Include C<[% USE Filter.IDN %]> in your template.  Then you will be able to use
the C<idn> filter to encode or decode International Domain Names.  The filter
takes a single required argument which is the action that is requested.  The
must be one of the following values:

=for :list
* to_ascii
Convert a UTF-8 label to Punycode.  If the string is already an ASCII string,
the original string will be passed through the filter.
* encode
This is an alias for C<to_ascii>.  Think "encode" to Punycode.
* to_utf8
Convert a Punycode label to UTF-8.  If the string is not a Punycode string,
then the original string will be passed through the filter.
* decode
This is an alias for C<to_utf8>.  Think "decode" from Punycode.

=head1 SEE ALSO

L<Net::IDN::Encode>
