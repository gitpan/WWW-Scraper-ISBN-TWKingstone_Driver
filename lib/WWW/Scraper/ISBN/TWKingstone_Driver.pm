# ex:ts=8

package WWW::Scraper::ISBN::TWKingstone_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.01';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::TWKingstone_Driver - Search driver for TWKingstone's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the TWKingstone's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;

use Data::Dumper;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	QUERY	=> 'http://search.kingstone.com.tw/search/searcher.exe?p=&p2=&p3=&p4=&p5=&p9=%s&h=0&l=0&o=&a=15&f=0&t=0&q=&e=&n=&s=1&r=1&z=1&fileaut=&filename=&filetype=&rel_start=1&rel_num=10&sim_start=1&sim_num=10&property=&property=&partner=';

#--------------------------------------------------------------------------

###########################################################################
#Inheritence                                                              #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Kingstone 
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  title
  author
  book_link
  image_link
  pubdate
  publisher
  price_list
  price_sell

The book_link and image_link refer back to the Kingstone website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $url = sprintf(QUERY, $isbn);
	my $mechanize = WWW::Mechanize->new();
	$mechanize->get($url);
	return undef unless($mechanize->success());

	# The Search Results page
	my $template = <<END;
您所搜尋的資料查到筆數共有[% ... %]<a class=inside href="[% book %]">
END

	my $extract = Template::Extract->new;
	my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from TWKingstone result page.")
		unless(defined $data);

	my $book = $data->{book};
	$mechanize->get($book);

	$template = <<END;
書籍基本頁[% ... %]
<img src='[% image_link %]'[% ... %]alt='[% title %]'[% ... %]
作　者：[% ... %]property=">[% author %]</a>[% ... %]
出版社：[% ... %]property=">[% publisher %]</a>[% ... %]
ISBN:[% ... %]">[% isbn %]</td>[% ... %]
出版日：[% ... %]">[% pubdate %]</td>[% ... %]
定　價：[% ... %]">[% price_list %]</font>[% ... %]
特惠價：[% ... %]color:#CC0000;><b>[% price_sell %]</b>
END

	$data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from TWKingstone result page.")
		unless(defined $data);

	$data->{publisher} =~ s/ *$//;

	my $bk = {
		'isbn'		=> $data->{isbn},
		'title'		=> $data->{title},
		'author'	=> $data->{author},
		'book_link'	=> $book,
		'image_link'	=> "http://www.kingstone.com.tw".$data->{image_link},
		'pubdate'	=> $data->{pubdate},
		'publisher'	=> $data->{publisher},
		'price_list'	=> $data->{price_list},
		'price_sell'	=> $data->{price_sell},
	};

	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

=head1 COPYRIGHT

Copyright (C) 2005 Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
