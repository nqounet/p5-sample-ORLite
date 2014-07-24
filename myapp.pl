#!/usr/bin/env perl
#ｕｔｆ８
use utf8;

package Model;
use strict;
use ORLite {
    file   => __FILE__ . qq{.db},
    create => sub {
        my $dbh = shift;
        $dbh->do(
            'CREATE TABLE bbs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        msg TEXT NOT NULL
      )'
        );
        return 1;
    },
    unicode => 1,
};

package main;
use Mojolicious::Lite;
use Mojo::ByteStream qw(b);
use JSON::XS qw(decode_json);

app->secrets( b(__FILE__)->md5_sum )->log->level('debug')
    ->debug( app->secrets );

app->static->paths( ['app'] );
app->renderer->default_format('json');

under '/api/v1';

get '/entries' => sub {
    my $self    = shift;
    my @entries;
    for my $entry (Model::Bbs->select('order by id desc')) {
      push @entries, {msg => $entry->msg};
    }
    $self->render( json => { entries => [@entries] } );
};

post '/entries' => sub {
    my $self = shift;
    my $json = $self->req->body;
    my $content = decode_json($json);
    warn app->dumper($content);
    Model::Bbs->create( %$content );
    $self->redirect_to('/api/v1/entries');
};

app->start;
