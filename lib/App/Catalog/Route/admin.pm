package App::Catalog::Route::admin;

use Catmandu::Sane;

#use Catmandu::Util qw(:array);
use Dancer ':syntax';
use App::Catalog::Helper;
use App::Catalog::Controller::Admin qw/:all/;

prefix '/admin' => sub {

    #TODO: check role!

    # manage accounts
    get '/account' => sub {
        template 'admin/account';
    };

    get '/account/new' => sub {
        my $id = new_person();
        template 'admin/edit_account', { _id => $id };
    };

    get '/account/search' => sub {
        my $p    = params;
        my $hits = search_person($p);
        template 'admin/account', $hits;
    };

    get '/account/edit/:id' => sub {
        my $id     = param 'id';
        my $person = edit_person($id);
        template 'admin/edit_account', $person;
    };

    post '/account/update' => sub {
        my $p = params;
        $p = h->nested_params($p);

        #update_person($p);
        template 'admin/account';
    };

    get '/account/import' => sub {
        my $id = params->{id};

        my $person_in_db = h->authority_admin->get($id);
        if ($person_in_db) {
            template 'admin/account',
                { error => "There is already an account with ID $id" };
        }
        else {
            my $p = import_person($id);
            template 'admin/edit_account', $p;
        }
    };

    # manage departments
    get '/admin/department' => sub { };

    # monitoring external sources
    get '/inspire-monitor' => sub { };
};

1;
