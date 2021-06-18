{application,mme_app,
             [{description,"Application that CRUD operations over the user database"},
              {vsn,"1.0.0"},
              {modules,[db,mme_app,mme_main_sup,mme_server]},
              {registered,[mme_server,mme_main_sup]},
              {mod,[mme_app]}]}.
