#!/usr/bin/perl

use Dancer;

set content_type => 'text/plain';

get '/' => sub {
    "Hello There!"
};

get '/hello/:name' => sub {
    if (params->{name} ne 'sukria') {
        status('not_found');
        content_type("text/plain");
        return "Not found";
    }
    return "Hey ".params->{name}.", how are you?";
};

post '/new' => sub {
    "creating new entry: ".params->{name};
};

get '/say/:word' => sub {
    if (params->{word} =~ /^\d+$/) {
        pass and return false;
    }
    "I say a word: '".params->{word}."'";
};

get '/say/:number' => sub {
    pass if (params->{number} == 42); # this is buggy :)
    "I say a number: '".params->{number}."'";
};

# this is the trash route
get r('/(.*)') => sub {
    my $trash = params->{splat}[0];

    "got to trash: $trash";
};

Dancer->dance;