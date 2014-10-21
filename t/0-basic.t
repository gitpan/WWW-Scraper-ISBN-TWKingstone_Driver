#!/usr/bin/env perl

use strict;
use Test::More tests => 13;

use_ok('WWW::Scraper::ISBN::TWKingstone_Driver');

ok($WWW::Scraper::ISBN::TWKingstone_Driver::VERSION) if $WWW::Scraper::ISBN::TWKingstone_Driver::VERSION or 1;

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

$scraper->drivers("TWKingstone");
my $isbn = "9864175351";
my $record = $scraper->search($isbn);

SKIP: {
	skip($record->error."\n", 10) unless($record->found);

	is($record->found, 1);
	is($record->found_in, 'TWKingstone');

	my $book = $record->book;
	is($book->{'isbn'}, '9864175351');
	is($book->{'title'}, '�Ů�����-�}�еL�H�v�������s����');
	is($book->{'author'}, '������ / ���B��');
	is($book->{'book_link'}, 'http://WWW.KINGSTONE.COM.TW/product.asp?ActID=tornado&ID=2024960224052');
	is($book->{'image_link'}, 'http://www.kingstone.com.tw/Book/images/Product/20249/2024960224052/2024960224052b.jpg');
	is($book->{'pubdate'}, '94�~07��29��');
	is($book->{'publisher'}, '�ѤU���');
	is($book->{'price_list'}, '450');
}
