// Models
window.MasterKey = Backbone.Model.extend({
    idAttribute: "key_id"
});

window.MasterKeyCollection = Backbone.Collection.extend({
    model:MasterKey,
    url: function(){
      return '../kms/master-keys/' + this.options.alias;
    },
    initialize: function(models, options){
        this.options=options;
    }
});

// Views
window.MasterKeyListView = Backbone.View.extend({

    tagName:'ul',

    initialize:function () {
        this.model.bind("reset", this.render, this);
    },

    render:function (eventName) {
        _.each(this.model.models, function (masterkey) {
            $(this.el).append(new MasterKeyListItemView({model:masterkey}).render().el);
        }, this);
        return this;
    }

});

window.MasterKeyListItemView = Backbone.View.extend({

    tagName:"li",

    template:_.template($('#tpl-masterkey-list-item').html()),

    render:function (eventName) {
        $(this.el).html(this.template(this.model.toJSON()));
        return this;
    }

});


// Router
var AppRouter = Backbone.Router.extend({

    routes:{
        "masterkeys/:key_alias":"masterkeyDetails"
    },

    masterkeyDetails:function (key_alias) {
        this.masterkeyList = new MasterKeyCollection(null, { alias: key_alias });
        this.masterkeyListView = new MasterKeyListView({model:this.masterkeyList});
        var self = this;
        this.masterkeyList.fetch().done(function(){
            $('#kmsMasterKeyBody').html(self.masterkeyListView.render().el);
        });
    }
});

var app = new AppRouter();
Backbone.history.start();